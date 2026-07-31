alter session set nls_date_format='YYYY/MM/DD HH24:MI:SS';
select run_start,run_end,jobname from dbaadmin.stats_job_table where run_start> sysdate-3 order by 1 desc ;
col running for a10
SELECT DBMS_STATS.get_prefs('CONCURRENT') "running" FROM dual;
