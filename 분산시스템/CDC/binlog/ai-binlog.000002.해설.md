# binlog.000002 해설 (사람이 읽는 버전)

> - `binlog.000002` : raw 바이너리 (사람이 못 읽음)
> - `binlog.000002.decoded.sql` : `mysqlbinlog -vv` 출력 (재생용이라 노이즈 많음)
> - **이 파일** : 위 출력에서 "신호"만 뽑아 정리한 것

## 이 로그에 담긴 트랜잭션 (1개)

```sql
UPDATE customers SET first_name='변경됨' WHERE id=1004;
```

## 이벤트 흐름 (binlog position 순서)

| pos | 이벤트 | 의미 |
|----:|--------|------|
| 4   | Format_desc      | 파일 헤더 (server v8.2.0) |
| 157 | Anonymous_GTID   | gtid OFF라 익명. `last_committed`/`sequence_number`가 커밋 순서를 표현 |
| 236 | Query: BEGIN     | 트랜잭션 시작 |
| 327 | Table_map        | "이제 `inventory.customers`(table id 116) 얘기다" |
| 401 | **Update_rows** ⭐ | 실제 행 변경 (아래 before/after) |
| 536 | Xid=92: COMMIT   | 커밋 확정 (이 시점이 "진짜 커밋") |

→ pos **401** = Debezium 이벤트의 `source.pos=401`, `op="u"`의 before/after 원천.

## 행 변경 (before → after)

컬럼 매핑: `@1=id, @2=first_name, @3=last_name, @4=email`

| 컬럼 | before (WHERE 블록) | after (SET 블록) | 변경 |
|------|--------------------|------------------|:---:|
| id (@1)         | 1004               | 1004               |  -  |
| first_name (@2) | Anne               | **변경됨**          | ✅ |
| last_name (@3)  | Kretchmar          | Kretchmar          |  -  |
| email (@4)      | annek@noanswer.org | annek@noanswer.org |  -  |

## 핵심 관찰

- row 포맷은 "바뀐 컬럼만"이 아니라 **행 전체(@1~@4)** 를 before/after로 통째 기록한다.
- WHERE 블록 = before 이미지, SET 블록 = after 이미지.
- decoded.sql의 노이즈(`base64 BINLOG '...'`, `SET @@SESSION...`, `DELIMITER`, `/*!50530...*/`)는 **재생(replay)용 보일러플레이트** — 읽을 땐 `###` 줄만 보면 됨.
