col owner for a20
col index_name for a30
col table_name for a20
col column_name for a30
select 
b.owner,  a.table_name, a.index_name,a.column_name,NUM_DISTINCT,HISTOGRAM,LAST_ANALYZED
from dba_ind_columns a, dba_tab_col_statistics b
where a.TABLE_NAME=b.TABLE_NAME 
and a.index_owner = b.owner
and a.column_name=b.column_name
and b.owner='&OWNER'
and b.table_name = upper('&TABLE_NAME')
order by a.table_name, a.index_name;
