SELECT 'EXEC msdb.dbo.sp_update_job @job_name='''+name+''', 
@enabled = 1
GO'
FROM msdb.dbo.sysjobs
