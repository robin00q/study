# Debezium 이 만드는 카프카 토픽

---

## 토픽의 종류

---

Debezium/Connect 는 성격이 다른 여러 토픽을 만든다.

| 종류          | 이름 예시                              | 담는 것                     |
|-------------|------------------------------------|--------------------------|
| 데이터 토픽      | dbserver1.inventory.customers      | 테이블 변경 이벤트 (테이블당 1개)     |
| 스키마 변경 토픽   | dbserver1                          | DDL 변경 알림                |
| 트랜잭션 토픽     | dbserver1.transaction              | 트랜잭션 경계                  |
| 내부(Connect) | connect-offsets / configs / status | offset(GTID/pos), 설정, 상태 |

- 크게 **데이터 토픽** vs **내부 토픽** 두 부류다.

## topic.prefix

---

- 데이터 토픽의 이름 규칙은 **<prefix>.<db>.<table>** 이다.
- 함부로 바꿔서는 안된다.
    - `connect-offsets` 토픽이 prefix 를 key 로 사용하기 때문에 바꾸면 새 소스로 인식한다. -> 재스냅샷이 발생한다.
- 왜 'DB 호스트명' 이 아니라 '논리명' 인가 : failover 로 장비가 바뀌어도 정체성을 유지한다.

## connect-offsets 토픽

---

- offset(GTID/pos) 를 저장한다.

|       | 예시 데이터                                                    | 설명                        | 
|-------|-----------------------------------------------------------|---------------------------|
| key   | ["inventory-connector", {"server": "dbserver1"}]          | 어떤 connector 의 offset 인가? |
| value | {"file": "mysql-bin.000003", "pos": 154, "gtids": "..." } | 어디까지 읽었나                  |

## 스키마 변경 토픽

---

|       | 예시 데이터                        | 설명                  | 
|-------|-------------------------------|---------------------|
| key   | {"databaseName": "inventory"} | 어느 DB 의 스키마 변경인가    |
| value | 아래 참고                         | DDL 원문 + 구조화된 변경 정보 |

- ddl : 실행된 DDL 원문 (예: "CREATE TABLE `customers` (...)")
- tableChanges[] : 구조화된 변경
    - type : CREATE / ALTER / DROP
    - id : "inventory.customers"
    - table.primaryKeyColumnNames : ["id"] 
    - table.columns[] : [{name, typeName}, ...] <- binlog 엔 없던 컬럼명/타입!
- databaseName / schemaName / source / ts_ms


## 데이터 토픽의 메시지 형식

---

|       | 예시 데이터                                      | 설명                | 
|-------|---------------------------------------------|-------------------|
| key   | {"id": 1001}                                | 해당 테이블의 PK        |
| value | [04-debezium.md](04-debezium.md) 의 이벤트구조 참고 | Debezium envelope |

**key 가 기본키인 게 중요한 이유**

- 같은 key = 같은 파티션 -> 한 행의 변경들이 순서대로 처리된다.
- 다운스트림이 key 로 upsert 가능 -> 멱등의 기반.