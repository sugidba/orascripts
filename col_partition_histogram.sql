col column_name for a30
col partition_name for a30
SELECT 
    p.column_name,
    p.partition_name,
    o.created,
    p.num_distinct,
    p.histogram,p.last_analyzed
FROM DBA_PART_COL_STATISTICS p
JOIN dba_objects o
  ON p.owner = o.owner
 AND p.table_name = o.object_name
 AND p.partition_name = o.subobject_name
WHERE p.table_name = UPPER('&table')
  AND p.owner = UPPER('&owner')
  AND o.object_type = 'TABLE PARTITION'
  AND o.created > SYSDATE - 10
ORDER BY p.column_name, o.created desc ;
