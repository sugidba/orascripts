col object_type  for a15
col object_owner for a30
col object_name  for a30
col object_alias for a30
col qblock_name  for a30
SELECT  id,object_type,object_owner,object_name,object_alias,qblock_name  FROM gv$sql_plan 
WHERE sql_id = '&sql_id' and object_alias is not null;
