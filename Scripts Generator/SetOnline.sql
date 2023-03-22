SELECT 'ALTER DATABASE ['+ name +'] SET ONLINE
GO' 
FROM sys.databases
WHERE state_desc = 'OFFLINE'
AND name NOT IN ('master', 'tempdb', 'msdb', 'model');
