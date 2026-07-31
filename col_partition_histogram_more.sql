--use sql developer
SELECT
    p.column_name,
    p.partition_name,
    o.created,
    p.num_distinct,
     LOW_VALUE,    
 HIGH_VALUE ,  
 DENSITY ,     
 NUM_NULLS ,   
 NUM_BUCKETS , 
 SAMPLE_SIZE , 
 GLOBAL_STATS ,
 USER_STATS ,  
 NOTES ,       
    p.histogram,p.last_analyzed
FROM DBA_PART_COL_STATISTICS p
JOIN dba_objects o
  ON p.owner = o.owner
 AND p.table_name = o.object_name
 AND p.partition_name = o.subobject_name
WHERE p.table_name = UPPER('&table_name')
  AND p.owner = UPPER('&owner')
  AND o.object_type = 'TABLE PARTITION'
  AND p.column_name in ('&col1','&col2','PAY_DETAIL_ID')
  AND o.created > SYSDATE - 4
ORDER BY p.column_name, o.created desc ;
