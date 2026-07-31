col TABLESPACE_SIZE for 9999999999999999
col ALLOCATED_SPACE for 9999999999999999
col FREE_SPACE for 9999999999999999
 select tablespace_name , TABLESPACE_SIZE/1024/1024/1024 ,ALLOCATED_SPACE/1024/1024/1024,FREE_SPACE/1024/1024/1024 from DBA_TEMP_FREE_SPACE where tablespace_name='IND_ACC_TMP';

select sample_time,username,sql_id,trunc(temp_space_allocated/1024/1024/1024)  TEMP_USED_GB from gv$active_session_history d,dba_users u
where d.user_id=u.user_id
and sample_time between   to_date('2024/05/08 08:00:00','YYYY/MM/DD HH24:MI:SS') 
and to_date('2024/05/08 08:55:00','YYYY/MM/DD HH24:MI:SS')
and inst_id=2
and temp_space_allocated is not null
order by 4 desc;
