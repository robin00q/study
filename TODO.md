# 📚 나중에 깊이 공부할 것 (TODO)

> 공부하다 "이건 나중에 제대로 파보자" 싶은 것들을 모아두는 백로그.

## 분산 시스템 / CDC

- [ ] **MySQL AUTO_INCREMENT 발급 시점 vs 커밋 가시성**
  - 맥락: id는 INSERT 실행 시점에 박히지만, 다른 세션엔 COMMIT 시점에야 보임 → 발급 순서 ≠ 커밋 순서.
  - 파볼 것: 트랜잭션 격리 수준(RR/SERIALIZABLE)이 왜 이 갭을 못 막는가, `innodb_autoinc_lock_mode`(0/1/2)의 차이, autocommit vs 명시적 트랜잭션에서의 동작 차이.
  - 왜 중요: "id > last_seen" 워터마크 폴링(증분 ETL, 큐 테이블, Outbox 폴링)에서 데이터 누락(skip)을 일으키는 근본 원인. log-based CDC(LSN)가 이를 구조적으로 해결하는 이유와도 직결.
  - 🧪 **직접 재현**: Docker로 MySQL 8 띄우고 두 세션으로 ① 롤백 시 id 갭 ② 워터마크 skip 시나리오 재현해보기. (Rancher Desktop 설치돼 있음 → 데몬만 켜면 됨)
