

--- 3 técnicas principais Ocultação, Restrição de Acesso e Criptografia
-- httpswww.dirceuresende.comblogsql-server-como-ocultar-os-databases-para-usuarios-nao-autorizados



SELECT 
    A.[name],
    A.[sid],
    A.[type_desc],
    A.is_disabled,
    B.[permission_name],
    B.state_desc
FROM
    sys.server_principals A
    JOIN sys.server_permissions B ON A.principal_id = B.grantee_principal_id
WHERE
    B.[permission_name] = 'VIEW ANY DATABASE'
    AND B.[state] IN ('G', 'W')












SELECT 
    A.[name],
    A.principal_id,
    A.create_date,
    A.modify_date,
    A.[type_desc],
    B.state_desc
FROM
    sys.server_principals A
    JOIN sys.server_permissions B ON A.principal_id = B.grantee_principal_id
WHERE
    B.[permission_name] = 'VIEW ANY DATABASE'
    AND B.[state] IN ('G', 'W')
    AND A.is_disabled = 0
    AND A.[type] NOT IN ('CERTIFICATE_MAPPED_LOGIN', 'WINDOWS_LOGIN', 'WINDOWS_GROUP')
    AND A.[name] = 'public'
ORDER BY
    1










USE [master]
GO
CREATE LOGIN [teste_view_any_database] WITH PASSWORD=N'teste123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

SELECT  FROM sys.databases
GO













REVOKE VIEW ANY DATABASE FROM [public]
GO





USE [dirceuresende]
GO

CREATE USER [teste_view_any_database] FOR LOGIN [teste_view_any_database]
GO

ALTER ROLE [db_datareader] ADD MEMBER [teste_view_any_database]
GO

ALTER ROLE [db_owner] ADD MEMBER [teste_view_any_database]
GO







ALTER AUTHORIZATION ON DATABASE[dirceuresende] TO [teste_view_any_database]
GO










USE [master]
GO

CREATE SERVER ROLE [Acesso_ViewAnyDatabase]
GO
 
GRANT VIEW ANY DATABASE TO [Acesso_ViewAnyDatabase]
GO
 
ALTER SERVER ROLE [Acesso_ViewAnyDatabase] ADD MEMBER [teste_view_any_database]
GO

ALTER SERVER ROLE [Acesso_ViewAnyDatabase] DROP MEMBER [teste_view_any_database]
GO









DENY VIEW ANY DATABASE TO [public]
GO
