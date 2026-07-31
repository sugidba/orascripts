--
-- Show top sessions in terms of I/Os from ash in the last x mins
--

undef last_x_mins
@plusenv

col sql_id      format a13
col module      format a40 trunc
col cpu         format 999,999  head 'CPU'
col wait        format 999,999
col io          format 999,999  head '*IO*'
col tot         format 9,999,999        head 'TOT'
col pctcpu      format 999.9    head 'CPU%'
col pctio       format 999.9    head 'IO%'
col sidser      format a15              head 'Sid,Serial<Blk'
col opname      format a06      head 'SQL Op'   trunc
select   sidser
        ,module
        ,sql_id
        ,opname
        ,cpu
        ,100*ratio_to_report (cpu) over () pctcpu
        ,wait
        ,io
        ,100*ratio_to_report (io) over () pctio
        ,tot
from
(
select   lpad(ash.session_id,4,' ')||','||lpad(ash.session_serial#,5,' ')||decode(substr(ash.blocking_session_status,1,1),'V','<',' ')||lpad(ash.blocking_session,4,' ')     sidser
   --     ,nvl(ash.module,'['||u.username||'@'||substr(ash.machine,1,instr(ash.machine,'amazon')-2)||']')          module
		,(u.username||'-'||ash.module)          module
        ,ash.sql_id
        ,ash.sql_opname opname
        ,sum(decode(ash.session_state,'ON CPU',1,0))     cpu
        ,sum(decode(ash.session_state,'WAITING',1,0)) - sum(decode(ash.session_state,'WAITING',decode(en.wait_class, 'User I/O',1,0),0))    wait
        ,sum(decode(ash.session_state,'WAITING', decode(en.wait_class, 'User I/O',1,0),0))    io
        ,sum(decode(ash.session_state,'ON CPU',1,1))     tot
from     v$active_session_history       ash
        ,v$event_name                   en
        ,dba_users                      u
where    ash.session_type = 'FOREGROUND'
and      ash.event#=en.event# (+)
and      ash.user_id            = u.user_id
and      sample_time >= sysdate - &&last_x_mins/1440
group by lpad(ash.session_id,4,' ')||','||lpad(ash.session_serial#,5,' ')||decode(substr(ash.blocking_session_status,1,1),'V','<',' ')||lpad(ash.blocking_session,4,' ')
        ,(u.username||'-'||ash.module) 
        ,ash.module
        ,ash.sql_id
        ,ash.sql_opname
order by sum(decode(ash.session_state,'WAITING', decode(en.wait_class, 'User I/O',1,0),0)) desc
)
where rownum <=30
;
