select 'alter '||object_type||' '||owner||'."'||object_name||'" compile;'
from dba_objects
where status<>'VALID'
and object_type not in ('PACKAGE BODY','TYPE BODY','UNDEFINED','JAVA CLASS','SYNONYM')
union
select 'alter package '||owner||'.'||object_name||' compile body;'
from dba_objects
where status<>'VALID'
and object_type='PACKAGE BODY'
union
select 'alter type '||owner||'.'||object_name||' compile body;'
from dba_objects
where status<>'VALID'
and object_type='TYPE BODY'
union
select 'alter materialized view '||owner||'.'||object_name||' compile;'
from dba_objects
where status<>'VALID'
and object_type='UNDEFINED'
union
select 'alter java class '||owner||'."'||object_name||'" resolve;'
from dba_objects
where status<>'VALID'
and object_type='JAVA CLASS'
union
select 'alter synonym '||owner||'.'||object_name||' compile;'
from dba_objects
where status<>'VALID'
and object_type='SYNONYM'
and owner<>'PUBLIC'
union
select 'alter public synonym '||object_name||' compile;'
from dba_objects
where status<>'VALID'
and object_type='SYNONYM'
and owner='PUBLIC';
