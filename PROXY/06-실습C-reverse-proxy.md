# 실습 (Reverse 프록시)

---

## 실습 흐름

---

```text
[ curl (내 맥/호스트) ]
      │  http://localhost:8080  (그냥 서버라고 생각하고 호출)
      ▼
[ nginx reverse proxy :80 ]   ← 우리가 띄울 reverse 프록시
      │  upstream 으로 분배 (proxy_pass)
      ├──────────────┬──────────────┐
      ▼              ▼
[ web1 (whoami) ] [ web2 (whoami) ]  ← 뒤에 숨은 백엔드 2개
```

- forward 와 반대 : 클라이언트는 백엔드 (web1/web2) 의 존재를 모른다.
    - nginx 만 보고 "이게 서버" 라고 생각한다.

```text
forward 는 curl -x 로 "프록시야" 라고 명시하지만
reverse 는 -x 없이 그냥 목적지처럼 호출한다.
```

## 실습 파일

---

### docker-compose.yml

---

```yaml
services:
  web1:
    image: traefik/whoami
    hostname: web1
  web2:
    image: traefik/whoami
    hostname: web2
  proxy:
    image: nginx:1.27-alpine
    ports:
      - "8080:80"    # HTTP
      - "8443:443"   # HTTPS
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./certs:/etc/nginx/certs:ro
    depends_on: [web1, web2]
```

### nginx.conf

---

```text
events {}

http {
    # 백엔드 2개 묶기 -> 기본 알고리즘은 round-robin
    upstream backend {
        server web1:80;
        server web2:80;
    }
    
    # 최소 reverse proxy: HTTP :80
    server {
        listen 80;
        location / {
            proxy_pass http://backend;
            
            # 백엔드가 원래 클라이언트 IP 를 알게하는 헤더
            proxy_set_header Host               $host;
            proxy_set_header X-Real-IP          $remote_addr;
            proxy_set_header X-Forwarded-For    $proxy_add_x_forwarded_for;
        }
    }
    
    # 클라 <-> nginx 는 HTTPS, nginx <-> 서버는 HTTP
    server {
        listen 443 ssl;
        ssl_certificate         /etc/nginx/certs/server.crt;
        ssl_certificate_key     /etc/nginx/certs/server.key;
        location / {
            # 백엔드에는 http 로 전달
            proxy_pass http://backend;
                              
            proxy_set_header Host               $host;
            proxy_set_header X-Real-IP          $remote_addr;
            proxy_set_header X-Forwarded-For    $proxy_add_x_forwarded_for;
        }
    }
}
```

#### nginx.conf 구조

---

##### http 블록

---

```text
http { ... }                  ← HTTP 전체 설정을 담는 최상위 통
  ├── upstream { ... }        ← "백엔드 그룹" 정의
  └── server { ... }          ← "가상 서버" 하나 (누구의 요청을 받을지)
        └── location { ... }  ← "경로별" 처리 규칙
```

- server : 요청을 받는 쪽
- upstream : 요청을 보낼 쪽

##### server 블록

---

```text
server {
    listen 80;
    location / {
        proxy_pass http://backend;
    }
}
```

- listen : 어느 포트로 들어오는 요청을 이 창구가 받을지
- location / : 들어온 요청을 경로별로 어떻게 처리할지. "/" 는 모든 경로
- proxy_pass : 이 요청은 내가 직접 안 만들고 뒤에 대신 물어봐서 가져다줄게 (reverse proxy 핵심 동작)

##### upstream 블록

---

```text
upstream backend {      # "backend" 라는 이름의 그룹을 정의
    server web1:80;     # 이 그룹의 멤버 1
    server web2:80;     # 이 그룹의 멤버 2
}
```

## 결과

---

### 관찰 1. 로드밸런싱 - Round Robin

---

- `curl -s http://localhost:8080/` 를 여러번 호출할때마다 hostname 이 변경된다.

```text
$ curl -s http://localhost:8080/ | grep Hostname
Hostname: web1
$ curl -s http://localhost:8080/ | grep Hostname
Hostname: web2
$ curl -s http://localhost:8080/ | grep Hostname
Hostname: web1
$ curl -s http://localhost:8080/ | grep Hostname
Hostname: web2
```

### 관찰 2. 클라이언트 <-> 프록시 : TLS / 프록시 <-> 서버 : TCP

---

```text
$ curl -vk https://localhost:8443/

* ...
* SSL connection using TLSv1.3 / AEAD-CHACHA20-POLY1305-SHA256 / [blank] / UNDEF
* ...
*  SSL certificate verify result: self signed certificate (18), continuing anyway.
* ...
< HTTP/1.1 200 OK
< Server: nginx/1.27.5
... 
Hostname: web2
IP: 172.26.0.3
X-Forwarded-For: 172.26.0.1
X-Real-Ip: 172.26.0.1
...
```

- 클라이언트 <-> nginx 는 TLS 핸드셰이크를 했다.
    - `SSL connection using TLSv1.3 / AEAD-CHACHA20-POLY1305-SHA256 / [blank] / UNDEF`
- 서버의 응답을 nginx 가 받아 클라이언트에게 응답했다.
    - `< HTTP/1.1 200 OK`, `Server: nginx/1.27.5`
- 실제 처리는 백엔드(web2), 평문으로 전달됨
    - `Hostname: web2`
    - `RemoteAddr: 172.26.0.4`
    - `X-Forwarded-For: 172.26.0.1`

### 관찰 3. 원래 클라이언트 IP 전달

---

- `X-Real-Ip: 172.26.0.1` : 원래 클라이언트 IP 하나 
- `X-Forwarded-For : 172.26.0.1` - 거쳐온 클라이언트 IP 목록 (프록시 여러 개면 누적 : 클라, 프록시1, 프록시2), 자기자신 프록시IP 제외
- `RemoteAddr : 172.26.0.4:44932` - 자기자신 프록시 IP