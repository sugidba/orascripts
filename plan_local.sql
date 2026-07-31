set lines 750 pages 9999
SELECT * FROM table (DBMS_XPLAN.DISPLAY_CURSOR('&sql_id',&child,'ADVANCED'));
