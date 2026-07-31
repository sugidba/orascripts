conn / as sysdba
col Parameter for  a30
col Default_Value for  a15
col Session_Value for a15
col Instance_Value for a15
SELECT a.ksppinm "Parameter", b.KSPPSTDF "Default_Value",
       b.ksppstvl "Session_Value", 
       c.ksppstvl "Instance_Value",
       decode(bitand(a.ksppiflg/256,1),1,'TRUE','FALSE') IS_SESSION_MODIFIABLE,
       decode(bitand(a.ksppiflg/65536,3),1,'IMMEDIATE',2,'DEFERRED',3,'IMMEDIATE','FALSE') IS_SYSTEM_MODIFIABLE
FROM   x$ksppi a,
       x$ksppcv b,
       x$ksppsv c
WHERE  a.indx = b.indx
AND    a.indx = c.indx
AND    a.ksppinm LIKE '/&parameter' escape '/';
