SELECT 
'ALTER USER [' + name + '] WITH LOGIN = [' + name + ']
GO'
FROM sys.database_principals 
WHERE TYPE = 'S'
AND name NOT IN ('dbo', 'guest', 'INFORMATION_SCHEMA')
