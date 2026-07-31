declare
my_report clob;
begin
 my_report := dbms_sqldiag.report_sql('&sql_id', directory=>'SUGIDIR', level=>'ALL');
end;
/
