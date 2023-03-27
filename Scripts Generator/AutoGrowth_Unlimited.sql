SELECT 
'USE master
GO
ALTER DATABASE [' + b.name + '] MODIFY FILE (NAME = N'''  + a.name +  ''', MAXSIZE = UNLIMITED, FILEGROWTH = 262144KB )
GO'
FROM
sys.master_files as a
INNER JOIN sys.databases as b
on a.database_id = b.database_id
WHERE a.type_desc='LOG' and b.name not in('master', 'msdb', 'tempdb', 'model');
