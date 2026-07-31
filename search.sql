col owner for a40
col object_name for a40
col object_type for a20
select owner,object_name,object_type,last_ddl_time from dba_objects where object_name like  UPPER('%&object_name%');
