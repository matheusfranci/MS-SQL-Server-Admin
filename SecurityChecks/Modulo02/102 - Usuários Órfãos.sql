
------------------------------------------------
-- GERANDO UM USUÁRIO ÓRFÃO
------------------------------------------------

USE [master]
GO

CREATE LOGIN [Usuario_Teste] WITH PASSWORD=N'123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

USE [dirceuresende]
GO

CREATE USER [Usuario_Orfao] FOR LOGIN [Usuario_Teste] WITH DEFAULT_SCHEMA=[dbo]
GO

USE [master]
GO

DROP LOGIN [Usuario_Teste]
GO

------------------------------------------------
-- GERANDO UM USUÁRIO SEM LOGIN
------------------------------------------------

USE [dirceuresende]
GO

CREATE USER [Usuario_Sem_Login] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO

SELECT * FROM sys.database_principals



------------------------------------------------
-- COMO IDENTIFICAR UM USUÁRIO ÓRFÃO
------------------------------------------------

-- deprecated (https://docs.microsoft.com/pt-br/sql/database-engine/deprecated-database-engine-features-in-sql-server-2016?view=sql-server-2017)
USE [dirceuresende]
EXEC sp_change_users_login 'Report'



SELECT
    A.name AS UserName,
    A.[sid] AS UserSID
FROM
    sys.sysusers A WITH(NOLOCK)
    LEFT JOIN sys.syslogins B WITH(NOLOCK) ON A.[sid] = B.[sid]
WHERE
    A.issqluser = 1 
    AND SUSER_NAME(A.[sid]) IS NULL 
    AND IS_MEMBER('db_owner') = 1 
    AND A.[sid] != 0x00
    AND A.[sid] IS NOT NULL 
    AND ( LEN(A.[sid]) <= 16 ) 
    AND B.[sid] IS NULL
ORDER BY
    A.name
    
    
    
SELECT
    A.name AS UserName,
    A.[sid] AS UserSID
FROM
    sys.database_principals A WITH(NOLOCK)
    LEFT JOIN sys.sql_logins B WITH(NOLOCK) ON A.[sid] = B.[sid]
    --JOIN sys.server_principals C WITH(NOLOCK) ON A.[name] COLLATE SQL_Latin1_General_CP1_CI_AI = C.[name] COLLATE SQL_Latin1_General_CP1_CI_AI
WHERE
    A.principal_id > 4
    AND B.[sid] IS NULL
    AND A.is_fixed_role = 0
    --AND C.is_fixed_role = 0
    AND A.name NOT LIKE '##MS_%'
    AND A.[type_desc] = 'SQL_USER'
    --AND C.[type_desc] = 'SQL_LOGIN'
    AND A.name NOT IN ('sa')
    AND A.authentication_type <> 0 -- NONE
ORDER BY
    A.name
    
    
   

------------------------------------------------
-- COMO RESOLVER UM PROBLEMA DE USUÁRIO ÓRFÃO
------------------------------------------------

USE [dirceuresende]
GO

EXEC sp_change_users_login 'Auto_Fix', 'Usuario_Orfao' -- Isso irá associar o Login 'Usuario_Orfao' ao usuário 'Usuario_Orfao'
GO


USE [dirceuresende]
GO

EXEC sp_change_users_login 
    'Update_One', 
    'Usuario_Orfao',  -- Usuário
    'Usuario_Teste'   -- Login
GO


USE [dirceuresende]
GO

EXEC sp_change_users_login 
    'Auto_Fix', 
    'Usuario_Orfao',  -- Usuário
    NULL,             -- Login. Deixar NULL para criar um novo com o mesmo nome do usuário
    '123I*'             -- Senha do Login que será criado
GO


-- Azure SQL Database
ALTER USER [Usuario_Orfao] WITH LOGIN = [Usuario_Orfao]



------------------------------------------------
-- COMO RESOLVER UM PROBLEMA DE USUÁRIO ÓRFÃO EM TODA INSTÂNCIA
------------------------------------------------

-- Identificando todos os usuários órfãos da instância
IF (OBJECT_ID('tempdb..#Usuarios_Orfaos') IS NOT NULL) DROP TABLE #Usuarios_Orfaos
CREATE TABLE #Usuarios_Orfaos (
    [Ranking] INT IDENTITY(1,1),
    [Database] sysname,
    [Username] sysname,
    [SID] UNIQUEIDENTIFIER,
    [Command] VARCHAR(MAX)
)

INSERT INTO #Usuarios_Orfaos
EXEC master.dbo.sp_MSforeachdb '
SELECT
    ''?'' AS [database],
    A.name,
    A.[sid],
    ''EXEC [?].[sys].[sp_change_users_login] ''''Auto_Fix'''', '''''' + A.name + '''''''' AS command
FROM
    [?].sys.database_principals A WITH(NOLOCK)
    LEFT JOIN [?].sys.sql_logins B WITH(NOLOCK) ON A.[sid] = B.[sid]
    JOIN sys.server_principals C WITH(NOLOCK) ON A.[name] COLLATE SQL_Latin1_General_CP1_CI_AI = C.[name] COLLATE SQL_Latin1_General_CP1_CI_AI
WHERE
    A.principal_id > 4
    AND B.[sid] IS NULL
    AND A.is_fixed_role = 0
    AND C.is_fixed_role = 0
    AND A.name NOT LIKE ''##MS_%''
    AND A.[type_desc] = ''SQL_USER''
    AND C.[type_desc] = ''SQL_LOGIN''
    AND A.name NOT IN (''sa'')
    AND A.authentication_type <> 0 -- NONE
ORDER BY
    A.name'


-- Exibindo os usuários órfãos da instância
SELECT * FROM #Usuarios_Orfaos


-- Executando os comandos no banco
DECLARE @Comando VARCHAR(MAX) = ''

SELECT @Comando += Command + '; '
FROM #Usuarios_Orfaos

EXEC(@Comando)








-- Identificando todos os usuários órfãos da instância
IF (OBJECT_ID('tempdb..#Usuarios_Orfaos') IS NOT NULL) DROP TABLE #Usuarios_Orfaos
CREATE TABLE #Usuarios_Orfaos (
    [Ranking] INT IDENTITY(1,1),
    [Database] sysname,
    [Username] sysname,
    [SID] UNIQUEIDENTIFIER,
    [Command] VARCHAR(MAX)
)

INSERT INTO #Usuarios_Orfaos
EXEC master.dbo.sp_MSforeachdb '
SELECT
    ''?'' AS [database],
    A.name,
    A.[sid],
    ''USE [?]; ALTER USER ['' + A.[name] + ''] WITH LOGIN = ['' + A.[name] + '']'' AS command
FROM
    [?].sys.database_principals A WITH(NOLOCK)
    LEFT JOIN [?].sys.sql_logins B WITH(NOLOCK) ON A.[sid] = B.[sid]
    JOIN sys.server_principals C WITH(NOLOCK) ON A.[name] COLLATE SQL_Latin1_General_CP1_CI_AI = C.[name] COLLATE SQL_Latin1_General_CP1_CI_AI
WHERE
    A.principal_id > 4
    AND B.[sid] IS NULL
    AND A.is_fixed_role = 0
    AND C.is_fixed_role = 0
    AND A.[type_desc] = ''SQL_USER''
    AND C.[type_desc] = ''SQL_LOGIN''
    AND A.authentication_type <> 0 -- NONE
ORDER BY
    A.name'

SELECT * FROM #Usuarios_Orfaos


------------------------------------------------
-- SIMULANDO UM ATAQUE
------------------------------------------------
USE [master]
GO

-- Observa o SID
SELECT * FROM dirceuresende.sys.database_principals

-- Cria um login + usuário que será db_owner e depois excluir o login

-- Cria um novo login usando o mesmo SID do usuário órfão
CREATE LOGIN [Usuario_Com_Create_Login] WITH PASSWORD = '123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF, SID = 0xE87D6E8E142C8045A47EE4207D4C3111
GO

