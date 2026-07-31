SELECT event, 
       SUM(wait_time) / 1000000 AS total_wait_time_seconds, 
       COUNT(*) AS wait_count
FROM gv$active_session_history
WHERE inst_id=&inst_id 
and sample_time > SYSDATE - INTERVAL '5' MINUTE
GROUP BY event
ORDER BY total_wait_time_seconds DESC
FETCH FIRST 10 ROWS ONLY;
