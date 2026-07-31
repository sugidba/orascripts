col owner           for a20
col table_name      for a30
col index_name      for a30
col partition_name  for a30
col global_stats    for a3
col object_name     for a30
col object_owner     for a20
col object_type     for a15
col NUM_ROWS for 9999999999999999999999

select distinct object_name,OBJECT_OWNER,GLOBAL_STATS,STALE_STATS,LAST_ANALYZED,NUM_ROWS,BLOCKS  
from gv$sql_plan p,DBA_TAB_STATISTICS t
where
  t.TABLE_NAME=p.object_name 
and  t.owner=p.object_owner
and p.sql_id='&&sql_id'
and p.object_name is not null 
and p.object_type='TABLE'
and t.PARTITION_NAME IS NULL;


select distinct object_name,OBJECT_OWNER,p.object_type,t.table_name,GLOBAL_STATS,STALE_STATS,LAST_ANALYZED,NUM_ROWS  
from gv$sql_plan p,DBA_IND_STATISTICS t
where
  t.INDEX_NAME=p.object_name 
and  t.owner=p.object_owner
and p.sql_id='&&sql_id'
and p.object_name is not null 
and p.object_type like 'INDEX%'
and t.PARTITION_NAME IS NULL;
