# 06 · 실습 B — SOCKS 프록시 (ssh -D / microsocks) — 질문

> 범위: SOCKS 프록시를 두 방식으로 띄우고 curl/브라우저로 경유. 결과·명령을 `06-...md`(내 노트)에 기록.

1. `ssh -D 1080 user@host`로 SOCKS 프록시를 만들고, `curl --socks5 localhost:1080`로 경유해보라. 소스 IP는?
2. `--socks5` vs `--socks5-hostname` 차이(로컬 DNS vs 원격 DNS)를 실험으로 확인해 기록. (04-3번과 연결)
3. microsocks 컨테이너를 도커로 띄워 같은 실험을 해보라. `ssh -D`와 무엇이 다른가(서버측 설치/설정)?
4. 브라우저를 SOCKS 프록시로 설정해 접속해보고, 접속 사이트가 인식하는 IP를 확인.
5. HTTP/HTTPS 외 프로토콜(예: `redis-cli`, DB 클라이언트)을 SOCKS로 태워보라 — 되는가? HTTP 프록시였다면?
6. (생각) 05단계 forward(HTTP) 프록시와 비교해, SOCKS가 더 범용인 지점을 실측 근거로 정리.
