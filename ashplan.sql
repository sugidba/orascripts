col OBJECT_NAME for a30
col operation for a45
col event for a30
SELECT ash.sql_plan_line_id,
       ash.sql_plan_operation||' '||ash.sql_plan_options operation,
       p.object_name,event,count(*),
       round(100*COUNT(*)/
          sum(count(1)) over(), 2) "% time"
FROM gv$active_session_history ash,
        gv$sql_plan p
WHERE ash.sql_id = p.sql_id
AND ash.sql_plan_hash_value = p.plan_hash_value
AND ash.sql_plan_line_id = P.id
AND ash.sql_id = '&&sql_id'
GROUP BY ASH.SQL_PLAN_LINE_ID,
         ash.sql_plan_operation||' '||ash.sql_plan_options,
         p.object_name,event
ORDER BY count(*) DESC;
