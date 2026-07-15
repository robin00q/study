# 실습 (Forward 프록시)

---

## 실습 흐름

---

```text
[ curl  (내 맥/호스트) ]
      │  -x 로 프록시 지정
      ▼
[ tinyproxy 컨테이너 :8888 ]   ← 우리가 도커로 띄울 forward 프록시
      │  대리 요청
      ▼
[ 외부 서버 (httpbin.org/ip, example.com 등) ]
```

- 흐름 :
    1. curl 이 목적지에 직접 안하고, `tinyproxy` 에 대리요청한다.
    2. tinyproxy 가 대리요청한다.
    3. 응답을 curl 에 반환한다.

| 요소             | 역할                                                       |
|----------------|----------------------------------------------------------|
| tinyproxy 컨테이너 | forward HTTP 프록시. :8888 listen                           |
| curl (호스트)     | 클라이언트. -x 로 프록시 지정                                       |
| 관찰 대상          | httpbin.org/ip(소스 IP 에코), example.com(HTTPS CONNECT 관찰용) |

## 관찰 목표

---

1. 프록시 경유 성공 : `curl -x` 로 요청이 tinyproxy 를 거쳐 나가는지
2. 로그 확인 : `tinyproxy` 로그에 요청이 찍히는지
3. HTTP 요청 라인 : `curl -v` 로 보면 absolute-URI (GET http://...) 로 나가는지
4. HTTPS 는 CONNECT - `curl -v https://...` 하면 `CONNECT example.com:443` 이 나가는지

## 실습파일

---

### tinyproxy.conf

---

```text
Port 8888
Listen 0.0.0.0
Timeout 600
Allow 0.0.0.0/0
LogLevel Connect
LogFile "/var/log/tinyproxy.log"
```

| 지시어                   | 의미                                                  |
|-----------------------|-----------------------------------------------------|
| Port 8888             | 프록시가 요청을 받을 포트                                      |
| Listen 0.0.0.0        | 모든 인터페이스에서 수신 - 컨테이너 밖(호스트) 에서 접속하려면 필수             |
| Timeout 600           | 유휴 연결 정리 시간 (초)                                     |
| Allow 0.0.0.0/0       | 누가 이 프록시를 쓸 수 있나 - 여기선 전부 허용                        |
| LogLevel Connect      | 연결 로그를 남김 (요청이 지나가는 걸 관찰)                           |
| LogFile "/var/log/tinyproxy.log" | docker exec tp cat /var/log/tinyproxy.log 로 로그 조회가능 |

> 실무에서는 Allow 0.0.0.0/0 을 하면 아무나 내 프록시를 쓸 수 있기에 특정 대역만 허용해야한다.

### Dockerfile

---

```dockerfile
FROM alpine:3.20
RUN apk add --no-cache tinyproxy
COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
EXPOSE 8888
CMD ["tinyproxy", "-d", "-c", "/etc/tinyproxy/tinyproxy.conf"]
```

## 결과

---

### 관찰 1. 프록시 경유 성공

---

```shell
$ curl -x http://localhost:8888 http://ifconfig.me/ip
43.250.154.216
```

- 프록시로 띄운 localhost:8888 을 경유해 ifconfig.me 로 접근하였다.

### 관찰 2. proxy docker logs

---

```text
CONNECT   Jul 15 06:04:17.010 [1]: Connect (file descriptor 5): 172.17.0.1
CONNECT   Jul 15 06:04:17.012 [1]: Request (file descriptor 5): GET http://ifconfig.me/ip HTTP/1.1
CONNECT   Jul 15 06:04:17.102 [1]: Established connection to host "ifconfig.me" using file descriptor 6.
```

- 프록시가 ifconfig.me 와 연결을 맺었다.

### 관찰 3. absolute-URI


---

```shell
$ curl -v -x http://localhost:8888 http://ifconfig.me/ip
* ... 
> GET http://ifconfig.me/ip HTTP/1.1
> Host: ifconfig.me
> ...
43.250.154.216
```

- `GET http://ifconfig.me/ip HTTP/1.1` 이 확인된다. (`absolute-URI`)
- `-x http://localhost:8888` 없이 호출하면 `GET /ip` 를 확인 할 수 있다.

### 관찰 4. CONNECT

---

**https** 요청은 내용을 못 보니 CONNECT 로 터널만 뚫고 **터널링**한다.

```shell
❯ curl -v -x http://localhost:8888 https://example.com
* ...
> CONNECT example.com:443 HTTP/1.1
> Host: example.com:443
> ...
* CONNECT phase completed
* CONNECT tunnel established, response 200
* ... TLS handshake
<!doctype html><html lang="en"><head><title>Example Domain</title><link rel="icon" href="data:,"><meta name="viewport" content="width=device-width, initial-scale=1"><style>body{background:#eee;width:60vw;margin:15vh auto;font-family:system-ui,sans-serif}h1{font-size:1.5em}div{opacity:0.8}a:link,a:visited{color:#348}</style></head><body><div><h1>Example Domain</h1><p>This domain is for use in documentation examples without needing permission. Avoid use in operations.</p><p><a href="https://iana.org/domains/example">Learn more</a></p></div></body></html>
* Connection #0 to host localhost left intact
```
- `CONNECT` 를 통해 TLS 연결을 클라이언트와 서버가 맺게된다.
