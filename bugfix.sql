column SQL_FEATURE for a34
column ofe for a10
column description for a64
 
select bugno,optimizer_feature_enable ofe ,sql_feature,description,value from v$system_fix_control where (sql_feature like upper('%&1%') or upper(description) like '%&1%')
order by 2 desc nulls last,1 asc;
