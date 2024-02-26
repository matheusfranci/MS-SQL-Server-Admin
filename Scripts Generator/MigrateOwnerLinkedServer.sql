SELECT '
USE [msdb]
GO
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N''' + name + ''', @locallogin = NULL , @useself = N''False'', @rmtuser = N''Conta.Jobs'', @rmtpassword = N''teste''
GO
'
FROM sys.servers
WHERE name not in (@@servername);
