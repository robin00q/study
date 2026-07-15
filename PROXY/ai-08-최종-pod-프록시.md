# 08 · 최종 — pod에 프록시 띄우고 port-forward로 사용 — 질문

> 범위: 앞 단계를 종합해 pod 프록시를 구성하고, Authkey 문제와 연결. 결과·매니페스트를 `08-...md`(내 노트)에 기록.

1. pod에 SOCKS(또는 HTTP) 프록시(microsocks 등)를 띄우는 **최소 매니페스트**는 어떻게 생겼나? (Service 없이)
2. `kubectl port-forward pod/<name> 1080:1080`이 만드는 터널의 구조는? 왜 Service/Ingress가 필요 없나?
3. 로컬 `curl`/브라우저를 port-forward된 프록시로 경유시키면 소스 IP는 무엇으로 보이나? (pod egress)
4. pod의 **egress IP**를 실제로 어떻게 확인하나? pod IP(`get pod -o wide`)와 egress IP가 다를 수 있는 이유(SNAT)는?
5. 이 구조가 Authkey 로그인 문제를 어떻게 해결하나? 01단계의 "소스 IP" 통찰과 연결해 한 문단으로 정리.
6. 노드가 바뀌면 egress IP가 바뀔 수 있는 문제를 어떻게 다루나? (nodeSelector 고정 / 노드풀 IP 등록 등)
7. 이 프록시는 클러스터 밖에서 접근 불가능한데(진입로가 port-forward뿐), 그게 왜 보안상 이점인가?
8. (종합) 1~8단계를 한 장으로 요약: 개념 → HTTP/SOCKS → forward/reverse → 실습 → pod. 내 언어로.
