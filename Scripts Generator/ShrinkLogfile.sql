SELECT 
'USE ['+b.name+']
GO
DBCC SHRINKFILE (N'''  + a.name +  ''' , 0)
GO'
FROM
sys.master_files as a
INNER JOIN sys.databases as b
on a.database_id = b.database_id
WHERE a.type_desc='LOG' and b.name not in('master', 'msdb', 'tempdb', 'model');




SELECT 
'USE ['+b.name+']
GO
CHECKPOINT
GO
DBCC SHRINKFILE (N'''  + a.name +  ''' , 0)
GO'
FROM
sys.master_files as a
INNER JOIN sys.databases as b
on a.database_id = b.database_id
WHERE a.type_desc='LOG' and b.name not in('master', 'msdb', 'tempdb', 'model');
