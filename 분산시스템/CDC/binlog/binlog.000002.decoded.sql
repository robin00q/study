# The proper term is pseudo_replica_mode, but we use this compatibility alias
# to make the statement usable on server versions 8.0.24 and older.
/*!50530 SET @@SESSION.PSEUDO_SLAVE_MODE=1*/;
/*!50003 SET @OLD_COMPLETION_TYPE=@@COMPLETION_TYPE,COMPLETION_TYPE=0*/;
DELIMITER /*!*/;
# at 4
#260622  1:42:53 server id 1  end_log_pos 126 CRC32 0x242228f3 	Start: binlog v 4, server v 8.2.0 created 260622  1:42:53 at startup
# Warning: this binlog is either in use or was not closed properly.
ROLLBACK/*!*/;
# at 126
#260622  1:42:53 server id 1  end_log_pos 157 CRC32 0x9b452c55 	Previous-GTIDs
# [empty]
# at 157
#260622  1:43:23 server id 1  end_log_pos 236 CRC32 0x5d490cd8 	Anonymous_GTID	last_committed=0	sequence_number=1	rbr_only=yes	original_committed_timestamp=1782092603690913	immediate_commit_timestamp=1782092603690913	transaction_length=410
/*!50718 SET TRANSACTION ISOLATION LEVEL READ COMMITTED*//*!*/;
# original_commit_timestamp=1782092603690913 (2026-06-22 01:43:23.690913 UTC)
# immediate_commit_timestamp=1782092603690913 (2026-06-22 01:43:23.690913 UTC)
/*!80001 SET @@session.original_commit_timestamp=1782092603690913*//*!*/;
/*!80014 SET @@session.original_server_version=80200*//*!*/;
/*!80014 SET @@session.immediate_server_version=80200*//*!*/;
SET @@SESSION.GTID_NEXT= 'ANONYMOUS'/*!*/;
# at 236
#260622  1:43:23 server id 1  end_log_pos 327 CRC32 0x1842418a 	Query	thread_id=13	exec_time=0	error_code=0
SET TIMESTAMP=1782092603/*!*/;
SET @@session.pseudo_thread_id=13/*!*/;
SET @@session.foreign_key_checks=1, @@session.sql_auto_is_null=0, @@session.unique_checks=1, @@session.autocommit=1/*!*/;
SET @@session.sql_mode=1168113696/*!*/;
SET @@session.auto_increment_increment=1, @@session.auto_increment_offset=1/*!*/;
/*!\C latin1 *//*!*/;
SET @@session.character_set_client=8,@@session.collation_connection=8,@@session.collation_server=255/*!*/;
SET @@session.lc_time_names=0/*!*/;
SET @@session.collation_database=DEFAULT/*!*/;
/*!80011 SET @@session.default_collation_for_utf8mb4=255*//*!*/;
BEGIN
/*!*/;
# at 327
#260622  1:43:23 server id 1  end_log_pos 401 CRC32 0x8a0fde5b 	Table_map: `inventory`.`customers` mapped to number 116
# has_generated_invisible_primary_key=0
# at 401
#260622  1:43:23 server id 1  end_log_pos 536 CRC32 0x4c38dfb7 	Update_rows: table id 116 flags: STMT_END_F
### UPDATE `inventory`.`customers`
### WHERE
###   @1=1004 /* INT meta=0 nullable=0 is_null=0 */
###   @2='Anne' /* VARSTRING(1020) meta=1020 nullable=0 is_null=0 */
###   @3='Kretchmar' /* VARSTRING(1020) meta=1020 nullable=0 is_null=0 */
###   @4='annek@noanswer.org' /* VARSTRING(1020) meta=1020 nullable=0 is_null=0 */
### SET
###   @1=1004 /* INT meta=0 nullable=0 is_null=0 */
###   @2='ë³€ê²½ë¨' /* VARSTRING(1020) meta=1020 nullable=0 is_null=0 */
###   @3='Kretchmar' /* VARSTRING(1020) meta=1020 nullable=0 is_null=0 */
###   @4='annek@noanswer.org' /* VARSTRING(1020) meta=1020 nullable=0 is_null=0 */
# at 536
#260622  1:43:23 server id 1  end_log_pos 567 CRC32 0xf67783b3 	Xid = 92
COMMIT/*!*/;
SET @@SESSION.GTID_NEXT= 'AUTOMATIC' /* added by mysqlbinlog */ /*!*/;
DELIMITER ;
# End of log file
/*!50003 SET COMPLETION_TYPE=@OLD_COMPLETION_TYPE*/;
/*!50530 SET @@SESSION.PSEUDO_SLAVE_MODE=0*/;
