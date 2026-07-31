set lines 1000 pages 9999
undef sql_id
COL instance_number FOR 9 HEA 'I';
col snap_time for a17
COL end_time HEA 'End Time';
COL PHV  for 9999999999
COL ela for 999999999999
COL fet for 9999999
col sql_id for a15
col sql_profile for a20


SELECT 'HIST' source,h.instance_number,
       TO_CHAR(CAST(s.begin_interval_time AS DATE), 'YYYY-MM-DD HH24:MI') snap_time,
       h.sql_id,
       h.plan_hash_value PHV,
	   PX_SERVERS_EXECS_DELTA px,
       h.executions_delta ex,
       h.rows_processed_delta rowp, 
       h.fetches_delta fet,     
       h.elapsed_time_delta ela,
	   DISK_READS_DELTA  pio,
	   BUFFER_GETS_DELTA lio,
       h.sql_profile
FROM dba_hist_sqlstat h,dba_hist_snapshot s
WHERE h.sql_id = '&&sql_id'
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
-- AND h.executions_delta > 0
-- AND TO_CHAR(CAST(s.begin_interval_time AS DATE), 'HH24') in ('10','11')
   AND s.instance_number = h.instance_number
UNION ALL
SELECT 'MEMORY' source,h.inst_id,
       TO_CHAR(LAST_ACTIVE_TIME, 'YYYY-MM-DD HH24:MI') end_time,
       h.sql_id,
       h.plan_hash_value PHV,
	   PX_SERVERS_EXECUTIONS,
       h.executions,
       h.rows_processed,
       h.fetches, 
       h.elapsed_time, 
       h.disk_reads,
       h.buffer_gets,	   
       h.sql_profile
--  FROM gv$sqlarea_plan_hash h 
   FROM gv$sql h
 WHERE h.sql_id = '&&sql_id'
-- AND h.executions > 0
order by source,snap_time;
