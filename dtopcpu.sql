    Prompt ==> time-format = DD-MON-YY hh24:mi:ss
	set feedback off echo off tab off trimout on trimspool on linesize 250 pagesize 1000 verify off
        BREAK ON instance_number SKIP 1
    col instance_number for 99 head 'I'
    col machine for a9 word_wrapped
    col PARSING_SCHEMA_NAME for a25 head PARSING_SCHEMA_NAME trunc
    col AVG_SECS_PER_EXEC  for 99,999.99 heading 'Avg Secs|Per Exec'
    col CPU_PCT for 999.9 heading 'CPU PCT'
    col IO_PCT for 999.9 heading 'IO PCT'
    col EXECUTIONS for 999,999,999 heading 'Total Execs|Per SQL_ID'
    col OSUSER for a9 word_wrapped
    col TXT for a30 word_wrapped  heading 'TXT'
    col SQL for a90 heading SQL trunc
    col sess for a12 heading 'Active|SID:SERIAL#' justify center
    col username for a20
    col QC_SID for a10 heading 'PQ|SID:SERIAL#' justify center

WITH cpu_data AS (
    SELECT
        instance_number,
        sql_id,
        SUM(DECODE(session_state, 'ON CPU', 1, 0)) AS CPU,
		user_id
    FROM
        dba_hist_active_sess_history
    WHERE
        session_state = 'ON CPU'
        AND sample_time BETWEEN TO_DATE('&starttime', 'dd-MON-yy hh24:mi:ss')
                      AND TO_DATE('&endtime', 'dd-MON-yy hh24:mi:ss')
        AND sql_id IS NOT NULL
		AND session_type='FOREGROUND'
    GROUP BY
        instance_number, sql_id,user_id
),
cpu_pct_data AS (
    SELECT
        instance_number,
        sql_id,
        ROUND(RATIO_TO_REPORT(CPU) OVER (PARTITION BY instance_number) * 100, 2) AS cpu_pct,
        ROW_NUMBER() OVER (PARTITION BY instance_number ORDER BY CPU DESC) AS rn,
		user_id
    FROM
        cpu_data
)
SELECT DISTINCT
    ash.instance_number,
    ash.sql_id,
    ash.cpu_pct,
    d.username,
	--REPLACE(REPLACE(SUBSTR(cc.sql_text, 1, 100), CHR(10), ' '), CHR(13), ' ') AS SQL
	  REPLACE(REPLACE(DBMS_LOB.SUBSTR(cc.sql_text, 80, 1), CHR(10), ' '), CHR(13), ' ') AS SQL
	--DBMS_LOB.SUBSTR(cc.sql_text, 100, 1) AS sql_text   
FROM
    cpu_pct_data ash
LEFT JOIN
    dba_hist_sqltext cc ON ash.sql_id = cc.sql_id 
LEFT JOIN
    dba_users d ON ash.user_id = d.user_id
WHERE
    ash.rn <= 10
ORDER BY
    ash.instance_number DESC, ash.cpu_pct DESC;
