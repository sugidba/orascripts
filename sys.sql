conn / as sysdba
select db_unique_name,instance_name,open_mode from v$database,v$instance;
set lines 750 pages 9999 verify off time on
set exitcommit OFF
