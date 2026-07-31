col OPERATION for a30
col ACCESS_PREDICATES for a30
col FILTER_PREDICATES for a30
col HINT_TEXT for a30
col OPTIONS for a30
col QBLOCK_NAME for a30
col OBJECT_NAME for a30
col OBJECT_ALIAS for a30

ACCEPT sql_id CHAR PROMPT 'Enter SQL_ID: '

WITH outline_data AS (
    SELECT 
        REGEXP_SUBSTR(hint, '[^ ]+', 1, 1) AS hint_type,
        hint AS hint_text,
        REGEXP_SUBSTR(hint, '"([^"]+)"@"([^"]+)"', 1, 1, NULL, 1) AS object_name,
        REGEXP_SUBSTR(hint, '@"([^"]+)"', 1, 1, NULL, 1) AS qblock_name
    FROM (
        SELECT 
            REGEXP_SUBSTR(plan_table_output, '([A-Z_]+\(.*?\))', 1, LEVEL) AS hint
        FROM 
            TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', NULL, 'OUTLINE'))
        CONNECT BY 
            LEVEL <= REGEXP_COUNT(plan_table_output, '([A-Z_]+\(.*?\))')
    )
)
SELECT 
    p.inst_id,
    p.sql_id,
    p.child_number,
    p.id AS plan_id,
    p.parent_id,
    p.operation,
    p.options,
    p.object_name,
    p.object_alias,
    p.qblock_name,
    p.access_predicates,
    p.filter_predicates,
    o.hint_text
FROM 
    gv$sql_plan p
LEFT JOIN outline_data o
ON (
    p.object_alias LIKE '%' || o.object_name || '%'
    AND p.qblock_name = o.qblock_name
)
WHERE 
    p.sql_id = '&sql_id'
ORDER BY 
    p.inst_id,
    p.child_number,
    p.id;

undef sql_id	
