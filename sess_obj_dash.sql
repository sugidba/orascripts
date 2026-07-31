SELECT /*+ LEADING(b) USE_NL(b c) PARALLEL(b, 4) PARALLEL(c, 4) */ DISTINCT
    c.owner,
    c.segment_name,
    c.partition_name,
    c.segment_type
FROM
    dba_hist_active_sess_history b
JOIN
    dba_extents c
    ON c.file_id = b.current_file#
   AND b.current_block# BETWEEN c.block_id AND c.block_id + c.blocks - 1
WHERE
    b.sql_id = '&sql_id'
    AND b.sample_time >= TO_DATE('18-JUL-25 07:15:00', 'DD-MON-RR HH24:MI:SS')
    AND b.sample_time < TO_DATE('18-JUL-25 07:17:00', 'DD-MON-RR HH24:MI:SS')
    AND b.current_file# > 0
    AND b.current_block# IS NOT NULL
    AND c.segment_type IN ('TABLE PARTITION', 'INDEX PARTITION')
ORDER BY
    c.owner,
    c.segment_name,
    c.partition_name;
