set lines 750 pages 9999
col sample_end for a22
COL instance_number FOR 99 HEA 'Inst';
col FORCE_MATCHING_SIGNATURE for 999999999999999999999
col sql_profile for a30
select to_char(min(s.end_interval_time),'DD-MON-YYYY DY HH24:MI') sample_end
, s.instance_number
, q.sql_id
, q.plan_hash_value
, max(PX_SERVERS_EXECS_TOTAL) px
, round((sum(ELAPSED_TIME_delta)/greatest(sum(executions_delta),1)/1e6),1) ELA
, round(sum(ROWS_PROCESSED_DELTA)/greatest(sum(executions_delta),1),1) rows_exec
, round(sum(DISK_READS_delta)/greatest(sum(executions_delta),1),1) PIO
, q.FORCE_MATCHING_SIGNATURE
, q.sql_profile
 from dba_hist_sqlstat q, dba_hist_snapshot s , dba_hist_sqltext t
where q.sql_id=t.sql_id
and  t.dbid = s.dbid
and q.FORCE_MATCHING_SIGNATURE=&FORCE_MATCHING_SIGNATURE
and s.snap_id = q.snap_id
and s.dbid = q.dbid
and s.instance_number = q.instance_number
--and s.end_interval_time >= to_date(trim('01-jan-2021 00:00'),'dd-mon-yyyy hh24:mi')
--and s.begin_interval_time <= to_date(trim('22-jan-2025 19:18'),'dd-mon-yyyy hh24:mi')
--and substr(to_char(s.end_interval_time,'DD-MON-YYYY DY HH24:MI'),13,2) like '%hr24_filter.%'
group by s.snap_id
, s.instance_number
, q.sql_id
, q.plan_hash_value
, q.FORCE_MATCHING_SIGNATURE
, q.sql_profile
order by s.snap_id, q.sql_id, q.plan_hash_value;
