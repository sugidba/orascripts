col sess for a20
col blocker for a12
col event for a32
col prog  for a6
col owner for a30
col obj for a40
col subobject_name for a40
select b.inst_id||','||b.sid||','||b.serial#||','||b.username   sess,
 b.sql_id,
 b.event,
 SUBSTR(b.program, -6) prog,
 owner||'.'||object_name obj,subobject_name
 from
 gv$session b,
 dba_objects o
 where 
  b.ROW_WAIT_OBJ#=o.object_id and
  b.sql_id='&&sql_id';
