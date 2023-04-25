SELECT 
'USE ['+b.name+']
GO
DBCC SHRINKDATABASE (N'''  + b.name +  ''' , 0)
GO'
FROM
sys.master_files as a
INNER JOIN sys.databases as b
on a.database_id = b.database_id
WHERE a.type_desc='LOG' and b.name not in('master', 'msdb', 'tempdb', 'model');
