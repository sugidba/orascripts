col OWNER  for a25                                 
col SYNONYM_NAME    for a30  
col TABLE_OWNER  for a20                                                                                                                      
 col TABLE_NAME   for a30               
col  DB_LINK  for a30      
select * from dba_synonyms where synonym_name like UPPER('%&object_name%'); 
