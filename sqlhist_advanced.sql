prompt ==================================================================
prompt  use SQL-DEVELOPER . because format is too big
prompt ==================================================================
select 
    instance_number as inst,
    (snap_id - 1) as Begin_Snap_id,
    to_char(sn.begin_interval_time,'dd.mm hh24:mi') as begin_snap_time,
    round(st.executions_delta) as execs,
    OPTIMIZER_MODE,
	VERSION_COUNT,
	MODULE,
	FORCE_MATCHING_SIGNATURE,
	PARSING_SCHEMA_NAME,
    st.rows_processed_delta as rows_processed,
    st.sql_id,
    st.plan_hash_value as plan,
    st.optimizer_cost as cost,
    round(st.parse_calls_delta/decode(st.executions_delta,0,1,st.executions_delta))                   as PARSE_PER_EXEC,
    round(st.elapsed_time_delta/decode(st.executions_delta,0,1,st.executions_delta))                    as ELA_PER_EXEC,
    round(st.cpu_time_delta/decode(st.executions_delta,0,1,st.executions_delta))                        as CPU_PER_EXEC,
    round(st.buffer_gets_delta/decode(st.executions_delta,0,1,st.executions_delta))                     as GETS_PER_EXEC,
    round(st.disk_reads_delta/decode(st.executions_delta,0,1,st.executions_delta))                      as disk_reads_per_exec,
    round(st.physical_read_bytes_delta/decode(st.executions_delta,0,1,st.executions_delta)/1024/1024)   as READ_MB_PER_EXEC,
    round(st.physical_read_requests_delta/decode(st.executions_delta,0,1,st.executions_delta))          as READS_PER_EXEC,
    round(st.physical_write_bytes_delta/decode(st.executions_delta,0,1,st.executions_delta)/1024/1024)  as WRITES_MB_PER_EXEC,
    round(st.physical_write_requests_delta/decode(st.executions_delta,0,1,st.executions_delta))         as WRITES_PER_EXEC,
    round(st.direct_writes_delta/decode(st.executions_delta,0,1,st.executions_delta))                   as DIRECT_WRITES_PER_EXEC,
    round(st.rows_processed_delta/decode(st.executions_delta,0,1,st.executions_delta))                  as ROWS_PER_EXEC,
    round(st.fetches_delta/decode(st.executions_delta,0,1,st.executions_delta))                         as FETCHES_PER_EXEC,
    round(st.iowait_delta/decode(st.executions_delta,0,1,st.executions_delta))                          as IOWAITS_PER_EXEC,
    round(st.clwait_delta/decode(st.executions_delta,0,1,st.executions_delta))                          as CLWAITS_PER_EXEC_uS,
    round(st.apwait_delta/decode(st.executions_delta,0,1,st.executions_delta))                          as APWAITS_PER_EXEC,
    round(st.ccwait_delta/decode(st.executions_delta,0,1,st.executions_delta))                          as CCWAITS_PER_EXEC,
    round(st.parse_calls_delta/decode(st.executions_delta,0,1,st.executions_delta))                     as PARSE_PER_EXEC,
    round(st.plsexec_time_delta/decode(st.executions_delta,0,1,st.executions_delta))                    as PLSQL_PER_EXEC,
    round(st.px_servers_execs_delta/decode(st.executions_delta,0,1,st.executions_delta))                as PX_PER_EXEC,
	round(st.IO_OFFLOAD_RETURN_BYTES_DELTA/decode(st.executions_delta,0,1,st.executions_delta))                as OFFLOAD_PER_EXEC
from dba_hist_sqlstat st join dba_hist_snapshot sn using(snap_id,instance_number)
where sql_id = '&sql_id'
-- and instance_number=5
-- and sn.begin_interval_time between  sysdate-20 and sysdate-1
 and sn.begin_interval_time >  sysdate-20 
--   and executions_delta > 0
order by snap_id, instance_number;
