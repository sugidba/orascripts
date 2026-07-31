set lines 750 pages 9999
col TABLE_OWNER for a20
col TABLE_NAME for a40
col SUBOBJECT_NAME for a20
--alter session set nls_date_format='DD-Mon-YY, HH24:Mi:SS' ;
alter session set nls_date_format='YYYY/MM/DD HH24:MI:SS';
select TABLE_OWNER,table_name,o.subobject_name,o.created,to_char(p.last_analyzed,'DD-MON-YYYY HH24:MI:SS') "LASTANALYZED"
from dba_objects o,DBA_TAB_PARTITIONS p
where   o.subobject_name=p.PARTITION_NAME
and o.created > sysdate-10
and o.object_name='&partition_name' order by 4;
