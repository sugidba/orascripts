col segment_name for a40
select   segment_name,sum(bytes)/(1024*1024) "TABLE_SIZE(MB)" from dba_extents where   owner=upper('&OWNER') and segment_name =upper( '&SEGMENT_NAME') group by segment_name;
