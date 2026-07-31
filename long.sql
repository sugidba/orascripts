SELECT inst_id,sid, serial#, sql_id, opname, username, sofar, totalwork,round(time_remaining/60,2) "REMAIN MINS", round(elapsed_seconds/60,2) "ELAPSED MINS",
 round((time_remaining+elapsed_seconds)/60,2) "TOTAL MINS", ROUND(SOFAR/nullif(TOTALWORK,0)*100,2) "%_COMPLETE"
FROM gv$session_longops
WHERE OPNAME NOT LIKE 'RMAN%' AND OPNAME NOT LIKE '%aggregate%' and sql_id='&&sql_id';
