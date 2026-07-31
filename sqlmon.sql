col exec_start format a25
col process    format a10
col status     format a15
select
    -- sql_id
    sql_exec_id   
   ,to_char(sql_exec_start,'dd/mm/yyyy hh24:mi:ss') exec_start
--   ,to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') current_time  
 ,sql_id  
 ,process_name process
   ,round((sysdate-sql_exec_start) * 60 * 24,2) "minutes"
   ,round(elapsed_time/1e6,3) "elaps(sec)"
   ,round(cpu_time/1e6,3) "cpu(sec)"
   ,sql_plan_hash_value   "plan hash value"
   ,status
from gv$sql_monitor
where
  sql_id = '&sql_id'
order by process_name;
