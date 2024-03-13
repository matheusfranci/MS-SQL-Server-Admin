
USE [dirceuresende]
GO

DROP USER IF EXISTS [teste]
GO

CREATE USER [teste] FOR LOGIN [teste] WITH DEFAULT_SCHEMA=[dbo]
GO










SELECT
    A.[name],
    A.principal_id,
    A.[type_desc],
    A.default_schema_name,
    A.create_date,
    A.modify_date
FROM
    sys.database_principals A WITH(NOLOCK)
    LEFT JOIN sys.database_role_members B WITH(NOLOCK) ON A.principal_id = B.member_principal_id
    LEFT JOIN sys.database_permissions C WITH(NOLOCK) ON A.principal_id = C.grantee_principal_id AND C.[permission_name] <> 'CONNECT' AND C.[state] = 'G'
WHERE
    B.member_principal_id IS NULL
    AND C.grantee_principal_id IS NULL
    AND A.is_fixed_role = 0
    AND A.principal_id > 4




/*

NO SQLCMD

sqlcmd -S localhost\sql2017 -d dirceuresende -U teste -P aaa

select @@version
go

select user_name()
go

select name from sys.databases
go

select name from sys.all_objects
go


*/
	
    
