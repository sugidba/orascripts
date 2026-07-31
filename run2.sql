select n.inst_id,sid,serial#,username,SQL_EXEC_START,n.sql_id,n.event
from gv$session n,gv$sql s where n.sql_id=s.sql_id 
and n.inst_id=s.inst_id 
and n.sql_id=s.sql_id
and status='ACTIVE'
order by username,SQL_EXEC_START; 
