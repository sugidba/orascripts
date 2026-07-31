SELECT
    t.inst_id,
    s.sid,
    s.serial#,
    s.username,
    s.program,
    t.xidusn AS undo_segment_number,
    t.ubafil AS undo_file_number,
    t.ubablk AS undo_block_number,
    sq.sql_id AS source_sql_id,
    sq.sql_text AS source_sql_text
FROM
    gv$transaction t
JOIN
    gv$session s ON t.ses_addr = s.saddr AND t.inst_id = s.inst_id
JOIN
    gv$sql sq ON s.sql_address = sq.address AND s.sql_hash_value = sq.hash_value
WHERE
    t.xidusn IN (
        SELECT
            DISTINCT t.xidusn
        FROM
            gv$transaction t
        JOIN
            gv$session s ON t.ses_addr = s.saddr AND t.inst_id = s.inst_id
        JOIN
            gv$sql sq ON s.sql_address = sq.address AND s.sql_hash_value = sq.hash_value
        WHERE
            sq.sql_id = '&sql_id'
    )
ORDER BY
    t.inst_id, s.username;
