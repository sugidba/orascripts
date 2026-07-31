SELECT
    'exec dbms_stats.gather_table_stats(OWNNAME=>''' || TABLE_OWNER || ''', TABNAME=>''' || table_name || ''', PARTNAME=>''' || o.subobject_name || ''', DEGREE=>8, GRANULARITY=>''PARTITION'', CASCADE=>TRUE, ESTIMATE_PERCENT=>1, no_invalidate=>TRUE);' AS gather_stats_cmd
FROM
    dba_objects o
    JOIN DBA_TAB_PARTITIONS p ON o.subobject_name = p.PARTITION_NAME
WHERE
    o.created > sysdate - 10
    AND o.object_name IN (select distinct object_name from gv$sql_plan where sql_id = '&sql_id' and object_name is not null and object_type='TABLE')
    AND p.last_analyzed IS NULL
ORDER BY
    o.created;
