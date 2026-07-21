# Debezium - log-based CDC 준 표준 도구

---

## Debezium 은 무슨일을 하는가?

---

아래의 과정을 반복한다.

1. binlog 를 읽는다.
2. 표준이벤트로 변환한다.
3. Kafka 에 발행한다.
4. Debezium 이 관리하는 offset 에 커밋한다.

**표준이벤트**

- MySQL binlog, Postgres WAL 등 제각각인 로그를 읽어 통일된 형태의 `표준이벤트`로 바꿔준다.
- 다운스트림은 원본이 MySQL 인지 Postgres 인지 몰라도된다.

### Debezium 은 binlog 파일을 읽는 게 아니다. (스트림을 받는다.)

---

- Debezium 은 MySQL 디스크의 binlog.xxxxxx 파일을 직접 열지 않는다.
- 자신을 **가짜 replica(server_id=....) 로 등록**하고, MySQL 이 복제 프로토콜로 binlog 이벤트를 **네트워크로 밀어주는걸 받는다.**

```text
mysql> SHOW PROCESSLIST;
...
+-----+----------+------------------+------+------------------+------+-----------------------------------+
| Id  | User     | Host             | db   | Command          | Time | State                             |
+-----+----------+------------------+------+------------------+------+-----------------------------------+
| 118 | debezium | 172.24.0.5:45498 | NULL | Binlog Dump GTID | 308  | Source has sent all binlog to     |
|     |          |                  |      |                  |      | replica; waiting for more updates |
+-----+----------+------------------+------+------------------+------+-----------------------------------+
```

**어떻게 연결되는가? (TCP + MySQL 프로토콜)**

- TCP 위에서 MySQL 프로토콜로 연결되며, 그 위에서 binlog 를 전달한다.
- Debezium 은 COM_BINLOG_DUMP_GTID 를 **'한 번' 만 요청**한다.
    - 그 이후 MySQL 이 변경이 생길때마다 이벤트를 알아서 밀어준다. (구독 후 push 되는 방식과 유사하다.)

**누락은 어떻게 막는가?**

- **연결중** 에는 `TCP` 가 순서 및 재전송을 보장한다.
- **끊김/재시작** 에는 마지막 offset(GTID/pos) 부터 재시작한다.
    - 이미 보낸 걸 다시 보낼 수 있어 '중복' 가능하다. = at-least-once

## Kafka Connect <-> Debezium

---

- `Kafka Connect` : Kafka 로 데이터를 넣고 빼는 일을 담당하는 프레임워크. 지루한 일 (offset 관리, 재시작, 분산, 직렬화) 을 대신해준다.
- `Debezium` : `Kafka Connect` 위에서 실행되는 source connector 플러그인 모음. (Debezium MySQL connector, Postgres connector ...)
- `source connector` : 데이터를 Kafka 안으로 집어넣는 커넥터 (DB -> Kafka). Debezium 이 이것이다. ✅
- `sink connector` : 데이터를 Kafka 밖으로 (Kafka -> ES/DB 등). 예: ES sink, JDBC sink

전체 그림 :

```text
[MySQL] -> (Debezium source connector) -> [Kafka] -> (ES sink connector) -> [Elasticsearch]
           └──── Kafka Connect 위에서 동작 ────────┘
```

## binlog position

---

형식

- `<binlog 파일명>:<offset>` 예: `mysql-bin.00003:154`
- 그 서버의 binlog 에서 몇 번째 파일, 몇 바이트 지점까지 읽었나를 표현

한계

- 특정 서버의 binlog 파일명/offset 체계는 서버마다 다르다.
- failover 로 replica 가 승격하면 해당 좌표는 무의미하다.

## GTID (Global Transaction ID)

---

형식
- <server_uuid>:<transaction_sequence_number>
- `server_uuid` : 
    - 서버의 uid 
    - (e.g.) a4b6c123-6ddb-11f1-8834-427687b9e9af
- `transaction_sequence_number` : 
    - 트랜잭션이 커밋되어 binlog 에 쓰일때 부여되는 증가하는 id 
    - (e.g.) 1

장점

- failover 로 replica 가 승격되어도 사용가능하다.

## CDC 이벤트의 구조

---

Debezium 표준이벤트는 대략 이렇게 생겼다.

```json
{
  "op": "u",
  "before": {
    "id": 1,
    "name": "A"
  },
  "after": {
    "id": 1,
    "name": "B"
  },
  "source": {
    "db": "shop",
    "table": "users",
    "pos": 154,
    "gtid": "...",
    "ts_ms": 1718800000000
  },
  "ts_ms": 1718800000050
}
```

- `op` : c(insert), u(update), d(delete), r(스냅샷 read)
- `before` : insert 면 null
- `after` : delete 면 null
- `source.pos` : binlog position
- `source.gtid` : GTID
- `source.ts_ms` : DB 가 변경을 "커밋한" 시각 (변경이 binlog 에 커밋된 시각, 트랜잭션이 DB 에서 확정된 순간)
- `ts_ms` : Debezium 이 해당 이벤트를 "만든" 시각

CDC 지연
- `ts_ms` - `source.ts_ms` : 해당 이벤트를 "만든" 시각 - DB 가 변경을 "커밋한" 시각

어떤 데이터를 offset 에 관리하는가?

- GTID 가 켜져있으면(gtid_mode=ON) - GTID 기준으로 위치를 추적/재개한다. (failover 안전)
- GTID 가 꺼져있으면 - binlog 파일명+position 으로 fallback 한다.

## op 4 종 이벤트

---

| op | 트리거    | before | after | 특징                  |
|----|--------|--------|-------|---------------------|
| r  | 스냅샷    | null   | 값     |                     |
| c  | INSERT | null   | 값     |                     |
| u  | UPDATE | 값      | 값     | 양쪽 다 값이 있다. (diff)  |
| d  | DELETE | 값      | null  | + tombstone 이벤트 추가 발행 |