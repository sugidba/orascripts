set lines 300
 set pages 300
col NUM_ROWS for 9999999999999999999999
col table_name for a40
col owner for a30 
col partition_name for a30
select distinct owner, table_name, STALE_STATS, last_analyzed, stattype_locked,NUM_ROWS,PARTITION_NAME
  from dba_tab_statistics
  where table_name=upper('&table_name') AND PARTITION_NAME IS NULL;
