col event for a50
select
    event,
    time_waited "time_waited(s)",
    case when time_waited = 0 then 
        0
    else
        round(time_waited*100 / sum(time_waited) Over(), 2)
    end "percentage"
from
    (
        select event, sum(time_waited) time_waited
        from gv$active_session_history
        where sql_id = '&&sql_id'
        group by event
    )
order by
    time_waited desc; 
