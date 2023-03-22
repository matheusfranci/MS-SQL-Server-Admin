SELECT
'ALTER LOGIN [' + loginname + '] ENABLE
GO'
FROM syslogins
WHERE name not IN ('siga', 'sa', 'S2\matheussantos.orion') and name not like '%#%' and name not like '%sis.%';
