Select
decode(px.qcinst_id,NULL,username,
' – '||lower(substr(pp.SERVER_NAME,
length(pp.SERVER_NAME)-4,4) ) )"Username",
decode(px.qcinst_id,NULL, 'QC', '(Slave)') "QC/Slave" ,
to_char( px.server_set) "SlaveSet",
to_char(px.inst_id) "Slave INST",
substr(opname,1,30)  operation_name,
substr(target,1,30) target,
sofar,
totalwork,
units,
start_time,
timestamp,
decode(px.qcinst_id, NULL ,to_char(s.sid) ,px.qcsid) "QC SID",
to_char(px.qcinst_id) "QC INST"
from gv$px_session px,
gv$px_process pp,
gv$session_longops s
where px.sid=s.sid
and px.serial#=s.serial#
and px.inst_id = s.inst_id
and px.sid = pp.sid (+)
and px.serial#=pp.serial#(+)
order by
decode(px.QCINST_ID,  NULL, px.INST_ID,  px.QCINST_ID),
px.QCSID,
decode(px.SERVER_GROUP, NULL, 0, px.SERVER_GROUP),
px.SERVER_SET,
px.INST_ID
/
