select spid "host-pid",p.pid, s.sid, s.serial#, p.program, s.machine from gv$session s, gv$process p where paddr=addr and s.sid=&sid order by p.pid;
