UNDEF username 
undef sql_id
 
UNDEF sid
SET LINES 1000 PAGES 9999
COL phprof FOR a15
COL sid FOR a12
COL txt FOR a30
COL s FOR a2
COL ch FOR 99
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
    round(elapsed_time / 1000000) ela,
    round(cpu_time / 1000000) cpu,
    round(user_io_wait_time / 1000000) io,
    round(cluster_wait_time / 1000000) clu,
    round(application_wait_time / 1000000) app,
    round(concurrency_wait_time / 1000000) con,
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
--    AND program NOT LIKE 'oracle%'
ORDER BY
    child_number;

prompt =================================================

SET LINES 1000 PAGES 9999
COL sid FOR a12
COL id FOR a15
COL w_sec FOR 99999
COL ch FOR 99
COL event FOR a33
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
--    AND program NOT LIKE 'oracle%'
ORDER BY
    child_number;
