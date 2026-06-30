# MySQL binlog

---

## binlog 파일 확인

---

```shell
mysql> SHOW BINARY LOGS;
+---------------+-----------+-----------+
| Log_name      | File_size | Encrypted |
+---------------+-----------+-----------+
| binlog.000001 |       180 | No        |
| binlog.000002 |       567 | No        |
+---------------+-----------+-----------+
2 rows in set (0.01 sec)
```

## 최신 활성화된 binlog 확인

---

```shell
mysql> SHOW MASTER STATUS;
+---------------+----------+--------------+------------------+-------------------+
| File          | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+---------------+----------+--------------+------------------+-------------------+
| binlog.000002 |      567 |              |                  |                   |
+---------------+----------+--------------+------------------+-------------------+
```

## BINLOG EVENTS 확인

---

```shell
mysql> SHOW BINLOG EVENTS in 'binlog.000002';
+---------------+-----+----------------+-----------+-------------+--------------------------------------+
| Log_name      | Pos | Event_type     | Server_id | End_log_pos | Info                                 |
+---------------+-----+----------------+-----------+-------------+--------------------------------------+
| binlog.000002 |   4 | Format_desc    |         1 |         126 | Server ver: 8.2.0, Binlog ver: 4     |
| binlog.000002 | 126 | Previous_gtids |         1 |         157 |                                      |
| binlog.000002 | 157 | Anonymous_Gtid |         1 |         236 | SET @@SESSION.GTID_NEXT= 'ANONYMOUS' |
| binlog.000002 | 236 | Query          |         1 |         327 | BEGIN                                |
| binlog.000002 | 327 | Table_map      |         1 |         401 | table_id: 116 (inventory.customers)  |
| binlog.000002 | 401 | Update_rows    |         1 |         536 | table_id: 116 flags: STMT_END_F      |
| binlog.000002 | 536 | Xid            |         1 |         567 | COMMIT /* xid=92 */                  |
+---------------+-----+----------------+-----------+-------------+--------------------------------------+
7 rows in set (0.01 sec)
```

- `Anonymous_Gtid` : `gtid` 가 OFF 상태여서 Anonymous 로 처리되어있다.
- `Query BEGIN` : 트랜잭션 시작
- `Table map` : 이후 행 이벤트가 어느 테이블인지 알도록 테이블명(`inventory.customers`) 을 매핑한다.
- `Update_rows` : 실제 행이 변경되었다. (before/after)
- `Xid COMMIT xid=92` : 커밋이 확정되었다.


