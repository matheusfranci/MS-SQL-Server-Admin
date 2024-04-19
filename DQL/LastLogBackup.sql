SELECT   d.name,
         d.recovery_model_desc,
         MAX(b.backup_finish_date) AS last_backup_finish_date,
CASE 
WHEN b.type = 'L'
THEN 'Log Backup'
else 'Null'
END AS 'Backup_type'
FROM     master.sys.databases d
         LEFT OUTER JOIN msdb..backupset b
         ON       b.database_name = d.name
         AND      b.type          = 'L'
WHERE d.state_desc = 'ONLINE'
AND d.recovery_model_desc = 'FULL'
GROUP BY d.name, d.recovery_model_desc, b.type
ORDER BY backup_finish_date DESC
