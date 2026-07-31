select distinct error from gv$archive_dest ;

set lines 1000 pages 9999
select to_char(START_TIME,'DD-MON-YYYY HH24:MI:SS') "Recovery Start Time",to_char(item)||' = '||to_char(sofar)||' '||to_char(units) "Progress"
from v$recovery_progress where start_time=(select max(start_time) from v$recovery_progress);
 
select inst_id,PROCESS,STATUS,THREAD#,SEQUENCE#,BLOCK#,BLOCKS from gv$managed_standby where process like '%MRP%';


set lines 160
col STBY_BEHIND_BY for a20
select (select sysdate from dual)"TIMESTAMP",s.thread#,s.MAX_SEQ#, a.MAX_APP_SEQ#, ' '||(s.MAX_SEQ#-a.MAX_APP_SEQ#)||' sequences' "STBY_BEHIND_BY" from 
( select thread#,max(sequence#) "MAX_SEQ#" from v$archived_log where activation#=(select activation# from v$database) group by thread# ) s,
(select thread#,max(sequence#) "MAX_APP_SEQ#" from v$archived_log where activation#=(select activation# from v$database )and applied='YES' group by thread#) a where a.thread#=s.thread#;
