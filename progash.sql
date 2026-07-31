col sample_time for a26
col TOP_LEVEL_CALL_NAME for a10
col SQL_PLAN_LINE_ID for 999
col SQL_PLAN_OPTIONS for a30
select sample_time,top_level_sql_id,event,top_level_call_name,sql_plan_line_id,sql_plan_options
from gv$active_session_history 
where sql_id='&&sql_id' 
order by sample_time desc 
fetch first 5 rows only;
