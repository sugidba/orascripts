col sess for a20
col username for a25
col blocker for a12
col event for a32
col block# for 9999999999999999
SELECT sw.inst_id||','||sw.sid||','||s.serial#||','||p.spid sess,s.username,logon_time,sql_id,sw.event,status, sw.p1 file#, sw.p2 block#,blocking_instance||','||blocking_session blocker
FROM gv$session_wait sw, gv$session s,gv$process p 
WHERE sw.sid = s.sid and sw.inst_id=s.inst_id and s.paddr=p.addr 
and p.inst_id=s.inst_id
and s.sql_id ='&sql_id';
