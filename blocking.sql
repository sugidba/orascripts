 set lines 750 pages 9999
col blocking_status for a100 
 select s1.inst_id,s2.inst_id,s1.username || '@' || s1.sql_id || ' ( SID=' || s1.sid || ' )  is blocking '
 || s2.username || '@' || s2.sql_id || ' ( SID=' || s2.sid || ' ) ' AS blocking_status , round(s2.seconds_in_wait/60)||' mins' Blocking_mins
  from gv$lock l1, gv$session s1, gv$lock l2, gv$session s2
  where s1.sid=l1.sid and s2.sid=l2.sid and s1.inst_id=l1.inst_id and s2.inst_id=l2.inst_id
  and l1.BLOCK=1 and l2.request > 0
  and l1.id1 = l2.id1
  and l2.id2 = l2.id2
order by s1.inst_id;


