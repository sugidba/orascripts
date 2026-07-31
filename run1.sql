alter session set nls_date_format='YYYY/MM/DD HH24:MI:SS';
select inst_id,sid,serial#,username,osuser,SQL_EXEC_START,sql_id,prev_sql_id,event,status,module,blocking_session,BLOCKING_INSTANCE,
FINAL_BLOCKING_SESSION,FINAL_BLOCKING_INSTANCE,FINAL_BLOCKING_SESSION_STATUS from gv$session  
where username='&username' 
order by SQL_EXEC_START desc ;
