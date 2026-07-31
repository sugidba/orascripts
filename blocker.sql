set lines 750 pages 9999
alter session set nls_date_format='YYYY/MM/DD HH24:MI:SS';
col sid for 9999
col event for a30
col blocker for a10
select inst_id,sid,serial#,username,event,module,BLOCKING_INSTANCE ||','|| blocking_session blocker from gv$session  
where username='&user' and blocking_session is not null order by logon_time desc ;
