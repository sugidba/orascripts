SELECT inst_id,
       SUM(CASE WHEN status = 'IN USE' THEN 1 ELSE 0 END) used,
       SUM(CASE WHEN status = 'AVAILABLE' THEN 1 ELSE 0 END) free,
       COUNT(*) total
FROM gv$px_process
GROUP BY inst_id order by 1;

set lines 1000 pages 9999
COL px_qcsid HEAD QC_SID FOR A13
COL px_instances FOR A100
COL px_username HEAD USERNAME FOR A25 WRAP

SELECT
    pxs.qcsid||','||pxs.qcserial# px_qcsid
  , pxs.qcinst_id
  , ses.username px_username
  , ses.sql_id
  , pxs.degree
  , pxs.req_degree
  , COUNT(*) slaves
  , COUNT(DISTINCT pxs.inst_id) inst_cnt
  , MIN(pxs.inst_id) min_inst
  , MAX(pxs.inst_id) max_inst
  --, LISTAGG ( TO_CHAR(pxs.inst_id) , ' ' ) WITHIN GROUP (ORDER BY pxs.inst_id) px_instances
FROM
    gv$px_session pxs
  , gv$session    ses
  , gv$px_process p
WHERE
    ses.sid     = pxs.sid
AND ses.serial# = pxs.serial#
AND p.sid       = pxs.sid
AND pxs.inst_id = ses.inst_id
AND ses.inst_id = p.inst_id
--
AND pxs.req_degree IS NOT NULL -- qc
GROUP BY
    pxs.qcsid||','||pxs.qcserial#
  , pxs.qcinst_id
  , ses.username
  , ses.sql_id
  , pxs.degree
  , pxs.req_degree
ORDER BY
 px_qcsid  
, slaves DESC
/
