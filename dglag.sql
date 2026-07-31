alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
SET linesize 500  
SELECT 'Apply instance is: '
  ||inst_id
  ||' and status is: '
  ||status "Apply lag data:"
FROM GV$MANAGED_STANDBY
WHERE process='MRP0'
UNION ALL
SELECT '---------------------------' FROM dual
UNION ALL
SELECT upper(NAME)
  ||' = '
  || VALUE
  ||' Local time: '
  || DATUM_TIME
  ||' Computed at: '
  || TIME_COMPUTED "Lag summary: "
FROM V$DATAGUARD_STATS
WHERE name LIKE 'transport lag'
UNION ALL
SELECT upper(NAME)
  ||'     = '
  || VALUE
  ||' Local time: '
  || DATUM_TIME
  ||' Computed at: '
  || TIME_COMPUTED
FROM V$DATAGUARD_STATS
WHERE name LIKE 'apply lag'
UNION ALL
SELECT 'GB to be applied (lag) = '
  ||ROUND(SUM(BLOCKS * BLOCK_SIZE)/1024/1024/1024)
FROM V$ARCHIVED_LOG
WHERE dest_id       =1
AND COMPLETION_TIME > sysdate          -
  (SELECT (to_number(SUBSTR(value,5,2))/24+to_number(SUBSTR(value,8,2))/24/60)
  FROM V$DATAGUARD_STATS
  WHERE name LIKE 'apply lag'
  )
UNION ALL
SELECT 'GB applied today       = '
  ||(
  (SELECT ROUND(SUM(BLOCKS * BLOCK_SIZE)/1024/1024/1024)
  FROM V$ARCHIVED_LOG
  WHERE dest_id       =1
  AND COMPLETION_TIME > TRUNC(sysdate)
  )                        -
  (SELECT ROUND(SUM(BLOCKS * BLOCK_SIZE)/1024/1024/1024)
  FROM V$ARCHIVED_LOG
  WHERE dest_id       =1
  AND COMPLETION_TIME > sysdate          -
    (SELECT (to_number(SUBSTR(value,5,2))/24+to_number(SUBSTR(value,8,2))/24/60)
    FROM V$DATAGUARD_STATS
    WHERE name LIKE 'apply lag'
    )
  ))
FROM dual
UNION ALL
SELECT 'GB generated today until now = '
  ||ROUND(SUM(BLOCKS * BLOCK_SIZE)/1024/1024/1024)
FROM V$ARCHIVED_LOG
WHERE dest_id       =1
AND COMPLETION_TIME > TRUNC(sysdate)
UNION ALL
SELECT 'TOTAL GB generated yesterday = '
  ||ROUND(SUM(BLOCKS * BLOCK_SIZE)/1024/1024/1024)
FROM V$ARCHIVED_LOG
WHERE dest_id              =1
AND TRUNC(COMPLETION_TIME) = TRUNC(sysdate-1)
UNION ALL
SELECT 'Daily avarage (last 30 days) = '
  ||ROUND(SUM(BLOCKS * BLOCK_SIZE)/1024/1024/1024 / COUNT(DISTINCT TRUNC(COMPLETION_TIME)))
FROM V$ARCHIVED_LOG
WHERE dest_id =1
AND TRUNC(COMPLETION_TIME) BETWEEN TRUNC(sysdate-31) AND TRUNC(sysdate-1)
UNION ALL
SELECT '---------------------------' FROM dual
UNION ALL
SELECT 'Apply performance data(sysdate is):'||sysdate FROM dual
UNION ALL
SELECT '---------------------------' FROM dual
UNION ALL
SELECT 'Recovery started (restarted)= '
  || MAX(start_time)
FROM gv$recovery_progress
UNION ALL
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
