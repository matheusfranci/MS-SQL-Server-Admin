SELECT 'ALTER DATABASE ['+ name +'] SET OFFLINE
GO' 
FROM sys.databases
WHERE state_desc = 'ONLINE'
AND name NOT IN ('master', 'tempdb', 'msdb', 'model');
