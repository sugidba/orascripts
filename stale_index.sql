set lines 750 pages 9999
col OWNER for a15
col TABLE_NAME for a25
col index_name for a25
col SUBOBJECT_NAME for a20
alter session set nls_date_format='YYYY/MM/DD HH24:MI:SS';
select o.OWNER,table_name,p.index_name,o.subobject_name,o.created,to_char(p.last_analyzed,'DD-MON-YYYY HH24:MI:SS') "LASTANALYZED",STALE_STATS,num_rows
from dba_objects o,dba_ind_statistics p
where   o.subobject_name=p.PARTITION_NAME
and STALE_STATS !='NO'
and o.object_name='&table_name' order by 4;
