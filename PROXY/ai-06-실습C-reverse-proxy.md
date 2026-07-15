# 06 · 실습 C — reverse 프록시 (nginx) — 질문

> 범위: nginx로 reverse 프록시·로드밸런싱·TLS 종료를 구성하고 관찰. 결과·설정을 `06-...md`(내 노트)에 기록.

1. nginx로 reverse 프록시를 구성하는 최소 설정은? (`server` / `location` / `proxy_pass`)
2. 백엔드 2개를 두고 `upstream`으로 로드밸런싱을 구성해보라. 요청이 어떻게 분배되나? (기본 알고리즘은?)
3. TLS 종료(클라이언트↔nginx는 HTTPS, nginx↔백엔드는 HTTP)를 구성해보라. 인증서는 어디에 두나?
4. 백엔드가 "원래 클라이언트 IP"를 알려면 nginx가 무엇을 넘겨줘야 하나? (`X-Forwarded-For`, `X-Real-IP`)
5. 05단계 forward 프록시와 비교: 설정에서 "대상 서버를 누가 정하나"가 어떻게 다른가?
6. `proxy_pass`에 트레일링 슬래시 유무가 경로 전달에 미치는 차이는? (실험으로 확인)
7. (생각) reverse 프록시가 보안/운영에 주는 이점 3가지를 실습 근거로 정리.
