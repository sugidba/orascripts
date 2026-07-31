col sess for a20
col blocker for a12
col event for a32
select 
 b.inst_id||','||b.sid||','||b.serial#  sess,
 b.username username,
 b.sql_id,
 b.event,
 ROW_WAIT_OBJ#,    
 ROW_WAIT_FILE# ,  
 ROW_WAIT_BLOCK# , 
 ROW_WAIT_ROW#   
 from gv$session b
 where
 b.sql_id='&&sql_id';
