col SQL_END_TIME for a23
col ch for 99
col exec_id for 999999999
col PHV for 999999999999
col FORCE_MATCHING_SIGNATURE for 99999999999999999999
SELECT SQL_ID,sql_exec_id exec_id,sql_child_number ch,
TO_CHAR(SQL_EXEC_START,'YYYY-MM-DD HH24:MI:SS') SQL_START_TIME,
TO_CHAR(MAX(sample_time),'YYYY-MM-DD HH24:MI:SS') SQL_END_TIME,
                 SQL_PLAN_HASH_VALUE PHV,FORCE_MATCHING_SIGNATURE,
-- Convert interval to seconds, then to HH24:MI:SS
       TO_CHAR(TRUNC(EXTRACT(HOUR FROM max(sample_time - sql_exec_start)), 0), 'FM09') || ':' ||
       TO_CHAR(TRUNC(EXTRACT(MINUTE FROM max(sample_time - sql_exec_start)), 0), 'FM09') || ':' ||
       TO_CHAR(TRUNC(EXTRACT(SECOND FROM max(sample_time - sql_exec_start)), 0), 'FM09')
         AS run_time,
--         ROUND (SUM (delta_read_io_bytes) / 1024 / 1024 / 1024, 2)              PHY_READ_GB,
--         ROUND (SUM (delta_interconnect_io_bytes) / 1024 / 1024 / 1024, 2)      INTER_IO_GB,
         MAX (TRUNC (px_flags / 2097152))                       ACTUAL_DOP,
         MIN (NULLIF (TRUNC (px_flags / 2097152), 0))             MIN_DOP
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE sql_id = '&sql_id' AND (SQL_EXEC_START IS NOT NULL OR SQL_EXEC_ID IS NOT NULL)
         AND sample_time > sysdate-15
GROUP BY SQL_ID,
         SQL_EXEC_START,
         sql_child_number,
         SQL_PLAN_HASH_VALUE,
                 FORCE_MATCHING_SIGNATURE,
         SQL_EXEC_ID,
         QC_INSTANCE_ID,
         QC_SESSION_ID,
         QC_SESSION_SERIAL#
 ORDER BY SQL_EXEC_START;
