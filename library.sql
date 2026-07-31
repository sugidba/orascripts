select kglnaown, kglnaobj from x$kglob where kglhdadr in ( select kgllkhdl from x$kgllk where kgllkreq >0);


column  sql_text format a70
column KGLNAOBJ format a20
select ses.sid, ses.serial#,lck.kgllkcnt, lck.kgllkmod,lck.kgllkreq, lck.kglnaobj, s.sql_id
  from x$kgllk lck , v$session ses, v$sqlarea s
  where kgllkhdl in
     (select kgllkhdl from x$kgllk where kgllkreq >0)
  and lck.KGLLKUSE = ses.saddr
  and ses.sql_id = s.sql_id;

  col type for a30
 col OBJECT_NAME for a30
 select to_char(SESSION_ID,'9999') sid ,
substr(LOCK_TYPE,1,30) Type,
substr(lock_id1,1,23) Object_Name,
substr(mode_held,1,4) HELD, substr(mode_requested,1,4) REQ,
lock_id2 Lock_addr
from dba_lock_internal
where
mode_requested<>'None'
and mode_requested<>mode_held
and session_id in ( select sid
from v$session_wait where wait_time=0
and event like '%library cache%') ;


select sid Holder ,KGLPNUSE Sesion , KGLPNMOD Held, KGLPNREQ Req
from x$kglpn , v$session
where KGLPNHDL in (select p1raw from v$session_wait
where wait_time=0 and event like '%library cache%')
and KGLPNMOD <> 0
and v$session.saddr=x$kglpn.kglpnuse ;


select a.sid Holder ,a.SERIAL#,b.INST_ID,b.KGLPNUSE Sesion , b.KGLPNMOD Held, b.KGLPNREQ Req
from x$kglpn b , v$session a
where b.KGLPNHDL in (select p1raw from v$session_wait
where wait_time=0 and event like 'library cache%')
and b.KGLPNMOD <> 0
and a.saddr=b.kglpnuse ;

SELECT s.sid,
waiter.p1raw w_p1r,
holder.event h_wait,
holder.p1raw h_p1r,
holder.p2raw h_p2r,
holder.p3raw h_p2r,
count(s.sid) users_blocked,
sql.hash_value
FROM
v$sql sql,
v$session s,
x$kglpn p,
v$session_wait waiter,
v$session_wait holder
WHERE
s.sql_hash_value = sql.hash_value and
p.kglpnhdl=waiter.p1raw and
s.saddr=p.kglpnuse and
waiter.event like 'library cache pin' and
holder.sid=s.sid
GROUP BY
s.sid,
waiter.p1raw ,
holder.event ,
holder.p1raw ,
holder.p2raw ,
holder.p3raw ,
sql.hash_value;

select decode(lob.kglobtyp,
0, 'NEXT OBJECT ',
1, 'INDEX ',
2, 'TABLE ',
3, 'CLUSTER ',
4, 'VIEW ',
5, 'SYNONYM ',
6, 'SEQUENCE ',
7, 'PROCEDURE ',
8, 'FUNCTION ',
9, 'PACKAGE ',
11, 'PACKAGE BODY ',
12, 'TRIGGER ',
13, 'TYPE ',
14, 'TYPE BODY ',
19, 'TABLE PARTITION ',
20, 'INDEX PARTITION ',
21, 'LOB ',
22, 'LIBRARY ',
23, 'DIRECTORY ',
24, 'QUEUE ',
28, 'JAVA SOURCE ',
29, 'JAVA CLASS ',
30, 'JAVA RESOURCE ',
32, 'INDEXTYPE ',
33, 'OPERATOR ',
34, 'TABLE SUBPARTITION ',
35, 'INDEX SUBPARTITION ',
40, 'LOB PARTITION ',
41, 'LOB SUBPARTITION ',
42, 'MATERIALIZED VIEW ',
43, 'DIMENSION ',
44, 'CONTEXT ',
46, 'RULE SET ',
47, 'RESOURCE PLAN ',
48, 'CONSUMER GROUP ',
51, 'SUBSCRIPTION ',
52, 'LOCATION ',
55, 'XML SCHEMA ',
56, 'JAVA DATA ',
57, 'SECURITY PROFILE ',
59, 'RULE ',
62, 'EVALUATION CONTEXT ',
'UNDEFINED ') object_type,
lob.kglnaobj object_name,
pn.kglpnmod lock_mode_held,
pn.kglpnreq lock_mode_requested,
ses.sid,
ses.serial#,
ses.username
from sys.v$session_wait vsw,
sys.x$kglob lob,
sys.x$kglpn pn,
sys.v$session ses
where vsw.event = 'library cache lock '
and vsw.p1raw = lob.kglhdadr
and lob.kglhdadr = pn.kglpnhdl
and pn.kglpnmod != 0
and pn.kglpnuse = ses.saddr
/



col handle for a30

select sid Waiter, p1raw,
substr(rawtohex(p1),1,30) Handle,
substr(rawtohex(p2),1,30) Pin_addr
from gv$session_wait where wait_time=0 and event like 'library cache%';


select
 distinct
   ses.ksusenum sid, ses.ksuseser serial#, ses.ksuudlna username,ses.ksuseunm machine,
   ob.kglnaown obj_owner, ob.kglnaobj obj_name
   ,pn.kglpncnt pin_cnt, pn.kglpnmod pin_mode, pn.kglpnreq pin_req
   , w.state, w.event, w.wait_Time, w.seconds_in_Wait
   -- lk.kglnaobj, lk.user_name, lk.kgllksnm,
   --,lk.kgllkhdl,lk.kglhdpar
   --,trim(lk.kgllkcnt) lock_cnt, lk.kgllkmod lock_mode, lk.kgllkreq lock_req,
   --,lk.kgllkpns, lk.kgllkpnc,pn.kglpnhdl
 from
  x$kglpn pn,  x$kglob ob,x$ksuse ses 
   , v$session_wait w
where pn.kglpnhdl in
(select kglpnhdl from x$kglpn where kglpnreq >0 )
and ob.kglhdadr = pn.kglpnhdl
and pn.kglpnuse = ses.addr
and w.sid = ses.indx
order by seconds_in_wait desc
/

select /*+ ordered */ w1.sid  waiting_session,
         h1.sid  holding_session,
         w.kgllktype lock_or_pin,
         w.kgllkhdl address,
         decode(h.kgllkmod,  0, 'None', 1, 'Null', 2, 'Share', 3, 'Exclusive',
            'Unknown') mode_held,
         decode(w.kgllkreq,  0, 'None', 1, 'Null', 2, 'Share', 3, 'Exclusive',
          'Unknown') mode_requested
   from dba_kgllock w, dba_kgllock h, v$session w1, v$session h1
  where
   (((h.kgllkmod != 0) and (h.kgllkmod != 1)
      and ((h.kgllkreq = 0) or (h.kgllkreq = 1)))
    and
      (((w.kgllkmod = 0) or (w.kgllkmod= 1))
      and ((w.kgllkreq != 0) and (w.kgllkreq != 1))))
   and  w.kgllktype      =  h.kgllktype
   and  w.kgllkhdl =  h.kgllkhdl
   and  w.kgllkuse     =   w1.saddr
   and  h.kgllkuse     =   h1.saddr;
