
-- Como alterar o modo de autenticação utilizando T-SQL
USE [master]
GO

EXEC sys.xp_instance_regwrite 
	N'HKEY_LOCAL_MACHINE', 
	N'Software\Microsoft\MSSQLServer\MSSQLServer', 
	N'LoginMode', 
	REG_DWORD, 
	2 -- 1 = Windows Authentication / 2 = Windows and SQL Server Authentication (Mixed Mode)


-- Como identificar o modo de autenticação pela função SERVERPROPERTY
SELECT
    CASE SERVERPROPERTY('IsIntegratedSecurityOnly')
		WHEN 1 THEN 'Windows Authentication' 
		WHEN 0 THEN 'Windows and SQL Server Authentication' 
	END AS [Authentication Mode]


-- Como identificar o modo de autenticação pelo Registro do Windows
DECLARE @AuthenticationMode INT

EXEC master.dbo.xp_instance_regread 
	N'HKEY_LOCAL_MACHINE', 
	N'Software\Microsoft\MSSQLServer\MSSQLServer',   
	N'LoginMode',
	@AuthenticationMode OUTPUT  

SELECT @AuthenticationMode


-- Como identificar o tipo de cada login
SELECT [name], [type], [type_desc]
FROM sys.server_principals
WHERE is_fixed_role = 0
AND [type] NOT IN ('C', 'R') -- CERTIFICATE_MAPPED_LOGIN / SERVER_ROLE

