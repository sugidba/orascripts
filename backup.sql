set lines 750
col sid for a15
col username for a10
col ela for 99999999 
col opname for a40
SELECT inst_id||','||SID||','||serial# sid, username,opname, TO_CHAR (start_time, 'DD-MON-YYYY HH24:MI:SS') start_time,
sofar, totalwork, elapsed_seconds ela, time_remaining, ROUND (sofar / totalwork * 100, 2) "%done" FROM gv$session_longops WHERE time_remaining > 0 and username='SYSBACKUP' order by 1;

COL client_info FORMAT A30 TRUNC
col sid for 9999999
COL event FORMAT A35
COL state FORMAT A20
COL wait FORMAT 999.90 HEAD "Min waiting"
SELECT p.inst_id,s.sid, p.spid, s.client_info, status, event, state, seconds_in_wait/60 wait
  FROM gv$process p, gv$session s
 WHERE p.addr = s.paddr
AND p.inst_id=s.inst_id
   AND client_info LIKE 'rman%';

select STATUS, COUNT(*) from gv$session where program like 'rman%' and osuser not like 'delp%' GROUP BY STATUS order by status;

