BREAK ON inst_id SKIP 1 ON sid SKIP 1
COLUMN value_pct FORMAT  999.9 HEADING "VALUE %"
col sid for 99999
SELECT
    stm.inst_id,
    stm.sid,
    stm.stat_name,
    stm.value,
    ROUND(
        100 * stm.value /
        NULLIF(SUM(stm.value) OVER (PARTITION BY stm.inst_id, stm.sid), 0),
        2
    ) AS value_pct
FROM gv$sess_time_model stm
JOIN gv$session s
  ON stm.sid = s.sid
 AND stm.inst_id = s.inst_id
WHERE
s.sql_id='&sql_id' 
--s.username = 'username'
  AND stm.value != 0
ORDER BY
    stm.inst_id ASC,
    stm.sid ASC,
    stm.value DESC;
CLEAR BREAKS;
