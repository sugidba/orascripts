
col username for a15
col "QC SID" for A6
col "SID" for A6
col SPID for A7
col "QC/Slave" for A8
col "Req. DOP" for 9999
col "Actual DOP" for 9999
col "Slaveset" for A8
col "Slave INST" for A9
col "QC INST" for A6
col sql_id for a20
set pages 9999 lines 300
col wait_event format a30
col blocker format a10
alter session set nls_date_format='YYYY/MM/DD HH24:MI:SS';
select
decode(px.qcinst_id,NULL,username,
' – '||lower(substr(pp.SERVER_NAME,
length(pp.SERVER_NAME)-4,4) ) )"username",
decode(px.qcinst_id,NULL, 'QC', '(Slave)') "QC/Slave" ,
to_char(s.sid) "SID",
pp.spid,
to_char(px.inst_id) "Slave INST",
decode(sw.state,'WAITING', 'WAIT', 'NOT WAIT' ) as STATE,
s.sql_id,
--case  sw.state WHEN 'WAITING' THEN substr(sw.event,1,30) ELSE NULL end as wait_event ,
s.event as wait_event ,
BLOCKING_INSTANCE ||','|| blocking_session blocker,
s.SECONDS_IN_WAIT,s.status
from gv$px_session px,
gv$session s ,
gv$px_process pp,
gv$session_wait sw
where px.sid=s.sid (+)
and px.serial#=s.serial#(+)
and px.inst_id = s.inst_id(+)
and px.sid = pp.sid (+)
and px.serial#=pp.serial#(+)
and sw.sid = s.sid
and sw.inst_id = s.inst_id
order by
--decode(px.QCINST_ID,  NULL, px.INST_ID,  px.QCINST_ID),
px.QCSID,
decode(px.SERVER_GROUP, NULL, 0, px.SERVER_GROUP),
px.INST_ID;
