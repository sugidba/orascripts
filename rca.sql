-------------------------------------------------------------------------------------------------------------------------------------
---
---    Root Cause finding for completed sql using sql_id
---
---    Author      Sugi
---
--------------------------------------------------------------------------------------------------------------------------------------

accept sql_id    default '' -
prompt 'Please provide the sql_id: '
accept Starttime  default '' -
prompt 'Please provide the Starttime: '
accept Endtime    default '' -
prompt 'Please provide the Endtime: '


Set echo off
set trimspool on time on
set define on

column filename new_val filename
select to_char(sysdate, 'yyyymmdd-hh-mi-ss' ) filename from dual;
column dbname new_value dbname noprint
select name dbname from v$database;
spool RCA-&dbname-&sql_id-&filename..txt

PROMPT #########################
PROMPT    DB INFO
PROMPT #########################

set lines 750 pages 9999
alter session set nls_date_format='YYYY/MM/DD HH24:MI:SS';
select INSTANCE_NAME,HOST_NAME,logins,VERSION from v$instance;


PROMPT #########################
PROMPT SQLTEXT
PROMPT #########################

set lines 750 pages 9999
set  long 2000000 longchunksize 2000000
select sql_text from  dba_hist_sqltext where SQL_ID='&&sql_id' and rownum < 2;



PROMPT #########################
PROMPT H-Stats
PROMPT #########################

set lines 1000 pages 9999
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

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY/MM/DD HH24:MI:SS';
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
    AND period_start_time > SYSDATE - 15
ORDER BY 3;


PROMPT #########################
PROMPT  PLAN
PROMPT #########################

SELECT * FROM table (DBMS_XPLAN.DISPLAY_AWR(sql_id => '&&sql_id',format=>'ADVANCED -QBREGISTRY -PROJECTION'));

PROMPT #########################
PROMPT  BINDS
PROMPT #########################

col value 80
SELECT 'VARIABLE ' || REPLACE(name, ':') || ' ' || MAX(datatype_string) AS value
FROM dba_hist_sqlbind a, dba_hist_snapshot b
WHERE a.snap_id = b.snap_id
AND a.sql_id = '&&sql_id'
AND b.begin_interval_time BETWEEN TIMESTAMP'&&Starttime' AND TIMESTAMP'&&Endtime'
GROUP BY name
UNION ALL
SELECT 'EXEC ' || name || ' := ''' || MAX(value_string) || ''';' AS value
FROM dba_hist_sqlbind a, dba_hist_snapshot b
WHERE a.snap_id = b.snap_id
AND a.sql_id = '&&sql_id'
AND b.begin_interval_time BETWEEN TIMESTAMP'&&Starttime' AND TIMESTAMP'&&Endtime'
AND value_string IS NOT NULL
GROUP BY name
UNION ALL
SELECT 'EXEC ' || name || ' := ''' || MAX(ANYDATA.AccessTimestamp(value_anydata)) || ''';' AS value
FROM dba_hist_sqlbind a, dba_hist_snapshot b
WHERE a.snap_id = b.snap_id
AND a.sql_id = '&&sql_id'
AND b.begin_interval_time BETWEEN TIMESTAMP'&&Starttime' AND TIMESTAMP'&&Endtime'
AND value_anydata IS NOT NULL
GROUP BY name;

PROMPT #########################
PROMPT  UNDO ?
PROMPT #########################

@dashtop1 current_obj#,subobject_name,objt "sql_id='&&sql_id'" "TIMESTAMP'&&Starttime'" "TIMESTAMP'&&Endtime'"

PROMPT #########################
PROMPT  Wait ?
PROMPT #########################

@dashtop1 event2 "sql_id='&&sql_id'" "TIMESTAMP'&&Starttime'" "TIMESTAMP'&&Endtime'"

PROMPT #########################
PROMPT Line
PROMPT #########################

@dashtop1 SQL_PLAN_LINE_ID,SQL_PLAN_OPERATION,SQL_PLAN_OPTIONS   "TIMESTAMP'&&Starttime'" "TIMESTAMP'&&Endtime'"

PROMPT #########################
PROMPT i/o Latency
PROMPT #########################

@devent_hist  'cell single block physical read: flash cache' "sql_id='&&sql_id'"  "TIMESTAMP'&&Starttime'" "TIMESTAMP'&&Endtime'"
@devent_hist  'cell single block physical read' "sql_id='&&sql_id'"  "TIMESTAMP'&&Starttime'" "TIMESTAMP'&&Endtime'"

PROMPT #########################
PROMPT Global-Stats
PROMPT #########################

col owner           for a20
col table_name      for a30
col index_name      for a30
col partition_name  for a30
col global_stats    for a3
col object_name     for a30
col object_owner     for a20
col object_type     for a15
col NUM_ROWS for 9999999999999999999999

select distinct object_name,OBJECT_OWNER,GLOBAL_STATS,STALE_STATS,LAST_ANALYZED,NUM_ROWS,BLOCKS  
from dba_hist_sql_plan p,DBA_TAB_STATISTICS t
where
  t.TABLE_NAME=p.object_name 
and  t.owner=p.object_owner
and p.sql_id='&&sql_id'
and p.object_name is not null 
and p.object_type='TABLE'
and t.PARTITION_NAME IS NULL;


select distinct object_name,OBJECT_OWNER,p.object_type,t.table_name,GLOBAL_STATS,STALE_STATS,LAST_ANALYZED,NUM_ROWS  
from dba_hist_sql_plan p,DBA_IND_STATISTICS t
where
  t.INDEX_NAME=p.object_name 
and  t.owner=p.object_owner
and p.sql_id='&&sql_id'
and p.object_name is not null 
and p.object_type like 'INDEX%'
and t.PARTITION_NAME IS NULL;


PROMPT #########################
PROMPT PARTITION-NO-Stats ?
PROMPT #########################

SELECT 
    'exec dbms_stats.gather_table_stats(OWNNAME=>''' || TABLE_OWNER || ''', TABNAME=>''' || table_name || ''', PARTNAME=>''' || o.subobject_name || ''', DEGREE=>8, GRANULARITY=>''PARTITION'', CASCADE=>TRUE, ESTIMATE_PERCENT=>1, no_invalidate=>TRUE);' AS gather_stats_cmd
FROM 
    dba_objects o
    JOIN DBA_TAB_PARTITIONS p ON o.subobject_name = p.PARTITION_NAME
WHERE   
    o.created > sysdate - 10
    AND o.object_name IN (select distinct object_name from dba_hist_sql_plan where sql_id = '&&sql_id' and object_name is not null and object_type='TABLE')
    AND p.last_analyzed IS NULL
ORDER BY 
    o.created;
	
PROMPT #########################
PROMPT PARTITION-Stale-Stats ?
PROMPT #########################

SELECT
    'exec dbms_stats.gather_table_stats(OWNNAME=>''' || o.OWNER || ''', TABNAME=>''' || table_name || ''', PARTNAME=>''' || o.subobject_name || ''', DEGREE=>8, GRANULARITY=>''PARTITION'', CASCADE=>TRUE, ESTIMATE_PERCENT=>DBMS_STATS.AUTO_SAMPLE_SIZE, no_invalidate=>TRUE);' AS gather_stats_cmd
FROM
    dba_objects o
    JOIN dba_tab_statistics p ON o.subobject_name = p.PARTITION_NAME
WHERE
    o.object_name IN (select distinct object_name from dba_hist_sql_plan where sql_id = '&&sql_id' and object_name is not null and object_type='TABLE')
    AND STALE_STATS !='NO'
ORDER BY
    o.created;





PROMPT #########################
PROMPT     ASH
PROMPT #########################

col SQL_END_TIME for a23
col ch for 99
col exec_id for 999999999
col PHV for 999999999999
col FORCE_MATCHING_SIGNATURE for 99999999999999999999
SELECT SQL_ID,sql_exec_id exec_id,sql_child_number ch,
         SQL_EXEC_START,
--         MIN (sample_time) SQL_START_TIME,
         MAX (sample_time)
             SQL_END_TIME,
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

col sample_time for a26
col TOP_LEVEL_CALL_NAME for a10
col SQL_PLAN_LINE_ID for 999
col SQL_PLAN_OPTIONS for a30
select sample_time,top_level_sql_id,event,top_level_call_name,sql_plan_line_id,sql_plan_options
from gv$active_session_history 
where sql_id='&&sql_id' 
order by sample_time desc 
fetch first 5 rows only;

PROMPT #########################
PROMPT Alertlog
PROMPT #########################

col host_id for a12	
col MESSAGE_TEXT format A100
SELECT
    TO_CHAR(originating_timestamp,'DD.MM.YYYY HH24:MI:SS') date_and_time,
    SUBSTR(host_id, 1, 11) AS host_id,
    message_text
FROM
    TABLE ( gv$(CURSOR(
        SELECT originating_timestamp,host_id, message_text   FROM   V$DIAG_ALERT_EXT x
        WHERE
            x.component_id = 'rdbms'
                        AND   originating_timestamp  between timestamp'&&Starttime' and timestamp'&&Endtime'
                       AND   (message_text LIKE '%ORA-%' OR lower(message_text) LIKE '%parse%' OR lower(message_text) LIKE '%failure%' OR   lower(message_text) LIKE '%error%' ) 
    ) ) ) ORDER BY    originating_timestamp ASC;


PROMPT #########################
PROMPT  REPORT
PROMPT #########################

set long 10000000
set longchunksize 10000000
set linesize 1000
set pagesize 0
set trim on
set trimspool on
set echo off
set feedback off

select dbms_auto_report.report_repository_detail(rid=>r.report_id,type=>'TEXT') report
from dba_hist_reports r
where r.component_name='sqlmonitor'
and r.key1='&&sql_id'
and r.period_start_time between timestamp'&&Starttime' and timestamp'&&Endtime'
order by r.report_id;


PROMPT #########################
PROMPT  TOPCPU
PROMPT #########################


set feedback off echo off tab off trimout on trimspool on linesize 250 pagesize 1000 verify off
BREAK ON instance_number SKIP 1
    col instance_number for 99 head 'I'
    col machine for a9 word_wrapped
    col PARSING_SCHEMA_NAME for a25 head PARSING_SCHEMA_NAME trunc
    col AVG_SECS_PER_EXEC  for 99,999.99 heading 'Avg Secs|Per Exec'
    col CPU_PCT for 999.9 heading 'CPU PCT'
    col IO_PCT for 999.9 heading 'IO PCT'
    col EXECUTIONS for 999,999,999 heading 'Total Execs|Per SQL_ID'
    col OSUSER for a9 word_wrapped
    col TXT for a30 word_wrapped  heading 'TXT'
    col SQL for a90 heading SQL trunc
    col sess for a12 heading 'Active|SID:SERIAL#' justify center
    col username for a20
    col QC_SID for a10 heading 'PQ|SID:SERIAL#' justify center

WITH cpu_data AS (
    SELECT
        instance_number,
        sql_id,
        SUM(DECODE(session_state, 'ON CPU', 1, 0)) AS CPU,
                user_id
    FROM
        dba_hist_active_sess_history
    WHERE
        session_state = 'ON CPU'
        AND sample_time BETWEEN timestamp'&&Starttime' and timestamp'&&Endtime'
        AND sql_id IS NOT NULL
                AND session_type='FOREGROUND'
    GROUP BY
        instance_number, sql_id,user_id
),
cpu_pct_data AS (
    SELECT
        instance_number,
        sql_id,
        ROUND(RATIO_TO_REPORT(CPU) OVER (PARTITION BY instance_number) * 100, 2) AS cpu_pct,
        ROW_NUMBER() OVER (PARTITION BY instance_number ORDER BY CPU DESC) AS rn,
                user_id
    FROM
        cpu_data
)
SELECT DISTINCT
    ash.instance_number,
    ash.sql_id,
    ash.cpu_pct,
    d.username,
        --REPLACE(REPLACE(SUBSTR(cc.sql_text, 1, 100), CHR(10), ' '), CHR(13), ' ') AS SQL
          REPLACE(REPLACE(DBMS_LOB.SUBSTR(cc.sql_text, 80, 1), CHR(10), ' '), CHR(13), ' ') AS SQL
        --DBMS_LOB.SUBSTR(cc.sql_text, 100, 1) AS sql_text
FROM
    cpu_pct_data ash
LEFT JOIN
    dba_hist_sqltext cc ON ash.sql_id = cc.sql_id
LEFT JOIN
    dba_users d ON ash.user_id = d.user_id
WHERE
    ash.rn <= 10
ORDER BY
    ash.instance_number DESC, ash.cpu_pct DESC;


PROMPT #########################
PROMPT  TOPIO
PROMPT #########################


set feedback off echo off tab off trimout on trimspool on linesize 250 pagesize 1000 verify off
BREAK ON instance_number SKIP 1
    col instance_number for 99 head 'I'
    col machine for a9 word_wrapped
    col PARSING_SCHEMA_NAME for a25 head PARSING_SCHEMA_NAME trunc
    col AVG_SECS_PER_EXEC  for 99,999.99 heading 'Avg Secs|Per Exec'
    col CPU_PCT for 999.9 heading 'CPU PCT'
    col IO_PCT for 999.9 heading 'IO PCT'
    col EXECUTIONS for 999,999,999 heading 'Total Execs|Per SQL_ID'
    col OSUSER for a9 word_wrapped
    col TXT for a30 word_wrapped  heading 'TXT'
    col SQL for a90 heading SQL trunc
    col sess for a12 heading 'Active|SID:SERIAL#' justify center
    col username for a25
    col QC_SID for a10 heading 'PQ|SID:SERIAL#' justify center

WITH io_data AS (
    SELECT
        ash.instance_number,
        ash.sql_id,
        SUM(DECODE(ash.session_state, 'WAITING', DECODE(en.wait_class, 'User I/O', 1, 0), 0)) AS IO,
                ash.user_id
    FROM
        dba_hist_active_sess_history ash
    JOIN
        gv$event_name en ON en.wait_class = ash.wait_class
    WHERE
        ash.sql_id IS NOT NULL
        AND sample_time BETWEEN  timestamp'&&Starttime' and timestamp'&&Endtime'
        AND sql_id IS NOT NULL
                AND session_type='FOREGROUND'
    GROUP BY
        ash.instance_number,
        ash.sql_id,ash.user_id
                order by 3 desc
),
io_pct_data AS (
    SELECT
        instance_number,
        sql_id,
        ROUND(RATIO_TO_REPORT(IO) OVER (PARTITION BY instance_number) * 100, 2) AS io_pct,
        ROW_NUMBER() OVER (PARTITION BY instance_number ORDER BY IO DESC) AS rn,
                user_id
    FROM
        io_data
)
SELECT DISTINCT
    ash.instance_number,
    ash.sql_id,
    ash.io_pct,
        d.username,
        --REPLACE(REPLACE(SUBSTR(cc.sql_text, 1, 100), CHR(10), ' '), CHR(13), ' ') AS SQL
          REPLACE(REPLACE(DBMS_LOB.SUBSTR(cc.sql_text, 80, 1), CHR(10), ' '), CHR(13), ' ') AS SQL
        --DBMS_LOB.SUBSTR(cc.sql_text, 100, 1) AS sql_text
FROM
    io_pct_data ash
LEFT JOIN
    gv$sqlarea cc ON ash.sql_id = cc.sql_id
LEFT JOIN
    dba_users d ON ash.user_id = d.user_id
WHERE
    ash.rn <= 10
ORDER BY
    ash.instance_number DESC, ash.io_pct DESC;

spool off;

