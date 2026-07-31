select STATUS, COUNT(*) from gv$sql_monitor where sql_id = '&sql_id' GROUP BY STATUS order by status;
