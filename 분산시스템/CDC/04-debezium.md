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

### binlog position

---

형식

- `<binlog 파일명>:<offset>` 예: `mysql-bin.00003:154`
- 그 서버의 binlog 에서 몇 번째 파일, 몇 바이트 지점까지 읽었나를 표현

한계

- 특정 서버의 binlog 파일명/offset 체계는 서버마다 다르다.
- failover 로 replica 가 승격하면 해당 좌표는 무의미하다.

### GTID (Global Transaction ID)

---

형식
- <server_uuid>:<transaction_sequence_number>
- `server_uuid` : 서버의 uid
- `transaction_sequence_number` : 트랜잭션이 커밋되어 binlog 에 쓰일때 부여되는 증가하는 id

장점

- failover 로 replica 가 승격되어도 사용가능하다.

### CDC 이벤트의 구조

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

어떤 데이터를 offset 에 관리하는가?

- GTID 가 켜져있으면(gtid_mode=ON) - GTID 기준으로 위치를 추적/재개한다. (failover 안전)
- GTID 가 꺼져있으면 - binlog 파일명+position 으로 fallback 한다.