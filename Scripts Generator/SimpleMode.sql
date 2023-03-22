SELECT 'ALTER DATABASE ['+ name +'] SET RECOVERY SIMPLE WITH NO_WAIT
GO' 
FROM sys.databases
WHERE recovery_model_desc = 'FULL'
AND name NOT IN ('master', 'tempdb', 'msdb', 'model');
