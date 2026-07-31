select inst_id,sql_id,child_number,plan_hash_value,FULL_PLAN_HASH_VALUE,IS_REOPTIMIZABLE,IS_RESOLVED_ADAPTIVE_PLAN,sql_text 
from gv$sql where sql_id='&sql_id';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id',&child,'+ADAPTIVE'));
