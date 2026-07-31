SELECT DBMS_STATS.get_prefs('INCREMENTAL', '&OWNER_NAME', '&TABLE_NAME') AS incremental_stats FROM dual;
