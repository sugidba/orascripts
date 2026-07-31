    set feedback off echo off tab off trimout on trimspool on linesize 250 pagesize 1000 verify off
	BREAK ON inst_id SKIP 1
    col inst_id for 99 head 'I'
    col machine for a9 word_wrapped
    col PARSING_SCHEMA_NAME for a25 head PARSING_SCHEMA_NAME trunc
    col AVG_SECS_PER_EXEC  for 99,999.99 heading 'Avg Secs|Per Exec'
    col CPU_PCT for 999.9 heading 'CPU PCT'
    col IO_PCT for 999.9 heading 'IO PCT'
    col EXECUTIONS for 999,999,999 heading 'Total Execs|Per SQL_ID'
    col OSUSER for a9 word_wrapped
    col TXT for a30 word_wrapped  heading 'TXT'
    col SQL for a100 heading SQL trunc
    col sess for a12 heading 'Active|SID:SERIAL#' justify center
    col username for a8
    col QC_SID for a10 heading 'PQ|SID:SERIAL#' justify center
 
    prompt #######################################################################
    prompt # Summary: Top 20 CPU consuming  SQLIDs for last min_to_check minutes
    prompt #######################################################################
	
WITH cpu_data AS (
    SELECT 
        inst_id, 
        sql_id,
        SUM(DECODE(session_state, 'ON CPU', 1, 0)) AS CPU
    FROM 
        gv$active_session_history
    WHERE 
        session_state = 'ON CPU'
        AND sample_time > SYSDATE - ((1/1440) * &min_to_check)
        AND sql_id IS NOT NULL
    GROUP BY 
        inst_id, sql_id
),
cpu_pct_data AS (
    SELECT
        inst_id,
        sql_id,
        ROUND(RATIO_TO_REPORT(CPU) OVER (PARTITION BY inst_id) * 100, 2) AS cpu_pct,
        ROW_NUMBER() OVER (PARTITION BY inst_id ORDER BY CPU DESC) AS rn
    FROM 
        cpu_data
)
SELECT DISTINCT 
    ash.inst_id, 
    ash.sql_id,
    ash.cpu_pct,
    cc.PARSING_SCHEMA_NAME,
    REPLACE(REPLACE(SUBSTR(cc.sql_text, 1, 100), CHR(10), ' '), CHR(13), ' ') AS SQL
FROM 
    cpu_pct_data ash
LEFT JOIN 
    gv$sqlarea cc ON ash.sql_id = cc.sql_id AND ash.inst_id = cc.inst_id
WHERE 
    ash.rn <= 10
ORDER BY 
    ash.inst_id DESC, ash.cpu_pct DESC;
