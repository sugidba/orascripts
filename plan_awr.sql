set lines 750 pages 9999
SELECT * FROM table (DBMS_XPLAN.DISPLAY_AWR(sql_id => '&sql_id',format=>'ADVANCED'));
--SELECT * FROM table (DBMS_XPLAN.DISPLAY_AWR(sql_id => '&sql_id'));
