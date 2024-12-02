### Gerando um Usuário Órfão
O primeiro script cria um novo login chamado "Usuario_Teste" no banco de dados `master` com uma senha e configurações específicas (sem expiração de senha e sem políticas de senha). Em seguida, no banco de dados `dirceuresende`, é criado um usuário chamado "Usuario_Orfao" associado ao login "Usuario_Teste". Após isso, o login "Usuario_Teste" é removido, deixando o usuário "Usuario_Orfao" órfão, sem um login associado.

### Gerando um Usuário Sem Login
Neste trecho, é criado um usuário chamado "Usuario_Sem_Login" no banco de dados `dirceuresende` sem um login associado, utilizando a opção `WITHOUT LOGIN`. A consulta `SELECT * FROM sys.database_principals` é executada para listar os usuários no banco de dados.

### Como Identificar um Usuário Órfão
O script apresenta duas maneiras de identificar usuários órfãos. A primeira usa a stored procedure `sp_change_users_login` com o parâmetro `'Report'`, que identifica e retorna os usuários órfãos. A segunda consulta utiliza as tabelas `sys.sysusers` e `sys.syslogins` para buscar usuários cujo SID não esteja associado a nenhum login, indicando que o usuário está órfão. Além disso, a segunda consulta garante que o usuário tenha permissões de `db_owner` e não seja um sistema predefinido (como "sa").

### Como Resolver um Problema de Usuário Órfão
O script seguinte oferece soluções para resolver o problema de um usuário órfão. A primeira solução usa a stored procedure `sp_change_users_login` com o parâmetro `'Auto_Fix'` para associar automaticamente o login ao usuário órfão. Em seguida, outra opção é associar o login manualmente ao usuário com o comando `'Update_One'`, e a última solução cria um novo login com o mesmo nome do usuário órfão e associa esse login ao usuário com uma senha definida.

### Como Resolver um Problema de Usuário Órfão em Toda Instância
Esse trecho apresenta um script que resolve o problema de usuários órfãos em toda a instância de SQL Server. O processo começa criando uma tabela temporária para armazenar os usuários órfãos, depois insere os dados dos usuários órfãos de todos os bancos de dados da instância utilizando a stored procedure `sp_MSforeachdb`. Após isso, os comandos necessários para corrigir os usuários órfãos em cada banco de dados são concatenados e executados. O script executa os comandos de correção em todos os bancos da instância, associando o login ao usuário órfão.

### Simulando um Ataque
Por fim, o script simula uma situação de ataque. Ele começa exibindo os usuários e seus SIDs no banco de dados `dirceuresende`. Em seguida, cria um novo login com um SID específico (copiado de um usuário órfão) e associa esse login ao papel de `db_owner`, permitindo o acesso completo ao banco de dados. Este tipo de ataque visa ilustrar o risco de usuários órfãos com SIDs conhecidos serem associados a novos logins maliciosos.

Este conjunto de scripts é essencial para gerenciar usuários órfãos no SQL Server, corrigir problemas relacionados e proteger a instância de possíveis riscos de segurança devido a usuários órfãos ou SIDs reutilizados maliciosamente.

```sql
------------------------------------------------
-- GERANDO UM USUÁRIO ÓRFÃO
------------------------------------------------
USE [master]
GO

CREATE LOGIN [Usuario_Teste] WITH PASSWORD=N'123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
```

```sql
USE [db]
GO

CREATE USER [Usuario_Orfao] FOR LOGIN [Usuario_Teste] WITH DEFAULT_SCHEMA=[dbo]
GO
```

```sql
USE [master]
GO

DROP LOGIN [Usuario_Teste]
GO
```

```sql
------------------------------------------------
-- GERANDO UM USUÁRIO SEM LOGIN
------------------------------------------------

USE [db]
GO

CREATE USER [Usuario_Sem_Login] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO

SELECT * FROM sys.database_principals
```

```sql
------------------------------------------------
-- COMO IDENTIFICAR UM USUÁRIO ÓRFÃO
------------------------------------------------

-- deprecated (https://docs.microsoft.com/pt-br/sql/database-engine/deprecated-database-engine-features-in-sql-server-2016?view=sql-server-2017)
USE [db]
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
```   
    
```sql 
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
```
   
```sql
------------------------------------------------
-- COMO RESOLVER UM PROBLEMA DE USUÁRIO ÓRFÃO
------------------------------------------------

USE [db]
GO

EXEC sp_change_users_login 'Auto_Fix', 'Usuario_Orfao' -- Isso irá associar o Login 'Usuario_Orfao' ao usuário 'Usuario_Orfao'
GO
```

```sql
USE [db]
GO

EXEC sp_change_users_login 
    'Update_One', 
    'Usuario_Orfao',  -- Usuário
    'Usuario_Teste'   -- Login
GO
```

```sql
USE [db]
GO

EXEC sp_change_users_login 
    'Auto_Fix', 
    'Usuario_Orfao',  -- Usuário
    NULL,             -- Login. Deixar NULL para criar um novo com o mesmo nome do usuário
    '123I*'             -- Senha do Login que será criado
GO

```sql
-- Azure SQL Database
ALTER USER [Usuario_Orfao] WITH LOGIN = [Usuario_Orfao]
```

```sql
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
```

```sql
-- Exibindo os usuários órfãos da instância
SELECT * FROM #Usuarios_Orfaos
```

```sql
-- Executando os comandos no banco
DECLARE @Comando VARCHAR(MAX) = ''

SELECT @Comando += Command + '; '
FROM #Usuarios_Orfaos

EXEC(@Comando)
```

```sql
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
```

```sql
------------------------------------------------
-- SIMULANDO UM ATAQUE
------------------------------------------------
USE [master]
GO

-- Observa o SID
SELECT * FROM db.sys.database_principals

-- Cria um login + usuário que será db_owner e depois excluir o login

-- Cria um novo login usando o mesmo SID do usuário órfão
CREATE LOGIN [Usuario_Com_Create_Login] WITH PASSWORD = '123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF, SID = 0xE87D6E8E142C8045A47EE4207D4C3111
GO
```