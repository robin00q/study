# CDC 04 — 도구와 아키텍처 (Debezium + Kafka)
> 한 줄 요약: (공부 후 직접 채우기)

## 공부할 질문
- [ ] ⭐ Debezium은 정확히 무슨 일을 하나? (DB 로그 → 표준 이벤트로 변환)
    - 흠.. 잘 모른다.. DB 의 binlog 를 읽고 kafka 에 이벤트를 발행하고 debezium 이 관리하는 offset 에 커밋하는 과정을 반복하지않을까?
- [ ] Kafka Connect와 Debezium의 관계는? source connector vs sink connector
    - source connector 로 알고있다. 하지만 잘 모른다.
- [ ] 중간에 Kafka를 두는 이유는? (버퍼링 / 재생 / 소비자 분리)
    - 대용량 eventually consistency 를 적용하는데 제일 괜찮으니까?
- [ ] CDC 이벤트 하나의 구조는? (before / after / op(c,u,d) / source 메타데이터)
    - 몰라용..
- [ ] 소비자가 죽었다 살아나면 어떻게 따라잡나(catch-up)?
    - 음..? 그냥 consumer 는 offset 을 관리하니 이벤트 처리하지않을까요?

## 핵심 개념 (내 말로)

## 직접 해본 것 / 예시

## 헷갈렸던 점 · 질문

## 더 파볼 것

## 출처
