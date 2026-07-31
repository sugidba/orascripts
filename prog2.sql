SET LINES 1000 PAGES 9999
COL sid FOR a10
col sql_id for a13
COL ch FOR 99
COL event FOR a30 WORD_WRAP
col p1text for a20
col p2text for a15
col p3 for 99999999999999
col p3text for a15
col QC for a5 TRUNCATE

SELECT
    u.inst_id
    || ','
    || sid sid,
        substr(u.program,length(u.program)-4,4),
    s.sql_id,
    child_number      ch,
    event,
    p1,p2,p3,disk_reads  diskr,p1text,p2text,p3text
FROM
    gv$sql       s,
    gv$session   u
WHERE
    s.sql_id = u.sql_id
        AND s.sql_id = nvl('&&sql_id', s.sql_id)
    AND s.inst_id = u.inst_id
--and u.inst_id=3
    AND s.address = u.sql_address
--    AND last_active_time > SYSDATE - 1
 --   AND program NOT LIKE 'oracle%'
ORDER BY
    child_number,sid;
