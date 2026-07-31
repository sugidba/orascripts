col owner for a40
col segment_name for a30
col partition_name for a30
SELECT owner,segment_name,partition_name,bytes/1024/1024 "MB" FROM dba_segments WHERE segment_type = 'TABLE PARTITION'
and segment_name= '&&TABLE_NAME' and OWNER='&&OWNER' and partition_name='&&partition_name'
order  by 1;
