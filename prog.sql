UNDEF username 
undef sql_id
 
UNDEF sid
SET LINES 1000 PAGES 9999
COL sid FOR a12
col event for a30
col module for a30
col machine for a30
alter session set nls_date_format='YYYY/MM/DD HH24:MI:SS';
SELECT
    inst_id
    || ','
    || sid
    || ','
    || serial# sid,event,sql_id,sql_exec_start,module,machine,blocking_session from gv$session
where sql_id = nvl('&&sql_id', sql_id) 
    AND username = nvl('&&username', username)
   and prev_sql_id is not null
   order by SQL_EXEC_START desc ;


col BS for a2
col BA for a2
col opt for a3
col ada for a3
select sql_id,child_number,executions,rows_processed,program_line#,is_bind_sensitive BS,is_bind_aware BA,is_reoptimizable opt,is_resolved_adaptive_plan ada,object_status,invalidations,parse_calls
from gv$sql
where sql_id='&&sql_id';



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
    AND u.username = nvl('&&username', u.username)
    AND s.inst_id = u.inst_id
--sid=5047
--and u.inst_id=6
    AND s.address = u.sql_address
    AND last_active_time > SYSDATE - 1
    AND program NOT LIKE 'oracle%'
ORDER BY
    child_number;

prompt =================================================

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
    AND u.username = nvl('&&username', u.username)
    AND s.sql_id = nvl('&&sql_id', s.sql_id)
    AND s.inst_id = u.inst_id
--and u.inst_id=3
    AND s.address = u.sql_address
--    AND last_active_time > SYSDATE - 1
    AND program NOT LIKE 'oracle%'
ORDER BY
    child_number;
