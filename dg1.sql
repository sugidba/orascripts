select NAME,value from  v$DATAGUARD_STATS where name in ('transport lag','apply lag');
SELECT TO_CHAR(item)
  ||' = '
  ||TO_CHAR(sofar)
  ||' '
  ||TO_CHAR(units)
  ||' '
  || TIMESTAMP "Values"
FROM gv$recovery_progress
WHERE start_time=
  (SELECT MAX(start_time) FROM gv$recovery_progress
  )
/
SELECT 'GB to be applied (lag) = '
  ||ROUND(SUM(BLOCKS * BLOCK_SIZE)/1024/1024/1024)
FROM V$ARCHIVED_LOG
WHERE dest_id       =1
AND COMPLETION_TIME > sysdate          -
  (SELECT (to_number(SUBSTR(value,5,2))/24+to_number(SUBSTR(value,8,2))/24/60)
  FROM V$DATAGUARD_STATS
  WHERE name LIKE 'apply lag'
  );
