
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
