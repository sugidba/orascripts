col inst_id for 999
col "Max Parallel Servers" for a10
col "Min Parallel Servers" for a10
col "Target Parallel Servers" for a10
col "Current PX Processes" for 999999
col "Busy PX Processes" for 999999
col "Available for New Queries" for 999999
col "CPU Count" for a10
col "Threads Per CPU" for a10
col "Default Max (CPU*Threads*2)" for 999999
col "Instance Name" for a15

WITH parallel_config AS (
    SELECT 
        inst_id,
        MAX(CASE WHEN name = 'parallel_max_servers' THEN value END) as max_servers,
        MAX(CASE WHEN name = 'parallel_min_servers' THEN value END) as min_servers,
        MAX(CASE WHEN name = 'parallel_servers_target' THEN value END) as target_servers,
        MAX(CASE WHEN name = 'cpu_count' THEN value END) as cpu_count,
        MAX(CASE WHEN name = 'parallel_threads_per_cpu' THEN value END) as threads_per_cpu
    FROM gv$parameter
    GROUP BY inst_id
),
current_usage AS (
    SELECT 
        inst_id,
        COUNT(*) as total_px_processes,
        SUM(CASE WHEN status = 'BUSY' THEN 1 ELSE 0 END) as busy_processes
    FROM gv$px_process
    GROUP BY inst_id
)
SELECT 
    pc.inst_id,
--    i.instance_name as "Instance Name",
    pc.max_servers as "Max Parallel Servers",
    pc.min_servers as "Min Parallel Servers",
    pc.target_servers as "Target Parallel Servers",
    NVL(cu.total_px_processes, 0) as "Current PX Processes",
    NVL(cu.busy_processes, 0) as "Busy PX Processes",
    pc.max_servers - NVL(cu.busy_processes, 0) as "Available for New Queries",
    pc.cpu_count as "CPU Count",
    pc.threads_per_cpu as "Threads Per CPU",
    pc.cpu_count * pc.threads_per_cpu * 2 as "Default Max (CPU*Threads*2)"
FROM parallel_config pc
LEFT JOIN current_usage cu ON pc.inst_id = cu.inst_id
LEFT JOIN gv$instance i ON pc.inst_id = i.inst_id
ORDER BY pc.inst_id;
