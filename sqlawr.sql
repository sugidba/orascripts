set lines 750 pages 9999
set long 20000 longchunksize 20000
select sql_text from dba_hist_sqltext where SQL_ID='&sql_id';
