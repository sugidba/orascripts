var B1 varchar2(250)
var B2 varchar2(250)
var B3 varchar2(250)
var B4 varchar2(250)
var B5 varchar2(250)
var B6 varchar2(250)
var B7 varchar2(250)
var B8 varchar2(250)
var B9 varchar2(250)
var B10 varchar2(250)
var B11 varchar2(250)



exec :B1  := 'SYSTEM_RELEASED';
exec :B2  := 'RELEASED';
exec :B3  := TO_DATE('05/22/2026 02:35:26', 'MM/DD/YYYY HH24:MI:SS');
exec :B4  := '0';
exec :B5  := '1';
exec :B6  := 'TBP';
exec :B7  := '';
exec :B8  := '';
exec :B9  := '';
exec :B10 := '';
exec :B11 := '';

OR

VAR P_RUN_DT VARCHAR2(128)
VAR P_REPORT_NAME VARCHAR2(128)
VAR P_ASSOCINVID VARCHAR2(32)

BEGIN
  :P_RUN_DT       := DATE '2026-06-01';
  :P_REPORT_NAME  := 'PMS-017_EXCEL';
  :P_ASSOCINVID   := NULL;
END;
/


NOTE:
for explain plan for no need to change like mentioned below , incase if you want to execute then only modify the sql as mentioned below

Required only for execution
================================
incase of query contains   TRUNC(:B3 )
change it to TRUNC(TO_DATE(:B3, 'MM/DD/YYYY HH24:MI:SS'))      <----  check the dd-mm-yyyy format accordingly

(OR)

OTHER OPTIONS OF declaring below

VARIABLE P_RUN_DT VARCHAR2(128)
EXEC :P_RUN_DT := '01-11-2025';

SQL> select TO_DATE(:P_RUN_DT,'DD-MM-YYYY') from dual;

TO_DATE(:P_RUN_DT,'
-------------------
2025/11/01 00:00:00

----------------------


VARIABLE P_RUN_DT VARCHAR2(128)
EXEC :P_RUN_DT := '2025-11-01T00:00:00Z';

select to_timestamp_tz(:P_RUN_DT,'YYYY-MM-DD"T"HH24:MI:SS"Z"') from dual;

TO_TIMESTAMP_TZ(:P_RUN_DT,'YYYY-MM-DD"T"HH24:MI:SS"Z"')
---------------------------------------------------------------------------
01-NOV-25 00.00.00.000000000 +00:00

----------------------


VARIABLE P_RUN_DT VARCHAR2(50)

EXEC :P_RUN_DT := '2025-11-01T00:00:00Z';

select TRUNC(
         CAST(
           TO_TIMESTAMP_TZ(:P_RUN_DT,'YYYY-MM-DD"T"HH24:MI:SS"Z"')
           AS TIMESTAMP
         )
       )
from dual;

TRUNC(CAST(TO_TIMES
-------------------
2025/11/01 00:00:00

----------------------

if your original variable looks like this then

VARIABLE P_RUN_DT TIMESTAMP
P_RUN_DT TIMESTAMP      := 787D0B01010101;  --HEXDUMP

convert hex to date 2025-11-01T00:00:00Z

if it contains Z then timestamp with timezone

original query contains

	and TO_DATE(TO_CHAR(:P_RUN_DT,'DD-MM-YYYY'),'DD-MM-YYYY') >= NVL(RS.VALID_FROM, '01-JAN-1900')
	and TO_DATE(TO_CHAR(:P_RUN_DT,'DD-MM-YYYY'),'DD-MM-YYYY') < NVL(RS.VALID_TO, '01-JAN-2400')

Then change the query directly like below 

select TO_DATE(TO_CHAR(to_timestamp_tz('2025-11-01T00:00:00Z','YYYY-MM-DD"T"HH24:MI:SS"Z"'),'DD-MM-YYYY'),'DD-MM-YYYY') from dual;

TO_DATE(TO_CHAR(TO_
-------------------
2025/11/01 00:00:00


