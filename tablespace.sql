set pages 50000 lines 32767
col tablespace_name format a30
col TABLESPACE_NAME heading "Tablespace|Name"
col Allocated_size heading "Allocated|Size(GB)" form 99999999.99
col Current_size heading "Current|Size(GB)" form 99999999.99
col Used_size heading "Used|Size(GB)" form 99999999.99
col Available_size heading "Available|Size(GB)" form 99999999.99
col Pct_used heading "%Used (vs)|(Allocated)" form 99999999.99
select a.tablespace_name
        ,a.alloc_size/1024/1024/1024 Allocated_size
        ,a.cur_size/1024/1024/1024 Current_Size
        ,(u.used+a.file_count*65536)/1024/1024/1024 Used_size
        ,(a.alloc_size-(u.used+a.file_count*65536))/1024/1024/1024 Available_size
        ,((u.used+a.file_count*65536)*100)/a.alloc_size Pct_used
from dba_tablespaces t
        ,(select t1.tablespace_name
        ,nvl(sum(s.bytes),0) used
        from dba_segments s
        ,dba_tablespaces t1
         where t1.tablespace_name=s.tablespace_name(+)
         group by t1.tablespace_name) u
        ,(select d.tablespace_name
        ,sum(greatest(d.bytes,nvl(d.maxbytes,0))) alloc_size
        ,sum(d.bytes) cur_size
        ,count(*) file_count
        from dba_data_files d
        group by d.tablespace_name) a
where t.tablespace_name=u.tablespace_name
and t.tablespace_name=a.tablespace_name
and a.tablespace_name='&tablespace'
order by Pct_used desc
/
