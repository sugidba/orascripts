DECLARE
    v_sql_id        VARCHAR2(20) := '&SQL_ID';
    v_sql_text      CLOB;
    v_hint_sql      CLOB;
    v_filename      VARCHAR2(100) := 'hint_test_cost_' || v_sql_id || '.txt';

    v_file          UTL_FILE.FILE_TYPE;
    v_hint_file     UTL_FILE.FILE_TYPE;

    -- Plan metrics
    v_cost          NUMBER;
    v_cardinality   NUMBER;
    v_bytes         NUMBER;

    v_line          VARCHAR2(4000);

    CURSOR c_sql IS
        SELECT sql_fulltext
        FROM gv$sql
        WHERE sql_id = v_sql_id
        AND rownum = 1;

    TYPE t_hints IS TABLE OF VARCHAR2(200);
    l_hints t_hints := t_hints();   -- empty init

BEGIN
    ------------------------------------------------------------------
    -- 1. READ HINTS FROM FILE (hints.txt)
    ------------------------------------------------------------------
    v_hint_file := UTL_FILE.FOPEN('SUGIDIR', 'hints.txt', 'R');

    LOOP
        BEGIN
            UTL_FILE.GET_LINE(v_hint_file, v_line);
            l_hints.EXTEND;
            l_hints(l_hints.COUNT) := TRIM(v_line);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                EXIT;
        END;
    END LOOP;

    UTL_FILE.FCLOSE(v_hint_file);

    ------------------------------------------------------------------
    -- 2. OPEN OUTPUT FILE
    ------------------------------------------------------------------
    v_file := UTL_FILE.FOPEN('SUGIDIR', v_filename, 'W');

    ------------------------------------------------------------------
    -- 3. FETCH SQL TEXT
    ------------------------------------------------------------------
    OPEN c_sql;
    FETCH c_sql INTO v_sql_text;
    CLOSE c_sql;

    IF v_sql_text IS NULL THEN
        UTL_FILE.PUT_LINE(v_file, 'SQL_ID not found');
        UTL_FILE.FCLOSE(v_file);
        RETURN;
    END IF;

    ------------------------------------------------------------------
    -- 4. LOOP THROUGH HINTS
    ------------------------------------------------------------------
    FOR i IN 1 .. l_hints.COUNT LOOP
        BEGIN
            -- Inject hint
            v_hint_sql := REGEXP_REPLACE(
                v_sql_text,
                'SELECT',
                'SELECT /*+ ' || l_hints(i) || ' */',
                1, 1, 'i'
            );

            EXECUTE IMMEDIATE 'DELETE FROM plan_table';

            -- Explain plan
            EXECUTE IMMEDIATE 'EXPLAIN PLAN FOR ' || v_hint_sql;

            -- Get metrics
            SELECT cost, cardinality, bytes
            INTO v_cost, v_cardinality, v_bytes
            FROM plan_table
            WHERE id = 0;

            -- Write output
            UTL_FILE.PUT_LINE(v_file, '========================================');
            UTL_FILE.PUT_LINE(v_file, 'HINT: ' || l_hints(i));
			UTL_FILE.PUT_LINE(v_file, '----------------------------------------');
            UTL_FILE.PUT_LINE(v_file, 'COST       : ' || v_cost);
            UTL_FILE.PUT_LINE(v_file, 'ROWS       : ' || v_cardinality);
            UTL_FILE.PUT_LINE(v_file, 'BYTES      : ' || v_bytes);
			UTL_FILE.PUT_LINE(v_file, '----------------------------------------');
            UTL_FILE.PUT_LINE(v_file, 'SQL:');
            UTL_FILE.PUT_LINE(v_file, DBMS_LOB.SUBSTR(v_hint_sql, 32000, 1));
			UTL_FILE.PUT_LINE(v_file, '----------------------------------------');
            UTL_FILE.PUT_LINE(v_file, 'PLAN:');

            FOR r IN (
                SELECT plan_table_output
                FROM TABLE(
                    DBMS_XPLAN.DISPLAY(
                        'PLAN_TABLE',
                        NULL,
                        '+COST -PREDICATE -PARALLEL'
                    )
                )
            ) LOOP
                UTL_FILE.PUT_LINE(v_file, r.plan_table_output);
            END LOOP;

        EXCEPTION
            WHEN OTHERS THEN
                UTL_FILE.PUT_LINE(v_file, 'ERROR with hint: ' || l_hints(i));
                UTL_FILE.PUT_LINE(v_file, SQLERRM);
        END;
    END LOOP;

    UTL_FILE.FCLOSE(v_file);

    DBMS_OUTPUT.PUT_LINE('File generated: ' || v_filename);
END;
/
