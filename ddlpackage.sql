SELECT line,
       text
FROM all_source
WHERE name = upper('&package_name')
AND type IN ('PACKAGE', 'PACKAGE BODY','PROCEDURE')
ORDER BY type, line;
