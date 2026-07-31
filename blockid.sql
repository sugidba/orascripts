select /*+ PARALLEL(8) */
 c.owner,
 c.segment_name,
 c.PARTITION_NAME,
 c.segment_type
 from
  dba_extents c
 where
    c.file_id = &file_id
    and &blockid between block_id AND block_id + blocks - 1;
