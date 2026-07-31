set pages 0 linesize 32767 trimspool on trim on long 1000000 longchunksize 10000000
spool perfhub_active.html
select dbms_perf.report_perfhub(is_realtime=>1,type=>'active') from dual;
spool off
