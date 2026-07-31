set lines 750 pages 9999
set  long 2000000 longchunksize 2000000
select sql_fulltext from gv$sql where SQL_ID='&sql_id' and rownum < 2;
--select sql_text from  dba_hist_sqltext where SQL_ID='&sql_id';
