ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY/MM/DD HH24:MI:SS';
col key1 for a20
col PHV for a20
Col ins for 99
col px_rq for a5
col px_al for a5
col status for a15
col time for a10
col SQL_EXEC_ID for a10
col fetch for a10
SELECT
    instance_number ins,
        EXTRACTVALUE(XMLType(report_summary),'/report_repository_summary/sql/status') status,
    report_id,
    EXTRACTVALUE(XMLType(report_summary),'/report_repository_summary/sql/@sql_exec_id') sql_exec_id,
    EXTRACTVALUE(XMLType(report_summary),'/report_repository_summary/sql/px_servers_requested') px_rq,
    EXTRACTVALUE(XMLType(report_summary),'/report_repository_summary/sql/px_servers_allocated') px_al,
    period_start_time,
    period_end_time,
    key1,
    EXTRACTVALUE(XMLType(report_summary), '/report_repository_summary/sql/plan_hash') AS PHV,
    LPAD(EXTRACT(HOUR FROM NUMTODSINTERVAL((period_end_time - period_start_time) * 24 * 60 * 60, 'SECOND')), 2, '0') || ':' ||
    LPAD(EXTRACT(MINUTE FROM NUMTODSINTERVAL((period_end_time - period_start_time) * 24 * 60 * 60, 'SECOND')), 2, '0') || ':' ||
    LPAD(EXTRACT(SECOND FROM NUMTODSINTERVAL((period_end_time - period_start_time) * 24 * 60 * 60, 'SECOND')), 2, '0') AS time,
    EXTRACTVALUE(XMLType(report_summary), '/report_repository_summary/sql/stats/stat[@name="user_fetch_count"]') AS fetch
FROM
    dba_hist_reports
WHERE
    component_name = 'sqlmonitor'
    AND key1 = '&sql_id'
    AND period_start_time > SYSDATE - 15
ORDER BY 3;
