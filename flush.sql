WITH FUNCTION flush_sqlid (
    hv IN NUMBER
) RETURN VARCHAR2 IS
BEGIN
    FOR i IN (SELECT address, hash_value
              FROM gv$sqlarea WHERE sql_id = '&sql_id')
    LOOP
        SYS.DBMS_SHARED_POOL.PURGE(i.address || ',' || i.hash_value, 'C');
    END LOOP;
    RETURN 'completed';
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'failed';
END;
SELECT * FROM TABLE(gv$(CURSOR(
    SELECT flush_sqlid(1)
    FROM v$database
)))
/
