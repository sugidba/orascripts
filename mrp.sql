select inst_id,PROCESS,STATUS,THREAD#,SEQUENCE#,BLOCK#,BLOCKS from gv$managed_standby where process like '%MRP%';
