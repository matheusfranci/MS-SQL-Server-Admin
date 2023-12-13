
SELECT 'USE [msdb];
EXEC msdb.dbo.sp_update_job @job_id = N''' + CONVERT(VARCHAR(36), j.job_id) + ''', @owner_login_name = N''marcos.vinicius'';'
FROM
    msdb.dbo.sysjobs j
INNER JOIN
    master.dbo.syslogins s ON j.owner_sid = s.sid;
