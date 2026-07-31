col owner for a30
col object_name for a40
col subobject_name for a40
select owner,object_name,subobject_name,object_id,object_type from dba_objects where object_id=&object_id;
