select NAME,value from  v$DATAGUARD_STATS where name in ('transport lag','apply lag');
PROMPT RFS CHECK-Execute Multiple Times
SELECT INST_ID,CLIENT_PROCESS, PROCESS,PID OS_SPID, THREAD#, SEQUENCE#,block#, blocks, STATUS FROM
GV$MANAGED_STANDBY WHERE  PROCESS in ('RFS','MRP0')  and status <> 'IDLE' order by THREAD#,SEQUENCE# ;
