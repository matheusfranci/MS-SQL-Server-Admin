SELECT 'USE ['+ db.name +']
GO
EXEC sp_updatestats
GO'
FROM sys.databases db 
WHERE db.name NOT IN ('master', 'msdb', 'tempdb', 'model');
