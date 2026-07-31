set long 1000000
set longchunksize 1000000
set linesize 1000
set pagesize 0
set trim on
set trimspool on
set echo off
set feedback off

spool sql_monitor_rid_report.html
set long 10000000 longchunksize 10000000 pages 0
SELECT DBMS_AUTO_REPORT.REPORT_REPOSITORY_DETAIL(RID => &RID, TYPE => 'ACTIVE')       FROM dual;
spool off
