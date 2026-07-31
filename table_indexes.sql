col owner for a30
col index_name for a30
col table_name for a30
col column_name for a30
select 
owner,b.uniqueness,  a.table_name, a.index_name,a.column_name 
from dba_ind_columns a, dba_indexes b
where a.index_name=b.index_name 
and a.index_owner = b.owner
and b.owner='&OWNER'
and b.table_name = upper('&TABLE_NAME')
order by a.table_name, a.index_name;
