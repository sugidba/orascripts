SELECT
    e.evh_event
  , e.evh_millisec
  , e.evh_sample_count
  , e.evh_est_event_count
  , e.evh_est_total_sec
  , ROUND ( 100 * RATIO_TO_REPORT(evh_est_total_sec) OVER (PARTITION BY evh_event) , 1 ) pct_evt_time
  , '|'||RPAD(NVL(RPAD('#', ROUND (10 * RATIO_TO_REPORT(evh_est_total_sec) OVER (PARTITION BY evh_event)), '#'),' '), 10)||'|' evh_graph
  , first_seen
  , last_seen
FROM (
    SELECT 
        event evh_event
      , LPAD('< ' || CASE WHEN time_waited = 0 THEN 0 ELSE CEIL(POWER(2,CEIL(LOG(2,time_waited/1000)))) END, 15) evh_millisec
      , COUNT(*)  evh_sample_count
      , ROUND(SUM(CASE WHEN time_waited >= 1000000 THEN 1 WHEN time_waited = 0 THEN 0 ELSE 1000000 / time_waited END),1) evh_est_event_count
      , ROUND(CASE WHEN time_waited = 0 THEN 0 ELSE CEIL(POWER(2,CEIL(LOG(2,time_waited/1000)))) END * SUM(CASE WHEN time_waited >= 1000000 THEN 1 WHEN time_waited = 0 THEN 0 ELSE 1000000 / time_waited END) / 1000,1) evh_est_total_sec
      , TO_CHAR(MIN(sample_time), 'YYYY-MM-DD HH24:MI:SS') first_seen
      , TO_CHAR(MAX(sample_time), 'YYYY-MM-DD HH24:MI:SS') last_seen
    FROM 
        gv$active_session_history 
    WHERE 
        regexp_like(event, '&event') 
		AND sql_id='&sql_id'
		AND sample_time > SYSDATE - INTERVAL '5' MINUTE
    AND session_state = 'WAITING' -- not really needed as "event" for ON CPU will be NULL in ASH, but added just for clarity
    AND time_waited > 0 
    GROUP BY 
        event
      , CASE WHEN time_waited = 0 THEN 0 ELSE CEIL(POWER(2,CEIL(LOG(2,time_waited/1000)))) END -- evh_millisec
) e
ORDER BY
    evh_event
  , evh_millisec
/
