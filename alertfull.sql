set lines 750 pages 9999
col MESSAGE_TEXT format A150
SELECT
    TO_CHAR(originating_timestamp,'DD.MM.YYYY HH24:MI:SS') date_and_time,
    inst_id,
    message_text
FROM
    TABLE ( gv$(CURSOR(
        SELECT
            *
        FROM
            x$dbgalertext x
        WHERE
            x.component_id = 'rdbms'
                        AND   originating_timestamp  >  sysdate-1
                       AND   (message_text LIKE '%ORA-%' OR message_text LIKE '%TNS-%' OR   lower(message_text) LIKE '%error%' OR lower(message_text) LIKE '%cannot%' OR    lower(message_text) LIKE '%warning%'  OR   lower(message_text) LIKE '%fatal%' OR message_text LIKE '%Parse%')
    ) ) )
ORDER BY
    originating_timestamp ASC;

select 'Curent time: '||TO_CHAR(sysdate,'DD.MM.YYYY HH24:MI:SS') from dual;
