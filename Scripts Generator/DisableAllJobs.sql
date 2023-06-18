SELECT 'exec msdb.dbo.sp_update_job @job_name = '''+name+''', @enabled = 0
GO'
FROM msdb.dbo.sysjobs
