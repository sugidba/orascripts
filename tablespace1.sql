set linesize 800 pagesize 400
column tablespace_name format a30
column "Size /Mb" format 99999999
column "Used /Mb" format 99999999
column "Free /Mb" format 99999999
column "% Used" format 999.99
column maxmb heading "Autoextend|Max /Mb" format 99999999
column autoxused heading "Autoextend|Max % Used" format 999.99
column cnt heading "# Files" format 999999
WITH ts_space as
  (select tablespace_name,sum(bytes) bytes,sum(greatest(maxbytes,bytes)) maxbytes,count(*) cnt
   from dba_data_files
   group by tablespace_name),
ts_free as
  (select tablespace_name,nvl(sum(bytes),0) bytes
   from dba_free_space
   group by tablespace_name)
select d.tablespace_name "Tablespace Name",
       d.bytes/1024/1024 "Size /Mb",
       (d.bytes-nvl(f.bytes,0))/1024/1024 "Used /Mb",
       nvl(f.bytes,0)/1024/1024 "Free /Mb",
       100*(d.bytes-nvl(f.bytes,0))/d.bytes "% Used",
       maxbytes/1024/1024 maxmb,
       100*(d.bytes-nvl(f.bytes,0))/d.maxbytes autoxused,
       cnt
from ts_space d, ts_free f
where d.tablespace_name=f.tablespace_name(+)
and d.tablespace_name in ('&tbs')
order by 1
/
