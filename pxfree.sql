
SELECT inst_id,
       SUM(CASE WHEN status = 'IN USE' THEN 1 ELSE 0 END) used,
       SUM(CASE WHEN status = 'AVAILABLE' THEN 1 ELSE 0 END) free,
       COUNT(*) total
FROM gv$px_process
GROUP BY inst_id order by 1;
