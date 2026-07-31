col OWNER for A10
col OBJECT_NAME for A30
col SAVTIME for A40
col ANALYZETIME for A30
col DESCRIPTION for A12
 
set define '~'
define t_owner=~owner
define t_table=~tablename
 
SELECT b.owner, b.object_name, a.savtime, a.rowcnt,a.analyzetime,'' as description  
FROM SYS.WRI$_OPTSTAT_TAB_HISTORY a, DBA_OBJECTS b
WHERE b.owner=upper('~t_owner')
and b.object_name=upper('~t_table')
and b.object_type='TABLE'
and a.obj#=b.object_id
union
select owner, table_name, last_analyzed, num_rows, last_analyzed, 'Current'
from dba_tables 
where owner=upper('~t_owner')
and   table_name=upper('~t_table')
order by analyzetime asc;
