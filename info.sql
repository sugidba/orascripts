set long 20000 longchunksize 20000 pagesize 9999 linesize 1000
col HOST_NAME for a35
col inst_id for 9
col db_unique_name for a10
col OPEN_MODE for a15
select d.inst_id,host_name,db_unique_name,open_mode,database_role,to_char(startup_time,'DD-MON-YYYY HH24:MI:SS') "DB Startup Time" ,(SELECT to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') FROM dual) "Current_time_db" ,
(select INSTANCE_NAME from v$instance) Connected_inst  from gv$database d,gv$instance i where d.inst_id=i.inst_id order by 1;
select con_id,NAME,OPEN_MODE,RESTRICTED,OPEN_TIME from gv$pdbs order by 1;
 col WRL_PARAMETER for a30
--select INST_ID,STATUS,WALLET_TYPE,WRL_TYPE,WRL_PARAMETER,WALLET_ORDER  from  gv$encryption_wallet;
