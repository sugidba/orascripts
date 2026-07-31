col SQL_ID for a13
col SQL_END_TIME for a23
col ch for 99
col ACT_PX for 99
col SQL_EXEC_ID for 999999999999
col PHV for 999999999999
col FMS for 9999999999999999999999
SELECT SQL_ID,sql_exec_id,sql_child_number ch,
         SQL_EXEC_START,
--         MIN (sample_time) SQL_START_TIME,
         MAX (sample_time)
             SQL_END_TIME,
                 SQL_PLAN_HASH_VALUE PHV,FORCE_MATCHING_SIGNATURE FMS,
         ROUND (
               (  CAST (MAX (sample_time) AS DATE)
                - CAST (SQL_EXEC_START AS DATE))
             * 3600
             * 24)
             elsec,
         ROUND (SUM (delta_read_io_bytes) / 1024 / 1024 / 1024, 2)   READ_GB,
    --     ROUND (SUM (delta_interconnect_io_bytes) / 1024 / 1024 / 1024, 2)  INTER_IO_GB,
         MAX (TRUNC (px_flags / 2097152))    ACT_Px,
         MIN (NULLIF (TRUNC (px_flags / 2097152), 0))   MIN_px
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
