# 프록시(Proxy) 학습 로드맵

> 목표: 프록시의 개념을 잡고 → 직접 프록시를 띄워 트래픽을 흘려보고 → 마지막에 pod에 프록시를 올려 사용한다.
> 동기 예제: FastID Authkey 로그인은 "등록된 IP에서만" 되기 때문에, 오피스 맥에서 pod의 SOCKS 프록시를 경유해야 했다. 이 학습의 종착점이 바로 그 구조다.

## 파일 규칙 (study 레포 관례)

- `01-`, `02-` … = **내가 직접 쓰는 노트** (최종적으로 이것만 남김)
- `ai-` = Claude가 만든 설명/스캐폴드/퀴즈 (`rm ai-*`로 정리 가능)
- 실습 인프라(docker-compose, 설정)는 `PROXY/실습/`에 둔다.

## 학습 트랙

각 단계는 질문 스캐폴드(`ai-0X-*.md`)만 제공된다. **답은 같은 번호의 내 노트(`0X-*.md`)에 직접 작성**한다.

| 단계 | 주제 | 형태 | 질문 스캐폴드 |
|---|---|---|---|
| 1 | 프록시란 무엇인가 (소스 IP·중개자 모델) | 개념 | `ai-01-프록시란-무엇인가.md` |
| 2 | Forward vs Reverse 프록시 | 개념 | `ai-02-forward-vs-reverse.md` |
| 3 | HTTP 프록시 동작 — GET 대리요청 · CONNECT 터널(HTTPS) | 개념 | `ai-03-http-프록시-동작.md` |
| 4 | SOCKS 프록시 — SOCKS5, `ssh -D` | 개념 | `ai-04-socks-프록시.md` |
| 5 | 실습 A: forward 프록시 띄우기 (tinyproxy + curl) | 실습 | `ai-05-실습A-forward-proxy.md` |
| 6 | 실습 B: SOCKS 프록시 (microsocks / `ssh -D`) | 실습 | `ai-06-실습B-socks-proxy.md` |
| 7 | 실습 C: reverse 프록시 (nginx) | 실습 | `ai-07-실습C-reverse-proxy.md` |
| 8 | 최종: pod에 프록시 띄우고 `port-forward`로 사용 | 실습 | `ai-08-최종-pod-프록시.md` |

## 실습 준비물

- Docker (forward/reverse/SOCKS 프록시 컨테이너)
- `curl` (요청 도구), 브라우저 (선택)
- 8단계: `kubectl` + 접근 가능한 클러스터

## 진행 방식

- **질문 우선**: `ai-` 스캐폴드의 질문에 스스로 조사·실습해 답을 내 노트(`0X-`)에 기록한다(active recall).
- 막히는 질문은 Claude에게 물어 힌트/설명을 받는다(답을 미리 채워두지 않음).
- 곁가지로 깊게 파고 싶은 건 레포 루트 `TODO.md`에 백로그로 남기고 메인 트랙 유지.
