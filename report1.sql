undef sql_id
set pagesize 0 echo off timing off linesize 1000 trimspool on trim on long 2000000 longchunksize 2000000
alter session set  "_parallel_syspls_obey_force" = FALSE ;
select
DBMS_SQL_MONITOR.REPORT_SQL_MONITOR(
   sql_id=>'&sql_id',
   report_level=>'ALL',
   type=>'TEXT')
from dual;
