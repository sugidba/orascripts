
col I for 99
col username for a25
col reason_for_downgrade for a60
alter session set nls_date_format='YYYY/MM/DD HH24:MI:SS';

SELECT
    m.inst_id I,
    m.sid,
    m.sql_id,
    s.username,
    m.sql_exec_id,
    m.sql_exec_start,
    m.otherstat_2_value,
    x.qksxareasons AS reason_for_downgrade
FROM
    gv$sql_plan_monitor m
JOIN
    x$qksxa_reason x
      ON m.otherstat_2_value = x.indx
LEFT JOIN
    gv$session s
      ON m.sid = s.sid
     AND m.inst_id = s.inst_id
WHERE
    x.qksxareasons LIKE '%DOP downgrade%'
--      and m.sql_exec_start > sysdate-1
    and username is not null
and username not in ('SYS','SVC_CONTROLM')
ORDER BY
    m.sql_exec_start desc
        fetch first 20 rows only;
