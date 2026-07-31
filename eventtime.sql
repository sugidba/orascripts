col program for a40
col i for 9
col event for a50
col sid for 9999
select e.inst_id I,e.sid,s.sql_id,s.program,e.event,e.time_waited_micro/1000000 time_sec,s.status from gv$session_event e , gv$session s
where e.inst_id=s.inst_id
and e.sid=s.sid
and s.sql_id='&&sql_id'
--and s.program not like 'oracle%'
and e.time_waited_micro/1000000 > 9
order by time_waited_micro desc;
