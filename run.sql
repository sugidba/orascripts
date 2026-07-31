set lines 1000 pages 9999
column sid format 9999
column serial for 999999
column I for 9
col px for 99
col p_rq for 99999
col p_al for 99999
column status format a15
column username format a25
column sql_text format a40
column module format a30
col program for a30
col SQL_EXEC_START for a20

       SELECT inst_id I,sid,SESSION_SERIAL# as Serial,username,sql_id,SQL_PLAN_HASH_VALUE PHV,px_maxdop px,
	   px_servers_requested p_rq,
      px_servers_allocated p_al,
         TO_CHAR(sql_exec_start,'dd-mon-yyyy hh24:mi:ss') AS sql_exec_start,
         ROUND(elapsed_time/1000000)                      AS "Ela(s)",
--         ROUND(cpu_time    /1000000)                      AS "CPU (s)",
         substr(sql_text,1,30) sql_text
       FROM gv$sql_monitor where status='EXECUTING'
       AND username is not null
       ORDER BY username;
