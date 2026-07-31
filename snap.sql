select systimestamp from dual;
 create table t as select * from gv$active_session_history where sample_time > sysdate-1/12;
