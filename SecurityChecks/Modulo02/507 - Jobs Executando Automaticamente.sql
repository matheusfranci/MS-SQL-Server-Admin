
SELECT 
	*
FROM 
	msdb.dbo.sysjobs A
	JOIN msdb.dbo.sysjobschedules B ON B.job_id = A.job_id
	JOIN msdb.dbo.sysschedules C ON C.schedule_id = B.schedule_id
WHERE
	C.freq_type = 64 -- Start automatically when SQL Server Agent starts
