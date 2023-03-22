SELECT 'ALTER DATABASE ['+ name +'] SET RECOVERY FULL WITH NO_WAIT
GO' 
FROM sys.databases
WHERE recovery_model_desc = 'SIMPLE'
AND name NOT IN ('master', 'tempdb', 'msdb', 'model');
