col program for a50
col event for a40
col ch for 99
col host-pid for a7
select s.sid,s.serial#,spid "host-pid",s.sql_child_number ch,s.program ,s.event,s.seconds_in_wait from gv$session s, gv$process p
where paddr=addr and s.sql_id='&&sql_id' and s.inst_id=p.inst_id order by p.pid;
