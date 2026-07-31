set long 1000000
set longchunksize 1000000
set linesize 1000
set pagesize 0
set trim on
set trimspool on
set echo off
set feedback off

ACCEPT sql_id CHAR PROMPT 'Enter the SQL_ID: '
-- Dynamically generate the HTML file name
COLUMN html_file_name NEW_VALUE html_file
SELECT 'sqlmonrep_' || '&sql_id' || '_' || TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS') || '.html' AS html_file_name
FROM DUAL;

-- Start spooling to the dynamically generated HTML file
SPOOL &html_file

--select dbms_sqltune.report_sql_detail(
select DBMS_SQL_MONITOR.REPORT_SQL_MONITOR(
  sql_id       => '&sql_id',
  type         => 'ACTIVE',
  report_level => 'ALL') as report
from dual;
spool off;
undef sql_id
