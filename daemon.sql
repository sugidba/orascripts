col username for a20
col osuser for a15
col id for a15
col event for a30
alter session set nls_date_format='YYYY/MM/DD HH24:MI:SS';
select inst_id||','||sid||','||serial# id,username,sql_exec_start,sql_id,event,status,module,blocking_session,BLOCKING_INSTANCE from gv$session
where  audsid in (select oracle_id from oes_ctl_owner.dm_process where program_id in (88888))
order by sql_exec_start desc ;
