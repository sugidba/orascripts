alter session set nls_date_format='YYYY/MM/DD HH24:MI:SS';
select n.inst_id,sid,serial#,username,osuser,prev_exec_start,logon_time,n.sql_id,n.module,blocking_session,sql_text
from gv$session n,gv$sql s where n.sql_id=s.sql_id 
and n.inst_id=s.inst_id 
and n.sql_id='&sql_id'
-- sql_text like '%select%'
order by username,logon_time; 
