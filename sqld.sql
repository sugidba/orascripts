------------------------------------------------------------------------------------------------------------------------------------------------------
---   
---   one script to Identify all performace issue related to sql query
---
---    Author      Sugi
---      
--
--      
------------------------------------------------------------------------------------------------------------------------------------------------------

Set echo off
set trimspool on
set define on

column filename new_val filename  
select to_char(sysdate, 'yyyymmdd-hh-mi-ss' ) filename from dual;  
column dbname new_value dbname noprint
select name dbname from v$pdbs;
spool &dbname-&filename..txt

PROMPT ==================
PROMPT    DB INFO
PROMPT ==================

set lines 750 pages 9999
select name CDB_NAME,(select name from v$pdbs) PDB_NAME,database_role from v$database;
select INSTANCE_NAME,HOST_NAME,logins,VERSION from v$instance;

PROMPT ==================
PROMPT TOTAL Connections
PROMPT ==================

set lines 750 pages 9999
break on report
compute SUM of tot on report
compute SUM of active on report
compute SUM of inactive on report
col username for a50
select DECODE(username,NULL,'INTERNAL',USERNAME) Username,
       count(*) TOT,
       COUNT(DECODE(status,'ACTIVE',STATUS)) ACTIVE,
       COUNT(DECODE(status,'INACTIVE',STATUS)) INACTIVE
from gv$session
where status in ('ACTIVE','INACTIVE')
group by username;

PROMPT ================
PROMPT Blocking Session
PROMPT ================ 
   
 set lines 750 pages 9999
col blocking_status for a100 
 select s1.inst_id,s2.inst_id,s1.username || '@' || s1.sql_id || ' ( SID=' || s1.sid || ' )  is blocking '
 || s2.username || '@' || s2.sql_id || ' ( SID=' || s2.sid || ' ) ' AS blocking_status , round(s2.seconds_in_wait/60)||' mins' Blocking_mins
  from gv$lock l1, gv$session s1, gv$lock l2, gv$session s2
  where s1.sid=l1.sid and s2.sid=l2.sid and s1.inst_id=l1.inst_id and s2.inst_id=l2.inst_id
  and l1.BLOCK=1 and l2.request > 0
  and l1.id1 = l2.id1
  and l2.id2 = l2.id2
order by s1.inst_id;

     
PROMPT =========================
PROMPT Sql Monitor - Executing
PROMPT =========================


  set lines 1000 pages 9999 
column sid format 9999 
column serial for 999999
column I for 9
column status format a15
column username format a30 
column sql_text format a80
column module format a30
col program for a30
col SQL_EXEC_START for a20

SELECT inst_id I,sid,SESSION_SERIAL# as Serial,username,sql_id,SQL_PLAN_HASH_VALUE,
         TO_CHAR(sql_exec_start,'dd-mon-yyyy hh24:mi:ss') AS sql_exec_start,
         ROUND(elapsed_time/1000000)                      AS "Elapsed (s)",
         substr(sql_text,1,30) sql_text
       FROM gv$sql_monitor where status='EXECUTING'
       ORDER BY elapsed_time;
    
    
    
PROMPT =========================
PROMPT Parallel Sessions
PROMPT =========================

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
    pxs.qcinst_id
  , slaves DESC
/
    
PROMPT ================================================================================================================================
PROMPT More Details
PROMPT ================================================================================================================================    
    
accept sid    default '' -
  prompt 'Please provide the sid: '
    
accept inst_id    default '' -
  prompt 'Please provide the inst_id: '  

 
accept sql_id    default '' -
  prompt 'Please provide the sql_id: '
  
  
PROMPT ================
PROMPT SID Details 
PROMPT ================ 

 column box format a30
column spid format a10
column username format a20 
column program format a30
column os_user format a20
col LOGON_TIME for a20  

select b.inst_id,b.sid,b.serial#,a.spid, substr(b.machine,1,30) box,to_char (b.logon_time, 'dd-mon-yyyy hh24:mi:ss') logon_time,
 substr(b.username,1,20) username,
 substr(b.osuser,1,20) os_user,
 substr(b.program,1,30) program,status,b.last_call_et AS last_call_et_secs,b.sql_id 
 from gv$session b,gv$process a 
 where b.paddr = a.addr 
 and a.inst_id = b.inst_id  
 and type='USER'   and  b.sid=&sid
 and b.inst_id=&inst_id
 order by logon_time;



column sid format 9999 
column username format a15
column PARSING_SCHEMA_NAME format a15  
column sql_text format a50
column module format a35
select a.inst_id,a.sid,a.username,b.PARSING_SCHEMA_NAME,a.module,a.sql_id,a.sql_child_number child,b.hash_value,to_char (a.sql_exec_start, 'dd-Mon-yyyy hh24:mi:ss') sql_exec_start,(sysdate-sql_exec_start)*24*60*60 SECS,b.rows_processed,a.status,substr(b.sql_text,1,50) sql_text  
from gv$session a,gv$sqlarea b 
where a.sql_hash_value = b.hash_value
and a.sql_address    = b.address
and a.sid=&sid
and a.inst_id=&inst_id
and  a.module not like '%emagent%'
and  a.module not like '%oraagent.bin%'
and a.username is not null 
order by a.status;


PROMPT ==============================
PROMPT RealTime Monitoring For Sid
PROMPT ===============================

SELECT *
     FROM
       (SELECT status,
         --username,
         sql_id,
         sql_exec_id,
         TO_CHAR(sql_exec_start,'dd-mon-yyyy hh24:mi:ss') AS sql_exec_start,
         ROUND(elapsed_time/1000000)                      AS "Elapsed (s)",
         ROUND(cpu_time    /1000000)                      AS "CPU (s)",
         buffer_gets,
         ROUND(physical_read_bytes /(1024*1024)) AS "Phys reads (MB)",
         ROUND(physical_write_bytes/(1024*1024)) AS "Phys writes (MB)"
       FROM gv$sql_monitor where sid=&sid and inst_id=&inst_id
       ORDER BY elapsed_time DESC
       )
     WHERE rownum<=20; 
  
  
SELECT ROUND(elapsed_time    /1000000)     AS "Elapsed (s)",
     ROUND(cpu_time             /1000000,3)   AS "CPU (s)",
     ROUND(queuing_time         /1000000,3)   AS "Queuing (s)",
     ROUND(user_io_wait_time    /1000000,3)   AS "I/O wait (s)",
     ROUND(application_wait_time/1000000,3)   AS "Appli wait (s)",
     ROUND(concurrency_wait_time/1000000,3)   AS "Concurrency wait (s)",
     ROUND(cluster_wait_time    /1000000,3)   AS "Cluster wait (s)",
     ROUND(physical_read_bytes  /(1024*1024)) AS "Phys reads (MB)",
     ROUND(physical_write_bytes /(1024*1024)) AS "Phys writes (MB)",
     buffer_gets                              AS "Buffer gets",
     ROUND(plsql_exec_time/1000000,3)         AS "Plsql exec (s)",
     ROUND(java_exec_time /1000000,3)         AS "Java exec (s)"
     FROM gv$sql_monitor
     WHERE sid=&sid and inst_id=&inst_id;
 
 
PROMPT ================
PROMPT SID Waiting on 
PROMPT ================   
  
set pagesize 9999 echo off  
COLUMN username FORMAT A30
COLUMN sid FORMAT 9999
COLUMN serial# FORMAT 999999
COLUMN event FORMAT A40
 
SELECT NVL(s.username, '(oracle)') AS username,
       s.sid,
       s.serial#,
       se.event,
       se.total_waits,
       se.total_timeouts,
       se.time_waited,
       se.average_wait,
       se.max_wait,
       se.time_waited_micro
FROM   gv$session_event se,
       gv$session s
WHERE  s.sid = se.sid
AND    s.sid = &sid
 and s.inst_id=se.inst_id
 and s.inst_id=&inst_id
ORDER BY se.time_waited DESC
/
  
  
col WAIT_CLASS for a10
SELECT sw.inst_id,NVL(s.username, '(oracle)') AS username,
       s.sid,
       s.serial#,
       sw.event,
       sw.wait_class,
       sw.wait_time,
       sw.seconds_in_wait,
       sw.state
FROM   gv$session_wait sw,
       gv$session s
WHERE  s.sid = sw.sid and s.inst_id=sw.inst_id and s.sid=&sid
 and s.inst_id=&inst_id
ORDER BY sw.seconds_in_wait DESC;  
  
PROMPT ================
PROMPT Session LongOps
PROMPT ================   
  
SET VERIFY OFF

SELECT a.sid,RPAD(a.opname,30),a.sofar,a.totalwork,a.ELAPSED_SECONDS,ROUND(((a.sofar)*100)/a.totalwork,3) "%_COMPLETED",time_remaining,
RPAD(a.username,10) username,a.SQL_HASH_VALUE,B.STATUS 
FROM GV$SESSION_LONGOPS a, gv$session b
WHERE a.sid=&sid 
 and b.inst_id=&inst_id
AND a.sofar<> a.totalwork
/

PROMPT ================================
PROMPT Reason for Downgrade
PROMPT ================================  
set pages 2000 lines 200
col sql_id for a19
col REASON_FOR_DOWNGRADE for a90
alter session set nls_date_format='DD-MM-YYYY HH24:MI:SS';
select SID,sql_id,sql_exec_id, sql_exec_start,
case otherstat_2_value
when 350 then 'DOP downgrade due to adaptive DOP'
when 351 then 'DOP downgrade due to resource manager max DOP'
when 352 then 'DOP downgrade due to insufficient number of processes'
when 353 then 'DOP downgrade because workers failed to join'
end reason_for_downgrade
from GV$SQL_PLAN_MONITOR
where sql_id = '&sql_id' and plan_operation='PX COORDINATOR' and otherstat_2_id=59
order by sql_exec_id;
  
PROMPT ================================
PROMPT SQL_MONITOR REPORT
PROMPT ================================  

set pagesize 0 echo off timing off linesize 1500 trimspool on trim on long 2000000 longchunksize 2000000
select
dbms_sql_monitor.REPORT_SQL_MONITOR(
   sql_id=>'&sql_id',
   report_level=>'ALL',
   type=>'TEXT')
from dual;  

  
PROMPT ================================
PROMPT Full sql statement
PROMPT ================================  

set lines 1000 pages 9999
 set long 20000
 col sql_text for a500 
select sql_text  from dba_hist_sqltext where sql_id = '&sql_id';  

  
PROMPT ================
PROMPT Bind Variables
PROMPT ================    
  
col name for a40  
col VALUE_STRING for a50  
SELECT NAME,POSITION,DATATYPE_STRING,VALUE_STRING FROM gv$sql_bind_capture WHERE sql_id='&sql_id'  and inst_id=&inst_id;
  

  
PROMPT ================
PROMPT SQL History
PROMPT ================    

set lines 1000 pages 9999
COL instance_number FOR 9999 HEA 'Inst';
COL end_time HEA 'End Time';
COL plan_hash_value HEA 'Plan|Hash Value';
COL executions_total FOR 999,999 HEA 'Execs|Total';
COL rows_per_exec HEA 'Rows Per Exec';
COL et_secs_per_exec HEA 'Elap Secs|Per Exec';
COL cpu_secs_per_exec HEA 'CPU Secs|Per Exec';
COL io_secs_per_exec HEA 'IO Secs|Per Exec';
COL cl_secs_per_exec HEA 'Clus Secs|Per Exec';
COL ap_secs_per_exec HEA 'App Secs|Per Exec';
COL cc_secs_per_exec HEA 'Conc Secs|Per Exec';
COL pl_secs_per_exec HEA 'PLSQL Secs|Per Exec';
COL ja_secs_per_exec HEA 'Java Secs|Per Exec';
SELECT 'gv$dba_hist_sqlstat' source,h.instance_number,
       TO_CHAR(CAST(s.begin_interval_time AS DATE), 'DD-MM-YYYY HH24:MI') snap_time,
       TO_CHAR(CAST(s.end_interval_time AS DATE), 'DD-MM-YYYY HH24:MI') end_time,
       h.sql_id,
       h.plan_hash_value, 
       h.executions_total,
       TO_CHAR(ROUND(h.rows_processed_total / h.executions_total), '999,999,999,999') rows_per_exec,
       TO_CHAR(ROUND(h.elapsed_time_total / h.executions_total / 1e6, 3), '999,990.000') et_secs_per_exec,
       TO_CHAR(ROUND(h.cpu_time_total / h.executions_total / 1e6, 3), '999,990.000') cpu_secs_per_exec,
       TO_CHAR(ROUND(h.iowait_total / h.executions_total / 1e6, 3), '999,990.000') io_secs_per_exec,
       TO_CHAR(ROUND(h.clwait_total / h.executions_total / 1e6, 3), '999,990.000') cl_secs_per_exec,
       TO_CHAR(ROUND(h.apwait_total / h.executions_total / 1e6, 3), '999,990.000') ap_secs_per_exec,
       TO_CHAR(ROUND(h.ccwait_total / h.executions_total / 1e6, 3), '999,990.000') cc_secs_per_exec,
       TO_CHAR(ROUND(h.plsexec_time_total / h.executions_total / 1e6, 3), '999,990.000') pl_secs_per_exec,
       TO_CHAR(ROUND(h.javexec_time_total / h.executions_total / 1e6, 3), '999,990.000') ja_secs_per_exec
  FROM dba_hist_sqlstat h, 
       dba_hist_snapshot s
 WHERE h.sql_id = '&sql_id'
   AND h.executions_total > 0 
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
UNION ALL  
SELECT 'gv$sqlarea_plan_hash' source,h.inst_id, 
       TO_CHAR(sysdate, 'DD-MM-YYYY HH24:MI') snap_time,
       TO_CHAR(sysdate, 'DD-MM-YYYY HH24:MI') end_time,
       h.sql_id,
       h.plan_hash_value, 
       h.executions,
       TO_CHAR(ROUND(h.rows_processed / h.executions), '999,999,999,999') rows_per_exec,
       TO_CHAR(ROUND(h.elapsed_time / h.executions / 1e6, 3), '999,990.000') et_secs_per_exec,
       TO_CHAR(ROUND(h.cpu_time / h.executions / 1e6, 3), '999,990.000') cpu_secs_per_exec,
       TO_CHAR(ROUND(h.USER_IO_WAIT_TIME / h.executions / 1e6, 3), '999,990.000') io_secs_per_exec,
       TO_CHAR(ROUND(h.CLUSTER_WAIT_TIME / h.executions / 1e6, 3), '999,990.000') cl_secs_per_exec,
       TO_CHAR(ROUND(h.APPLICATION_WAIT_TIME / h.executions / 1e6, 3), '999,990.000') ap_secs_per_exec,
       TO_CHAR(ROUND(h.CLUSTER_WAIT_TIME / h.executions / 1e6, 3), '999,990.000') cc_secs_per_exec,
       TO_CHAR(ROUND(h.PLSQL_EXEC_TIME / h.executions / 1e6, 3), '999,990.000') pl_secs_per_exec,
       TO_CHAR(ROUND(h.JAVA_EXEC_TIME / h.executions / 1e6, 3), '999,990.000') ja_secs_per_exec
  FROM gv$sqlarea_plan_hash h 
 WHERE h.sql_id = '&sql_id'
  and h.inst_id=&inst_id
   AND h.executions > 0 
order by source ; 
  
PROMPT ================================
PROMPT    Sql_id waiting on  ?
PROMPT ================================    

select
    sql_id,event,
    time_waited "time_waited(s)",
    case when time_waited = 0 then 
        0
    else
        round(time_waited*100 / sum(time_waited) Over(), 2)
    end "percentage"
from
    (
        select sql_id,event, sum(time_waited) time_waited
        from gv$active_session_history
        where sql_id = '&sql_id' and
  inst_id=&inst_id
        group by sql_id,event
    )
order by
    time_waited desc;

PROMPT ================================
PROMPT  v$active_sess_history Details
PROMPT ================================  


column my_sid format 99999
column my_ser format 99999
column my_state format a30
column my_blkr format 99999
select to_char(a.sample_time, 'HH24:MI:SS') MY_TIME,a.session_id MY_SID,a.session_serial# MY_SER,SQL_PLAN_HASH_VALUE,SQL_CHILD_NUMBER,
        DECODE(a.session_state, 'WAITING' ,a.event, a.session_state) MY_STATE,a.xid, a.sql_id,
        a.blocking_session MY_BLKR
from gv$active_session_history a, dba_users u
where u.user_id = a.user_id
and a.sql_id = '&sql_id' and a.inst_id=&inst_id
and a.sample_time > SYSTIMESTAMP-(2/1440);


PROMPT ================================
PROMPT    v$sql Details
PROMPT ================================ 

Set lines 1000 pages 9999
COL executions FOR A20;
COL rows_processed FOR A20;
COL buffer_gets FOR A20;
COL disk_reads FOR A20;
COL direct_writes FOR A20;
COL elapsed_secs FOR A18;
COL cpu_secs FOR A18;
COL user_io_wait_secs FOR A18;
COL cluster_wait_secs FOR A18;
COL appl_wait_secs FOR A18;
COL conc_wait_secs FOR A18;
COL plsql_exec_secs FOR A18;
COL java_exec_secs FOR A18;
COL io_cell_offload_eligible_bytes FOR A30;
COL io_interconnect_bytes FOR A30;
COL io_saved FOR A8;

SELECT inst_id, child_number, plan_hash_value,
       LPAD(TO_CHAR(executions, '999,999,999,999,990'), 20) executions, 
       LPAD(TO_CHAR(rows_processed, '999,999,999,999,990'), 20) rows_processed, 
       LPAD(TO_CHAR(buffer_gets, '999,999,999,999,990'), 20) buffer_gets,
       LPAD(TO_CHAR(disk_reads, '999,999,999,999,990'), 20) disk_reads, 
       LPAD(TO_CHAR(direct_writes, '999,999,999,999,990'), 20) direct_writes,
       LPAD(TO_CHAR(ROUND(elapsed_time/1e6, 3), '999,999,990.000'), 18) elapsed_secs,
       LPAD(TO_CHAR(ROUND(cpu_time/1e6, 3), '999,999,990.000'), 18) cpu_secs,
       LPAD(TO_CHAR(ROUND(user_io_wait_time/1e6, 3), '999,999,990.000'), 18) user_io_wait_secs,
       LPAD(TO_CHAR(ROUND(cluster_wait_time/1e6, 3), '999,999,990.000'), 18) cluster_wait_secs,
       LPAD(TO_CHAR(ROUND(application_wait_time/1e6, 3), '999,999,990.000'), 18) appl_wait_secs,
       LPAD(TO_CHAR(ROUND(concurrency_wait_time/1e6, 3), '999,999,990.000'), 18) conc_wait_secs,
       LPAD(TO_CHAR(ROUND(plsql_exec_time/1e6, 3), '999,999,990.000'), 18) plsql_exec_secs,
       LPAD(TO_CHAR(ROUND(java_exec_time/1e6, 3), '999,999,990.000'), 18) java_exec_secs,
       LPAD(TO_CHAR(io_cell_offload_eligible_bytes, '999,999,999,999,999,999,990'), 30) io_cell_offload_eligible_bytes,
       LPAD(TO_CHAR(io_interconnect_bytes, '999,999,999,999,999,999,990'), 30) io_interconnect_bytes,
       CASE 
         WHEN io_cell_offload_eligible_bytes > io_interconnect_bytes THEN
           LPAD(TO_CHAR(ROUND(
           (io_cell_offload_eligible_bytes - io_interconnect_bytes) * 100 / io_cell_offload_eligible_bytes
           , 2), '990.00')||' %', 8) END io_saved
       FROM gv$sql
WHERE sql_id = '&sql_id' and inst_id=&inst_id
ORDER BY 1, 2;

 
PROMPT ================================
PROMPT Sql Profiles 
PROMPT ================================   
 
set lines 1000 pages 9999
col name for a30
col task_exec_name for a16
col category for a10
col created for a30
col sql_text for a150
col signature for 9999999999999999999999999

select sql.sql_id,sql.child_number as child , prof.name, prof.category, prof.created,prof.task_exec_name,prof.FORCE_MATCHING,prof.status,prof.SIGNATURE
from 
dba_sql_profiles prof,
gv$sql sql
where sql.sql_id  in ('&sql_id')
-- and   sql.child_number=child_number  
-- and   sql.force_matching_signature=prof.SIGNATURE 
order by
created;


 
PROMPT ================
PROMPT Sql Baselines 
PROMPT ================ 
 
 
col SQL_HANDLE for a30
col origin for a16
col last_modified for a30
col last_verified for a30

select sql_handle, plan_name, origin, created, last_modified, last_verified,ENABLED,ACCEPTED,FIXED,REPRODUCED
from dba_sql_plan_baselines
where signature in (select force_matching_signature
                    from gv$sql
     where sql_id='&sql_id'
      and inst_id=&inst_id);
 
 
 
undef sid 
undef sql_id
undef inst_id 
spool off;

