col name for a30
col time for a30
set lines 750
select NAME,TIME,GUARANTEE_FLASHBACK_DATABASE,STORAGE_SIZE/1024/1024/1024 "GB_USED" from v$restore_point order by 2;
