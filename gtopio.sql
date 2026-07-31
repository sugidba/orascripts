    set feedback off echo off tab off trimout on trimspool on linesize 250 pagesize 1000 verify off
    col machine for a9 word_wrapped
    col module for a25 head MODULE trunc
    col AVG_SECS_PER_EXEC  for 99,999.99 heading 'Avg Secs|Per Exec'
    col CPU_PCT for 999.9 heading 'CPU PCT'
    col IO_PCT for 999.9 heading 'IO PCT'
    col EXECUTIONS for 999,999,999 heading 'Total Execs|Per SQL_ID'
    col OSUSER for a9 word_wrapped
    col TXT for a30 word_wrapped  heading 'TXT'
    col SQL for a100 heading SQL trunc
    col sess for a12 heading 'Active|SID:SERIAL#' justify center
    col username for a8
    col QC_SID for a10 heading 'PQ|SID:SERIAL#' justify center   
 prompt
    prompt #######################################################################
    prompt # Summary: Top 20 IO consuming  SQLIDs for last min_to_check minutes
    prompt #######################################################################
    --
    select distinct ash.inst_id, ash.sql_id,ash.io_pct,cc.module,replace(replace(substr(cc.sql_text,1,300),chr(10),' '),chr(13),' ') as SQL
    FROM
    (
    select
         inst_id, 
         sql_id,
         round(ratio_to_report (IO) over () *100,2) as io_pct
    from
    (
        select ash.inst_id, ash.sql_id,sum(decode(ash.session_state,'WAITING',decode(en.wait_class,'User I/O',1,0),0)) IO
        from gv$active_session_history ash , gv$event_name en
        where ash.sql_id is not null and en.event#=ash.event# and en.inst_id=ash.inst_id
        and ash.sample_time > sysdate - ((1/1440)* &min_to_check )
        group by ash.inst_id,sql_id
        order by 3 desc
    )
    where rownum < 21
    ) ash,
    gv$sqlarea cc
    where ash.sql_id  = cc.sql_id(+) and ash.inst_id=cc.inst_id(+)
    order by 3 desc
;
