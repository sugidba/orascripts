-------------------------------------------------------------------------------------------------------------------------------------
---
---    Quick Check for a sql id running Currently
---
---    Author      Sugi
---
--------------------------------------------------------------------------------------------------------------------------------------

accept sql_id  prompt 'Please provide the sql_id: '

Set echo off
set trimspool on time on
set define on

column filename new_val filename
select to_char(sysdate, 'yyyymmdd-hh-mi-ss' ) filename from dual;
column dbname new_value dbname noprint
select name dbname from v$database;
spool &LOG_DIR\&dbname-&sql_id-&filename..txt

PROMPT ##################
PROMPT Active
PROMPT ##################

set lines 750 pages 9999
set verify off
alter session set nls_date_format='YYYY/MM/DD HH24:MI:SS';
col HOST_NAME for a30
select INSTANCE_NAME,HOST_NAME,(select systimestamp from dual)currenttime,VERSION from v$instance;

column sid format 9999
column serial for 999999
column I for 9
col px for 99
col p_rq for 99999
col p_al for 99999
column status format a15
column username format a25
column sql_text format a40
column module format a30
col program for a30
col SQL_EXEC_START for a20

       SELECT inst_id I,sid,SESSION_SERIAL# as Serial,username,sql_id,SQL_PLAN_HASH_VALUE PHV,px_maxdop px,
           px_servers_requested p_rq,
      px_servers_allocated p_al,
         TO_CHAR(sql_exec_start,'dd-mon-yyyy hh24:mi:ss') AS sql_exec_start,
         ROUND(elapsed_time/1000000)                      AS "Ela(s)",
--         ROUND(cpu_time    /1000000)                      AS "CPU (s)",
         substr(sql_text,1,30) sql_text
       FROM gv$sql_monitor where status='EXECUTING'
       AND username is not null
       ORDER BY username;



PROMPT ##################
PROMPT Blocker
PROMPT ##################
col sid for 9999
col event for a30
col blocker for a10
select inst_id,sid,serial#,username,sql_id,event,module,BLOCKING_INSTANCE ||','|| blocking_session blocker from gv$session
where blocking_session is not null order by logon_time desc ;

PROMPT ##################
PROMPT PX
PROMPT ##################

PROMPT --Available px slaves
SELECT inst_id,
       SUM(CASE WHEN status = 'IN USE' THEN 1 ELSE 0 END) used,
       SUM(CASE WHEN status = 'AVAILABLE' THEN 1 ELSE 0 END) free,
       COUNT(*) total
FROM gv$px_process
GROUP BY inst_id order by 1;

PROMPT --px split
set lines 1000 pages 9999
COL px_qcsid HEAD QC_SID FOR A13
COL px_instances FOR A100
COL px_username HEAD USERNAME FOR A25 WRAP

SELECT
    pxs.qcsid||','||pxs.qcserial# px_qcsid
  , pxs.qcinst_id
  , ses.username px_username
  , ses.sql_id
  , pxs.degree
  , pxs.req_degree
  , COUNT(*) slaves
  , COUNT(DISTINCT pxs.inst_id) inst_cnt
  , MIN(pxs.inst_id) min_inst
  , MAX(pxs.inst_id) max_inst
  --, LISTAGG ( TO_CHAR(pxs.inst_id) , ' ' ) WITHIN GROUP (ORDER BY pxs.inst_id) px_instances
FROM
    gv$px_session pxs
  , gv$session    ses
  , gv$px_process p
WHERE
    ses.sid     = pxs.sid
AND ses.serial# = pxs.serial#
AND p.sid       = pxs.sid
AND pxs.inst_id = ses.inst_id
AND ses.inst_id = p.inst_id
--
AND pxs.req_degree IS NOT NULL -- qc
GROUP BY
    pxs.qcsid||','||pxs.qcserial#
  , pxs.qcinst_id
  , ses.username
  , ses.sql_id
  , pxs.degree
  , pxs.req_degree
ORDER BY
 px_qcsid
, slaves DESC
/


PROMPT --px event

col username for a15
col "QC SID" for A6
col "SID" for A6
col SPID for A7
col "QC/Slave" for A8
col "Req. DOP" for 9999
col "Actual DOP" for 9999
col "Slaveset" for A8
col "Slave INST" for A9
col "QC INST" for A6
col sql_id for a20
col ch for 99
set pages 9999 lines 300
col wait_event format a30
col blocker format a10
alter session set nls_date_format='YYYY/MM/DD HH24:MI:SS';
select
decode(px.qcinst_id,NULL,username,
' – '||lower(substr(pp.SERVER_NAME,
length(pp.SERVER_NAME)-4,4) ) )"username",
decode(px.qcinst_id,NULL, 'QC', '(Slave)') "QC/Slave" ,
to_char(s.sid) "SID",
sql_child_number ch,
pp.spid,
to_char(px.inst_id) "Slave INST",
decode(sw.state,'WAITING', 'WAIT', 'NOT WAIT' ) as STATE,
s.sql_id,
--case  sw.state WHEN 'WAITING' THEN substr(sw.event,1,30) ELSE NULL end as wait_event ,
s.event as wait_event ,
BLOCKING_INSTANCE ||','|| blocking_session blocker,
s.SECONDS_IN_WAIT wait_s,
s.last_call_et
from gv$px_session px,
gv$session s ,
gv$px_process pp,
gv$session_wait sw
where px.sid=s.sid (+)
and px.serial#=s.serial#(+)
and px.inst_id = s.inst_id(+)
and px.sid = pp.sid (+)
and px.serial#=pp.serial#(+)
and sw.sid = s.sid
and sw.inst_id = s.inst_id
order by
--decode(px.QCINST_ID,  NULL, px.INST_ID,  px.QCINST_ID),
px.QCSID,
decode(px.SERVER_GROUP, NULL, 0, px.SERVER_GROUP),
px.INST_ID;



PROMPT ##################
PROMPT Px-Time
PROMPT ##################

BREAK ON inst_id SKIP 1 ON sid SKIP 1
COLUMN value_pct FORMAT  999.9 HEADING "VALUE %"
col sid for 99999
SELECT
    stm.inst_id,
    stm.sid,
    stm.stat_name,
    stm.value,
    ROUND(
        100 * stm.value /
        NULLIF(SUM(stm.value) OVER (PARTITION BY stm.inst_id, stm.sid), 0),
        2
    ) AS value_pct
FROM gv$sess_time_model stm
JOIN gv$session s
  ON stm.sid = s.sid
 AND stm.inst_id = s.inst_id
WHERE
s.sql_id='&&sql_id'
--s.username = 'username'
  AND stm.value != 0
ORDER BY
    stm.inst_id ASC,
    stm.sid ASC,
    stm.value DESC;
clear breaks;

PROMPT ##################
PROMPT Px-Event
PROMPT ##################

BREAK ON inst_id SKIP 1 ON sid SKIP 1
COLUMN wait_pct FORMAT 999.9 HEADING "WAIT %"
COLUMN wait_seconds FORMAT 999999999.99 HEADING "WAIT SEC"
COLUMN avg_wait_ms FORMAT 999999.99 HEADING "AVG WAIT MS"
COLUMN event FORMAT A40
COLUMN wait_class FORMAT A15
COL sid FOR 99999
SELECT se.inst_id,se.sid,se.event,se.wait_class,se.total_waits,ROUND(se.time_waited_micro/1000000,2) wait_seconds,ROUND(se.time_waited_micro/NULLIF(se.total_waits,0)/1000,2) avg_wait_ms,ROUND(100*se.time_waited_micro/NULLIF(SUM(se.time_waited_micro) OVER(PARTITION BY se.inst_id,se.sid),0),2) wait_pct
FROM gv$session_event se
JOIN gv$session s
ON s.inst_id=se.inst_id
AND s.sid=se.sid
WHERE s.sql_id='&&sql_id'
AND se.wait_class<>'Idle'
---AND se.time_waited_micro>1000000
ORDER BY se.inst_id,se.sid,se.time_waited_micro DESC;
CLEAR BREAKS;

PROMPT ##################
PROMPT  Shared
PROMPT ##################

@nonshared &&sql_id

PROMPT ##################
PROMPT  PLAN
PROMPT ##################

set lines 750 pages 9999
SELECT * FROM TABLE(gv$(CURSOR(SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&&sql_id', null,'ADVANCED -PREDICATE -PROJECTION -ALIAS -OUTLINE -qbregistry')))));

PROMPT ##################
PROMPT  BINDS
PROMPT ##################

col name for a30
col DATATYPE_STRING for a30
col value_string for a30
col value_anydata for a30
--SELECT b.NAME,  b.datatype_string, b.value_string,ANYDATA.accesstimestamp (value_anydata) value_anydata FROM gv$sql_bind_capture b WHERE sql_id = '&&sql_id';

SELECT
 'VARIABLE ' ||
 REPLACE(name,':') || ' ' ||
 datatype_string
FROM gv$sql_bind_capture
WHERE sql_id = '&&sql_id'
UNION ALL
SELECT
 'EXEC ' ||
 name ||
 ' := ''' ||
 value_string ||
 ''';'
FROM gv$sql_bind_capture
WHERE sql_id = '&&sql_id';

PROMPT ##################
PROMPT OBJ
PROMPT ##################

@ashtop1 current_obj#,subobject_name,objt,CURRENT_FILE# "sql_id='&&sql_id'" sysdate-1/24/12 sysdate

PROMPT -- OTHERS ACCESS SAME OBJECTS

@ashtop1 sql_id,username,SQL_OPNAME,object_name "object_name in (select distinct object_name from gv$sql_plan  where sql_id='&&sql_id' and object_name is not null and object_type='TABLE')  and sql_opname not like 'SELECT'" sysdate-1/24 sysdate

PROMPT ##################
PROMPT WAITS
PROMPT ##################

@ashtop1 event2 "sql_id='&&sql_id'" sysdate-1/24/12 sysdate

PROMPT ##################
PROMPT LINE
PROMPT ##################

@ashtop1 SQL_PLAN_LINE_ID,SQL_PLAN_OPERATION,SQL_PLAN_OPTIONS   "sql_id='&&sql_id'" sysdate-1/24/12 sysdate

PROMPT ##################
PROMPT Latency
PROMPT ##################

@event_hist  'db file scattered read' "sql_id='&&sql_id'"  sysdate-1/24 sysdate
@event_hist  'db file sequential read' "sql_id='&&sql_id'"  sysdate-1/24 sysdate


PROMPT ##################
PROMPT History
PROMPT ##################

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
order by snap_time desc;


PROMPT ##################
PROMPT ASH
PROMPT ##################

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

PROMPT --Recent Samples
col sample_time for a26
col TOP_LEVEL_CALL_NAME for a10
col SQL_PLAN_LINE_ID for 999
col SQL_PLAN_OPTIONS for a30
select sample_time,top_level_sql_id,event,top_level_call_name,sql_plan_line_id,sql_plan_options
from gv$active_session_history 
where sql_id='&&sql_id' 
order by sample_time desc 
fetch first 5 rows only;

PROMPT ##################
PROMPT Alertlog
PROMPT ##################

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
                        AND   originating_timestamp  >  sysdate-1/24
                       AND   (message_text LIKE '%ORA-%' OR lower(message_text) LIKE '%parse%' OR lower(message_text) LIKE '%failure%' OR   lower(message_text) LIKE '%error%' ) 
    ) ) ) ORDER BY    originating_timestamp ASC;


PROMPT ##################
PROMPT SQL
PROMPT ##################

PROMPT --Session
SET LINES 1000 PAGES 9999
COL sid FOR a12
col event for a30
col module for a30
col machine for a30
SELECT
    inst_id
    || ','
    || sid
    || ','
    || serial# sid,event,sql_id,sql_exec_start,module,machine,blocking_session from gv$session
where sql_id = nvl('&&sql_id', sql_id)
   and prev_sql_id is not null
   order by SQL_EXEC_START desc ;

PROMPT --sql
col BS for a2
col BA for a2
col opt for a3
col ada for a3
select sql_id,child_number,executions,rows_processed,program_line#,is_bind_sensitive BS,is_bind_aware BA,is_reoptimizable opt,is_resolved_adaptive_plan ada,object_status,invalidations,parse_calls
from gv$sql
where sql_id='&&sql_id';

PROMPT --Profile
COL phprof FOR a15
COL sid FOR a12
COL txt FOR a30
COL s FOR a2
COL ch FOR 99
COL force_matching_signature for  999999999999999999999
set verify off

SELECT
    u.inst_id
    || ','
    || sid
    || ','
    || serial# sid,
    substr(status, 1, 2) s,
    s.sql_id       id,
    child_number   ch,
    lpad(plan_hash_value, 10, ' ')
    || ' '
    ||
        CASE
            WHEN sql_profile IS NOT NULL THEN
                sql_profile
            WHEN sql_plan_baseline IS NOT NULL THEN
                sql_plan_baseline
            WHEN sql_patch IS NOT NULL THEN
                sql_patch
            ELSE
                ' '
        END
    phprof,
    force_matching_signature,
    round(elapsed_time / 1000000) ela,
    round(cpu_time / 1000000) cpu,
    round(user_io_wait_time / 1000000) io,
    substr(sql_text, 1, 30) txt
FROM
    gv$sql       s,
    gv$session   u
WHERE
    s.sql_id = u.sql_id
    AND s.sql_id = nvl('&&sql_id', s.sql_id)
    AND s.inst_id = u.inst_id
--sid=5047
--and u.inst_id=6
    AND s.address = u.sql_address
    AND last_active_time > SYSDATE - 1
    AND program NOT LIKE 'oracle%'
ORDER BY
    child_number;

PROMPT #########################
PROMPT SQLTEXT
PROMPT #########################

set lines 750 pages 9999
set  long 2000000 longchunksize 2000000
select sql_fulltext from gv$sql where SQL_ID='&&sql_id' and rownum < 2;


PROMPT ##################
PROMPT PROGRESS
PROMPT ##################

PROMPT --Time Remaining
col OPNAME for a20
col SID form 9999
col SERIAL form 9999999
col PROGRAM for a10
col USERNAME for a20
col MESSAGE for a25

SELECT inst_id,sid, serial#, sql_id, opname, username, sofar, totalwork,round(time_remaining/60,2) "REMAIN MINS", round(elapsed_seconds/60,2) "ELAPSED MINS", round((time_remaining+elapsed_seconds)/60,2) "TOTAL MINS", ROUND(SOFAR/TOTALWORK*100,2) "%_COMPLETE"
FROM gv$session_longops
WHERE 
--OPNAME NOT LIKE 'RMAN%' AND OPNAME NOT LIKE '%aggregate%'
sql_id='&&sql_id'
 AND TOTALWORK != 0 AND sofar<>totalwork AND time_remaining > 0;

PROMPT --I/O Movement
SET LINES 1000 PAGES 9999
COL sid FOR a12
COL id FOR a15
COL w_sec FOR 99999
COL ch FOR 99
COL event FOR a32
COL ex FOR 999999
COL s_cn FORMAT a07

SELECT
    u.inst_id
    || ','
    || sid
    || ','
    || serial# sid,
    s.sql_id          id,
    child_number      ch,
    event,
    seconds_in_wait   w_sec,
    ( SYSDATE - last_active_time ) * 86400 last,
    DECODE(executions, 0, 1, executions) ex,
    fetches           ft,
    rows_processed    rowp,
    buffer_gets       bufg,
    disk_reads        diskr,
    direct_writes     diskw,
    sorts             sort
FROM
    gv$sql       s,
    gv$session   u
WHERE
    s.sql_id = u.sql_id
    AND s.sql_id = nvl('&&sql_id', s.sql_id)
    AND s.inst_id = u.inst_id
    AND s.address = u.sql_address
--    AND last_active_time > SYSDATE - 1
    AND program NOT LIKE 'oracle%'
ORDER BY
    child_number;

PROMPT ##################
PROMPT STATS
PROMPT ##################

PROMPT --Global-Stats
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
from gv$sql_plan p,DBA_TAB_STATISTICS t
where
  t.TABLE_NAME=p.object_name 
and  t.owner=p.object_owner
and p.sql_id='&&sql_id'
and p.object_name is not null 
and p.object_type='TABLE'
and t.PARTITION_NAME IS NULL;


select distinct object_name,OBJECT_OWNER,p.object_type,t.table_name,GLOBAL_STATS,STALE_STATS,LAST_ANALYZED,NUM_ROWS  
from gv$sql_plan p,DBA_IND_STATISTICS t
where
  t.INDEX_NAME=p.object_name 
and  t.owner=p.object_owner
and p.sql_id='&&sql_id'
and p.object_name is not null 
and p.object_type like 'INDEX%'
and t.PARTITION_NAME IS NULL;


PROMPT --PARTITION-NO-Stats
SELECT 
    'exec dbms_stats.gather_table_stats(OWNNAME=>''' || TABLE_OWNER || ''', TABNAME=>''' || table_name || ''', PARTNAME=>''' || o.subobject_name || ''', DEGREE=>8, GRANULARITY=>''PARTITION'', CASCADE=>TRUE, ESTIMATE_PERCENT=>1, no_invalidate=>TRUE);' AS gather_stats_cmd
FROM 
    dba_objects o
    JOIN DBA_TAB_PARTITIONS p ON o.subobject_name = p.PARTITION_NAME
WHERE   
    o.created > sysdate - 10
    AND o.object_name IN (select distinct object_name from gv$sql_plan where sql_id = '&&sql_id' and object_name is not null and object_type='TABLE')
    AND p.last_analyzed IS NULL
ORDER BY 
    o.created;
        
PROMPT --PARTITION-Stale

SELECT
    'exec dbms_stats.gather_table_stats(OWNNAME=>''' || o.OWNER || ''', TABNAME=>''' || table_name || ''', PARTNAME=>''' || o.subobject_name || ''', DEGREE=>8, GRANULARITY=>''PARTITION'', CASCADE=>TRUE, ESTIMATE_PERCENT=>DBMS_STATS.AUTO_SAMPLE_SIZE, no_invalidate=>TRUE);' AS gather_stats_cmd
FROM
    dba_objects o
    JOIN dba_tab_statistics p ON o.subobject_name = p.PARTITION_NAME
WHERE
    o.object_name IN (select distinct object_name from gv$sql_plan where sql_id = '&&sql_id' and object_name is not null and object_type='TABLE')
    AND STALE_STATS !='NO'
ORDER BY
    o.created;

PROMPT ##################
PROMPT SPEED
PROMPT ##################

SELECT /*+ PARALLEL(2) */
      TO_CHAR(sample_time,'HH24:MI') sample_minute,
       ROUND(SUM(delta_read_io_bytes)/1024/1024,2) read_mb,
           ROUND(SUM(delta_WRITE_io_bytes)/1024/1024,2) write_mb,
       SUM(delta_read_io_requests) read_ios,
           SUM(delta_write_io_requests) write_ios
FROM gv$active_session_history
WHERE sql_id='&&sql_id'
AND sample_time BETWEEN sysdate-1
                    AND sysdate
GROUP BY TO_CHAR(sample_time,'HH24:MI')
ORDER BY 1;

PROMPT ##################
PROMPT SQLMON-REPORT
PROMPT ##################

PROMPT --DOP REASON
set lines 1000 pages 9999
select SID,sql_id,sql_exec_id, sql_exec_start,otherstat_2_value,
case otherstat_2_value
when 352 then 'DOP downgrade due to adaptive DOP'
when 353 then 'DOP downgrade due to resource manager max DOP'
when 354 then 'DOP downgrade due to insufficient number of processes'
when 355 then 'DOP downgrade because workers failed to join'
end reason_for_downgrade 
from GV$SQL_PLAN_MONITOR where sql_id = '&&sql_id'
and otherstat_2_value in (350,351,352,353,354,355);
 
PROMPT --TEXT REPORT
set pagesize 0 echo off timing off linesize 1000 trimspool on trim on long 2000000 longchunksize 2000000
alter session set  "_parallel_syspls_obey_force" = FALSE ;
select
DBMS_SQL_MONITOR.REPORT_SQL_MONITOR(
   sql_id=>'&&sql_id',
   report_level=>'ALL',
   type=>'TEXT')
from dual;

 


 
spool off;