# binlog 의 순서

---

## 2개의 트랜잭션이 동시에 수행되지만, T2 가 먼저 커밋되는 경우

---

**상황**

```text
 시간  │  T1 (먼저 시작)          T2 (나중 시작)
 ─────┼──────────────────────────────────────────
  t0  │  BEGIN
      │  INSERT → id=1
      │     │  ⟵ 트랜잭션 계속 열려있음
  t1  │     │                    BEGIN
      │     │                    INSERT → id=2
  t2  │     │                    COMMIT ✅ (먼저!)
      │     │
  t3  │  COMMIT ✅ (나중)
 ─────┴──────────────────────────────────────────
```

- T1 과 T2 가 동시에 수행된다.
- T1 이 T2 보다 트랜잭션을 먼저 수행하지만, T2 가 먼저 종료되는 상황이다.

**binlog**


```text
mysql> SHOW BINLOG EVENTS in 'binlog.000003';
+---------------+-----+----------------+-----------+-------------+--------------------------------------+
| Log_name      | Pos | Event_type     | Server_id | End_log_pos | Info                                 |
+---------------+-----+----------------+-----------+-------------+--------------------------------------+
| binlog.000003 |   4 | Format_desc    |         1 |         126 | Server ver: 8.2.0, Binlog ver: 4     |
| binlog.000003 | 126 | Previous_gtids |         1 |         157 |                                      |
| binlog.000003 | 157 | Anonymous_Gtid |         1 |         236 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS' |
| binlog.000003 | 236 | Query          |         1 |         316 | BEGIN                                |
| binlog.000003 | 316 | Table_map      |         1 |         381 | table_id: 126 (inventory.t_demo)     |
| binlog.000003 | 381 | Write_rows     |         1 |         449 | table_id: 126 flags: STMT_END_F      |
| binlog.000003 | 449 | Xid            |         1 |         480 | COMMIT /* xid=145 */                 |
| binlog.000003 | 480 | Anonymous_Gtid |         1 |         559 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS' |
| binlog.000003 | 559 | Query          |         1 |         639 | BEGIN                                |
| binlog.000003 | 639 | Table_map      |         1 |         704 | table_id: 126 (inventory.t_demo)     |
| binlog.000003 | 704 | Write_rows     |         1 |         770 | table_id: 126 flags: STMT_END_F      |
| binlog.000003 | 770 | Xid            |         1 |         801 | COMMIT /* xid=140 */                 |
+---------------+-----+----------------+-----------+-------------+--------------------------------------+
```

- binlog 는 트랜잭션의 수정과 관계없이 섞여있지 않다.
- **binlog 의 순서는 커밋순서와 동일**하다.

**요약**

```text
INSERT(id) 순서 : T1(1) -> T2(2)
COMMIT     순서 : T2    -> T1           <- binlog 기록 순서
```