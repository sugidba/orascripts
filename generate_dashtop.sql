set verify off
set heading off
set feedback off
spool run_dashtop.sql
SELECT
    '@dashtop event "sql_id=''' || sql_id || '''" "TIMESTAMP''' ||
    TO_CHAR(MIN(sample_time), 'YYYY-MM-DD HH24:MI:SS') || '''" "TIMESTAMP''' ||
    TO_CHAR(MAX(sample_time), 'YYYY-MM-DD HH24:MI:SS') || '''"'
FROM DBA_HIST_ACTIVE_SESS_HISTORY
WHERE sql_id = '&sql_id'
   AND (SQL_EXEC_START IS NOT NULL OR SQL_EXEC_ID IS NOT NULL)
    AND sample_time > sysdate-&number_of_days
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

spool off
prompt @run_dashtop.sql generated
set heading on
set feedback on

