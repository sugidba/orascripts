break on inst_id skip 1
col WAIT_CLASS for a20
col avg_wait    format 999.9            head 'Avg|Wait|ms'
SELECT inst_id,
       event, 
       wait_class, 
       cnt, 
       percentage,
	   avg_wait
FROM (
    SELECT NVL(event, 'CPU') AS event, 
           NVL(wait_class, 'CPU') AS wait_class, 
           COUNT(*) AS cnt,  
           100 * TRUNC(RATIO_TO_REPORT(COUNT(*)) OVER (PARTITION BY inst_id), 6) AS percentage,
		   sum(time_waited)/count(*)/1000  avg_wait,
           inst_id
    FROM gv$active_session_history
    WHERE sample_time > SYSDATE - &last_x_min/1440
     -- AND inst_id IN (1, 2)
    GROUP BY event, wait_class,  inst_id
) 
WHERE percentage > 1
ORDER BY inst_id, cnt DESC;
