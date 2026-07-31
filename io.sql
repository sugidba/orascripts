col sess_io.sid for 99999
select sess_io.inst_id,
sess_io.sid,
sesion.sql_id,
sess_io.block_gets,
sess_io.consistent_gets,
sess_io.physical_reads,
sess_io.block_changes,
sess_io.consistent_changes
from gv$sess_io sess_io, gv$session sesion
where sesion.sid = sess_io.sid and
sess_io.inst_id = sesion.inst_id and
sesion.sql_id='&&sql_id'
and sesion.username is not null
order by sess_io.inst_id,
sess_io.sid ;
