--conn / as sysdba 
alter session set nls_date_format='YYYY/MM/DD HH24:MI:SS';
-- select SID,sql_id,sql_exec_id, sql_exec_start,otherstat_2_value,qksxareasons reason_for_downgrade
--from GV$SQL_PLAN_MONITOR m, x$qksxa_reason x where m.otherstat_2_value= indx and indx in (select indx from x$qksxa_reason where qksxareasons like '%DOP downgrade%')  order by sql_exec_start;


select SID,sql_id,sql_exec_id, sql_exec_start,otherstat_2_value,
case otherstat_2_value
when 352 then 'DOP downgrade due to adaptive DOP'
when 353 then 'DOP downgrade due to resource manager max DOP'
when 354 then 'DOP downgrade due to insufficient number of processes'
when 355 then 'DOP downgrade because workers failed to join'
end reason_for_downgrade
from GV$SQL_PLAN_MONITOR where sql_id = '&sql_id'
 and otherstat_2_value in (350,351,352,353,354,355);
