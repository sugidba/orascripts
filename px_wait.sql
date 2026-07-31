  column instance_number new_value m_inst
select instance_number from v$instance;
 
set linesize 120
set pagesize 60
set trimspool on
set tab off
set verify off

 
break -
        on qcsid skip 1 -
        on server_group -
        on degree -
        on server_set -
        on sid -
        on server# skip 1
 
column event format a32
 
column  qcsid           format a6       heading 'Coord'
column  server_group    format 999      heading 'Grp'
column  degree          format a5       heading 'Deg'   noprint
column  server_set      format 999      heading 'Set'   noprint
column  server#         format 999      heading 'Sno'
column  sid             format 9999     heading 'SID'
column  name            format a32      heading 'Statistic'
column  value           format 99,999,999       heading 'value'
 
select
        ss.qcsid || '/' || nvl(ss.qcinst_id,&m_inst)            qcsid,
        ss.server_group,
        decode(degree,
                null,null,
                ss.degree || '/' || ss.req_degree
        )       degree,
        ss.server_set,
        ss.server#,
        ss.sid,
        se.event,
        se.total_waits,
        se.time_waited
from
        v$px_session            ss,
        v$session_event         se
where
        se.sid = ss.sid
order by
        ss.qcsid,
        ss.server_group,
        ss.server_set,
        ss.server#,
        se.event
;
 
clear columns
clear breaks
set verify on
