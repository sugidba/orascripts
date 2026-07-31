col action_time for a28
col action for a8
col comments for a30
col status for a30
set line 999 pages 999
select patch_id,  status, Action,TARGET_VERSION,Action_time from dba_registry_sqlpatch order by action_time;
