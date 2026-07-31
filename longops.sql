set pages 50000 lines 32767
col OPNAME for a20
col SID form 9999
col SERIAL form 9999999
col PROGRAM for a10
col USERNAME for a20
col MESSAGE for a25
alter session set nls_date_format = 'DD-MM-YYYY HH24:MI:SS';
SELECT inst_id,sid, serial#, sql_id, opname, username, sofar, totalwork,round(time_remaining/60,2) "REMAIN MINS", round(elapsed_seconds/60,2) "ELAPSED MINS", round((time_remaining+elapsed_seconds)/60,2) "TOTAL MINS", ROUND(SOFAR/TOTALWORK*100,2) "%_COMPLETE"
FROM gv$session_longops
WHERE OPNAME NOT LIKE 'RMAN%' AND OPNAME NOT LIKE '%aggregate%' AND TOTALWORK != 0 AND sofar<>totalwork AND time_remaining > 0
/
