-- Script to submit SQL_ID to Oracle SQL Tuning Advisor (DBMS_SQLTUNE).
-- Usage: @tune_sql_id [SQL ID]
--
-- e.g. @tune_sql_id dnrtsnqgfqzsz
-- @tune_sql_id dnrtsnqgfqzsz 10
--
-- Requires ADVISOR system privilege to run tuning task. Requires CREATE ANY SQL PROFILE to apply a profile.
-- http://docs.oracle.com/cd/E11882_01/appdev.112/e40758/d_sqltun.htm#ARPLS68383
--
-- If DBMS_SQLTUNE finds an improved plan the recommendations section will include a note like this:
--
-- SQL Profile Finding (see explain plans section below)
-- -----------------------------------------------------------------
-- A potentially better execution plan was found for this statement.
--
-- This script captures the recommendation and generates a PL/SQL block which it displays at the end, accompanied by a backout statement.
-- Copy and paste the generated statement onto the command line and execute it.
-- Execution plans will then include a note that the profile was applied. The profile can also be found in DBA_SQL_PROFILES.

set term off autoprint off
set define '&'

var minutes number
var taskname varchar2(50)
var recommendations clob
var plsql_call varchar2(4000)
var plsql_backout varchar2(4000)

store set sqlplus_settings.sql replace

col 1 new_value 1
col 2 new_value 2
select '' as "1", 0 as "2" from dual where 1=2;
def sql_id = '&1'
def minutes = '&2'

set term on
set feedback off
set verify off
set serverout on size 200000
set autotrace off
set autoprint off
set long 50000
set linesize 170 pagesize 999
set longchunksize 170
col recommendations format a120 word

exec dbms_lob.createtemporary(:recommendations, true);

begin
    if '&minutes' > 0 then
        :minutes := to_number('&minutes');
    else
        :minutes := 10;
    end if;

    dbms_output.put_line('Running tuning advisor for maximum of ' || :minutes || ' minute' || case when :minutes > 1 then 's' end || '.');
    dbms_output.put_line('Check progress using the following query:');
    dbms_output.new_line();
    dbms_output.put_line
    ( 'select * from dba_advisor_log where owner = ''' || user || '''' || chr(10) ||
    'and execution_start >= to_date(''' || to_char(sysdate,'YYYYMMDD HH24:MI:SS') || ''',''YYYYMMDD HH24:MI:SS'');' );
end;
/

declare
    k_sql_id constant v$sqlstats.sql_id%type := '&sql_id';
    k_taskname constant varchar2(50) := user || '_' || k_sql_id;
    v_task varchar2(30);
    v_priv_check integer := 0;
begin
    :taskname := k_taskname;
    select count(*) into v_priv_check
    from user_sys_privs p
    where p.privilege in ('ADVISOR','OEM_ADVISOR');

    if v_priv_check = 0 then
        :recommendations := 'ADVISOR or OEM_ADVISOR system privilege is required to use the DBMS_SQLTUNE tuning task procedures.';

    else
        -- Drop the task in case we are re-running for same SQL ID:
        -- (also double-checks for privilege)
        declare
            no_advisor_privs exception; pragma exception_init(no_advisor_privs, -13616);
            no_such_tuning_task exception; pragma exception_init(no_such_tuning_task, -13605);
        begin
            dbms_sqltune.drop_tuning_task(k_taskname);
        exception
            when no_advisor_privs then dbms_output.put_line('The current user has not been granted the ADVISOR privilege.');
            when no_such_tuning_task then null;
        end;

        -- Create a SQL Tuning task for our SQL...
        v_task :=
            dbms_sqltune.create_tuning_task
            ( sql_id => k_sql_id
            , time_limit => :minutes * 60
            , scope => 'COMPREHENSIVE'
            , task_name => k_taskname
            , description => 'Created on ' || to_char(sysdate,'YYYY-MM-DD HH24:MI') || ' using tune_sql_id.sql' );

        dbms_sqltune.execute_tuning_task(k_taskname);

        :recommendations := dbms_sqltune.report_tuning_task(k_taskname);

        if :recommendations like '%dbms_sqltune.accept_sql_profile%' then
            -- Parse out the call to DBMS_SQLTUNE:
            :plsql_call := 'exec' || ' ' || regexp_replace(regexp_substr(:recommendations,'dbms_sqltune.accept_sql_profile[^;]+;', 1,1,'n'),'\s+',' ');

            -- Add 'name' parameter reusing the task name as the profile name (otherwise it will be generated as e.g. SYS_SQLPROF_014afcf1d566c005):
            :plsql_call := replace(:plsql_call,');', ', name => ''' || k_taskname || ''');');
            :plsql_backout := 'exec dbms_sqltune.drop_sql_profile(''' || k_taskname || ''');';
        else
            :plsql_call := '[No SQL profile to apply]';
            :plsql_backout := '[No SQL profile to back out]';
        end if;
    end if;
end;
/

col spoolfile new_value spoolfile
select 'tuning_advice_'||:taskname||'.txt' as spoolfile from dual;
spool &spoolfile

set term on
set feed off

select :recommendations "Recommendations:" from dual;

set heading off

prompt
prompt Execute the following PL/SQL block to apply the recommended SQL profile:
select :plsql_call from dual;
prompt
prompt
prompt To back out this change, execute the following PL/SQL block:
select :plsql_backout from dual;
prompt
prompt Recommendations saved to file &spoolfile
spool off

set term off
begin
    dbms_lob.freetemporary(:recommendations);
end;
/

undefine 1
undefine sql_id
@sqlplus_settings.sql
set term on

