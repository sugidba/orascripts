set lines 750 pages 9999
break on report
compute SUM of tot on report
compute SUM of active on report
compute SUM of inactive on report
col username for a50
select DECODE(username,NULL,'INTERNAL',USERNAME) Username,
       count(*) TOT,
       COUNT(DECODE(status,'ACTIVE',STATUS)) ACTIVE,
       COUNT(DECODE(status,'INACTIVE',STATUS)) INACTIVE
from gv$session
where status in ('ACTIVE','INACTIVE')
group by username order by username;
