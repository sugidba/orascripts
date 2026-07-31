col owner for a15
col table_name for a20
col DATA_TYPE for a15
col column_name for a30
select owner,table_name,column_name,data_type,num_distinct,NULLABLE,histogram,last_analyzed,GLOBAL_STATS from dba_tab_columns
where owner=upper('&OWNER')
and table_name=upper('&TABLE_NAME');
