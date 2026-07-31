col end_interval_time for a23
SELECT 'HIST' source,
 --   snap_id,
    sql_id,
    plan_hash_value phv,
    end_interval_time,
    executions_delta ex,
    round(elapsed_time_delta /(nonzeroexecutions * 1000), 1) "Ela-ms",
    round(cpu_time_delta /(nonzeroexecutions * 1000), 1)     "C-ms",
    round(iowait_delta /(nonzeroexecutions * 1000), 1)       "IO-ms",
    round(buffer_gets_delta /(nonzeroexecutions * 1000), 1)  "Buff",
    round(disk_reads_delta /(nonzeroexecutions * 1000), 1)   "Disk",
    round(trunc(physical_write_bytes_delta /(nonzeroexecutions * 1024 * 1024)),
          1)                                                 "Wr-MB",
    round(trunc(physical_read_bytes_delta /(nonzeroexecutions * 1024 * 1024)),
          1)                                                 "Re-MB",
    round(rows_processed_delta /(nonzeroexecutions), 1)      "A-Rows"
FROM
    (
        SELECT
      --      ss.snap_id,
            ss.sql_id,
            ss.plan_hash_value,
            sn.end_interval_time,
            ss.executions_delta,
            CASE ss.executions_delta
                WHEN 0 THEN
                    1
                ELSE
                    ss.executions_delta
            END nonzeroexecutions,
            elapsed_time_delta,
            cpu_time_delta,
            iowait_delta,
            buffer_gets_delta,
            disk_reads_delta,
            physical_write_bytes_delta,
            physical_read_bytes_delta,
            rows_processed_delta
        FROM
            dba_hist_sqlstat  ss,
            dba_hist_snapshot sn
        WHERE
                ss.sql_id = '&&sql_id'
            AND ss.snap_id = sn.snap_id
            AND ss.instance_number = sn.instance_number
    )
WHERE
    elapsed_time_delta > 0
UNION ALL	
SELECT 'NOW' source,
 --   snap_id,
    sql_id,
    plan_hash_value phv,
    LAST_ACTIVE_TIME,
    executions ex,
    round(elapsed_time /(nonzeroexecutions * 1000), 1) "Ela-ms",
    round(cpu_time /(nonzeroexecutions * 1000), 1)     "C-ms",
    round(USER_IO_WAIT_TIME /(nonzeroexecutions * 1000), 1)       "IO-ms",
    round(buffer_gets /(nonzeroexecutions * 1000), 1)  "Buff",
    round(disk_reads /(nonzeroexecutions * 1000), 1)   "Disk",
    round(trunc(physical_write_bytes /(nonzeroexecutions * 1024 * 1024)),
          1)                                                 "Wr-MB",
    round(trunc(physical_read_bytes /(nonzeroexecutions * 1024 * 1024)),
          1)                                                 "Re-MB",
    round(rows_processed /(nonzeroexecutions), 1)      "A-Rows"
FROM
    (
        SELECT
      --      ss.snap_id,
            ss.sql_id,
            ss.plan_hash_value,
            ss.LAST_ACTIVE_TIME,
            ss.executions,
            CASE ss.executions
                WHEN 0 THEN
                    1
                ELSE
                    ss.executions
            END nonzeroexecutions,
            elapsed_time,
            cpu_time,
            USER_IO_WAIT_TIME,
            buffer_gets,
            disk_reads,
            physical_write_bytes,
            physical_read_bytes,
            rows_processed
        FROM
            gv$sqlarea_plan_hash  ss
        WHERE
                ss.sql_id = '&&sql_id'
    )
WHERE
    elapsed_time > 0
ORDER BY
    source,end_interval_time;
undef sql_id
