alter session set nls_date_format='YYYY/MM/DD HH24:MI:SS';
select sample_time,event,program from gv$active_session_history where sql_id='&sql_id' and event is not null order by sample_time desc;
