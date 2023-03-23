SELECT 
 DATEPART(MONTH,backup_finish_date) AS [BackupMonth] ,
 (AVG(msdb.dbo.backupset.backup_size)/1048576) as [BackupSize (MB)] ,
DATEPART(YEAR,backup_finish_date)  AS [BackupYear],
msdb.dbo.backupset.database_name
FROM msdb.dbo.backupmediafamily 
INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
WHERE  msdb..backupset.type='D' 
AND database_name='Adventureworks'
and DATEPART(YEAR,backup_finish_date)=DATEPART(YEAR,GETDATE())
GROUP BY msdb.dbo.backupset.database_name 
, DATEPART(MONTH,backup_finish_date) ,
DATEPART(YEAR,backup_finish_date) 
order by  
 DATEPART(MONTH,backup_finish_date)
 Asc
