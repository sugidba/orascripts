 col owner for a30
 col index_name for a30
 col TABLE_NAME for a30
col NUM_ROWS for 9999999999999999999999 
   select owner,index_name,TABLE_NAME,PARTITIONED,
   --status,
   blevel,LEAF_BLOCKS,NUM_ROWS,LAST_ANALYZED from dba_indexes
   where 
   index_name like '&INDEX_NAME';
