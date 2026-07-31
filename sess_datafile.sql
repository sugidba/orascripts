SELECT
    tablespace_name,
    COUNT(*)
FROM
    gv$active_session_history ash
    JOIN dba_data_files d ON ash.current_file# = d.file_id
WHERE
    sql_id = '&sql_id'
   and sample_time between sysdate-1/24/12 and sysdate
GROUP BY
    tablespace_name
ORDER BY
    2 DESC;
