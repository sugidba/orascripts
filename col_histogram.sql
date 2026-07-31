undefine tbl_name
undefine owner
SET VERIFY OFF
SET ECHO OFF

accept tbl_name prompt 'Enter Table Name :'
accept owner prompt 'Enter Owner Name :'

col column_name format a30
col density format 99999999
col num_distinct format 999,999,999

select num_rows,degree,blocks,last_analyzed
from dba_tables
where table_name =upper('&tbl_name')
/

col low_value for a50
col high_value for a50

select column_name,
density,
num_distinct,
histogram
--,low_value,
--high_value
from dba_tab_columns
where table_name =upper('&tbl_name')
and owner=upper('&owner')
order by column_id
/

