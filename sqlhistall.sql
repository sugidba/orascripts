accept sql_id    default '' -
prompt 'Please provide the sql_id: '

Set echo off
set trimspool on time on
set define on
set verify off

PROMPT #########################
PROMPT H-Stats
PROMPT #########################

set lines 1000 pages 9999
COL instance_number FOR 9 HEA 'I';
col snap_time for a20
COL end_time HEA 'End Time';
COL PHV  for 9999999999
COL ela for 999999999999
COL fet for 9999999
col sql_id for a15
col sql_profile for a20


SELECT 'HIST' source,h.instance_number,
       TO_CHAR(CAST(s.begin_interval_time AS DATE), 'YYYY-MM-DD HH24:MI:SS') snap_time,
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
       TO_CHAR(LAST_ACTIVE_TIME, 'YYYY-MM-DD HH24:MI:SS') end_time,
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


PROMPT #########################
PROMPT H-ASH
PROMPT #########################

col SQL_END_TIME for a23
col ch for 99
col exec_id for 999999999
col PHV for 999999999999
col FORCE_MATCHING_SIGNATURE for 99999999999999999999
SELECT SQL_ID,sql_exec_id exec_id,sql_child_number ch,
TO_CHAR(SQL_EXEC_START,'YYYY-MM-DD HH24:MI:SS') SQL_START_TIME,
TO_CHAR(MAX(sample_time),'YYYY-MM-DD HH24:MI:SS') SQL_END_TIME,
                 SQL_PLAN_HASH_VALUE PHV,FORCE_MATCHING_SIGNATURE,
-- Convert interval to seconds, then to HH24:MI:SS
       TO_CHAR(TRUNC(EXTRACT(HOUR FROM max(sample_time - sql_exec_start)), 0), 'FM09') || ':' ||
       TO_CHAR(TRUNC(EXTRACT(MINUTE FROM max(sample_time - sql_exec_start)), 0), 'FM09') || ':' ||
       TO_CHAR(TRUNC(EXTRACT(SECOND FROM max(sample_time - sql_exec_start)), 0), 'FM09')
         AS run_time,
--         ROUND (SUM (delta_read_io_bytes) / 1024 / 1024 / 1024, 2)              PHY_READ_GB,
--         ROUND (SUM (delta_interconnect_io_bytes) / 1024 / 1024 / 1024, 2)      INTER_IO_GB,
         MAX (TRUNC (px_flags / 2097152))                       ACTUAL_DOP,
         MIN (NULLIF (TRUNC (px_flags / 2097152), 0))             MIN_DOP
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE sql_id = '&sql_id' AND (SQL_EXEC_START IS NOT NULL OR SQL_EXEC_ID IS NOT NULL)
         AND sample_time > sysdate-15
GROUP BY SQL_ID,
         SQL_EXEC_START,
         sql_child_number,
         SQL_PLAN_HASH_VALUE,
                 FORCE_MATCHING_SIGNATURE,
         SQL_EXEC_ID,
         QC_INSTANCE_ID,
         QC_SESSION_ID,
         QC_SESSION_SERIAL#
 ORDER BY SQL_EXEC_START;


PROMPT #########################
PROMPT H-Monitor
PROMPT #########################

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';
col key1 for a20
col PHV for a20
Col ins for 99
col px_rq for a5
col px_al for a5
col status for a15
col time for a10
col SQL_EXEC_ID for a10
col fetch for a10
SELECT
    instance_number ins,
    EXTRACTVALUE(XMLType(report_summary),'/report_repository_summary/sql/status') status,
    report_id,
    EXTRACTVALUE(XMLType(report_summary),'/report_repository_summary/sql/@sql_exec_id') sql_exec_id,
    EXTRACTVALUE(XMLType(report_summary),'/report_repository_summary/sql/px_servers_requested') px_rq,
    EXTRACTVALUE(XMLType(report_summary),'/report_repository_summary/sql/px_servers_allocated') px_al,
    period_start_time,
    period_end_time,
    key1,
    EXTRACTVALUE(XMLType(report_summary), '/report_repository_summary/sql/plan_hash') AS PHV,
    LPAD(EXTRACT(HOUR FROM NUMTODSINTERVAL((period_end_time - period_start_time) * 24 * 60 * 60, 'SECOND')), 2, '0') || ':' ||
    LPAD(EXTRACT(MINUTE FROM NUMTODSINTERVAL((period_end_time - period_start_time) * 24 * 60 * 60, 'SECOND')), 2, '0') || ':' ||
    LPAD(EXTRACT(SECOND FROM NUMTODSINTERVAL((period_end_time - period_start_time) * 24 * 60 * 60, 'SECOND')), 2, '0') AS time,
    EXTRACTVALUE(XMLType(report_summary), '/report_repository_summary/sql/stats/stat[@name="user_fetch_count"]') AS fetch
FROM
    dba_hist_reports
WHERE
    component_name = 'sqlmonitor'
    AND key1 = '&&sql_id'
    AND period_start_time > SYSDATE - 30
ORDER BY 3;

PROMPT #########################
PROMPT  ASH
PROMPT #########################

col SQL_END_TIME for a23
col ch for 99
col exec_id for 999999999
col PHV for 999999999999
col FORCE_MATCHING_SIGNATURE for 99999999999999999999
SELECT SQL_ID,sql_exec_id exec_id,sql_child_number ch,
TO_CHAR(SQL_EXEC_START,'YYYY-MM-DD HH24:MI:SS') SQL_START_TIME,
TO_CHAR(MAX(sample_time),'YYYY-MM-DD HH24:MI:SS') SQL_END_TIME,
                 SQL_PLAN_HASH_VALUE PHV,FORCE_MATCHING_SIGNATURE,
-- Convert interval to seconds, then to HH24:MI:SS
       TO_CHAR(TRUNC(EXTRACT(HOUR FROM max(sample_time - sql_exec_start)), 0), 'FM09') || ':' ||
       TO_CHAR(TRUNC(EXTRACT(MINUTE FROM max(sample_time - sql_exec_start)), 0), 'FM09') || ':' ||
       TO_CHAR(TRUNC(EXTRACT(SECOND FROM max(sample_time - sql_exec_start)), 0), 'FM09')
         AS run_time,
--         ROUND (SUM (delta_read_io_bytes) / 1024 / 1024 / 1024, 2)              PHY_READ_GB,
--         ROUND (SUM (delta_interconnect_io_bytes) / 1024 / 1024 / 1024, 2)      INTER_IO_GB,
         MAX (TRUNC (px_flags / 2097152))                       ACTUAL_DOP,
         MIN (NULLIF (TRUNC (px_flags / 2097152), 0))             MIN_DOP
    FROM gv$ACTIVE_SESSION_HISTORY
   WHERE sql_id = '&&sql_id' AND (SQL_EXEC_START IS NOT NULL OR SQL_EXEC_ID IS NOT NULL)
         AND sample_time > sysdate-1
GROUP BY SQL_ID,
         SQL_EXEC_START,
         sql_child_number,
         SQL_PLAN_HASH_VALUE,
                 FORCE_MATCHING_SIGNATURE,
         SQL_EXEC_ID,
         QC_INSTANCE_ID,
         QC_SESSION_ID,
         QC_SESSION_SERIAL#
 ORDER BY SQL_EXEC_START;

