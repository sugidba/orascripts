col username for a20
col host-pid for a10
col sess for a15
select s.inst_id,spid "host-pid",s.sid||','||s.serial# as sess, p.program,s.username, s.machine from gv$session s, gv$process p
where paddr=addr and s.sid=&sid and s.inst_id=p.inst_id order by p.pid;
