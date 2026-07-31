prompt	USE SQLDEVELOPER
col id for 999
col pid for 999	
col OP                 for a30
col ACCESS_PREDICATES  for a30
col FILTER_PREDICATES  for a30
col OBJECT             for a30
col OBJECT_ALIAS       for a30
col QBLOCK_NAME        for a30

select sqp.id, sqp.parent_id pid,
   lpad('| ', (sqp.depth-1) * 2, '| ') || sqp.operation || case when sqp.options is not null then ' (' || sqp.options || ')' end op,
--  sqp.operation || case when sqp.options is not null then ' (' || sqp.options || ')' end op,
   sqp.access_predicates,
   sqp.filter_predicates,
   sqp.object_owner||'.'|| sqp.object_name object,
   sqp.object_alias,
   sqp.qblock_name,cpu_cost, io_cost
from
   gv$sql_plan            sqp
where
   sqp.sql_id = 'abc' 
order by
   sqp.id;
