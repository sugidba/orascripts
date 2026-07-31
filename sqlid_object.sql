col object_name for a40
col object_owner for a40
col object_type for a30
select distinct object_name,object_owner,object_type
from gv$sql_plan
where sql_id = '&sql_id' and object_name is not null and object_type is not null
order by object_type desc;
