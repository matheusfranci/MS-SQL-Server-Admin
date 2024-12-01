# Descrição do Script

Este script é utilizado para **identificar usuários órfãos** em uma instância SQL Server. Usuários órfãos são aqueles que existem em bancos de dados, mas não possuem logins associados no servidor. O script realiza as seguintes etapas:

## 1. **Criação da Tabela Temporária**

Uma tabela temporária chamada `#Usuarios_Orfaos` é criada para armazenar as informações dos usuários órfãos, incluindo:
- Nome do banco de dados.
- Nome do usuário.
- SID (Security Identifier) do usuário.
- O comando `ALTER USER` que pode ser usado para associar o usuário ao seu login.

## 2. **Identificação de Usuários Órfãos**

O script usa o procedimento armazenado `sp_MSforeachdb` para iterar por todos os bancos de dados da instância. Para cada banco, ele verifica:
- Usuários do tipo `SQL_USER` que não têm um login correspondente na tabela `sys.sql_logins`.
- O script busca por usuários que não pertencem a funções fixas nem no banco de dados nem no servidor.

Para cada usuário órfão identificado, o script gera um comando `ALTER USER` que pode ser utilizado para associar o login ao usuário.

## 3. **Exibição dos Resultados**

Após identificar os usuários órfãos, o script exibe os resultados na tabela temporária `#Usuarios_Orfaos`, mostrando as informações dos usuários encontrados e o comando necessário para corrigi-los.

Este script é útil para gerenciar a integridade de usuários e logins no SQL Server, identificando e permitindo a correção de associações ausentes entre usuários e logins.

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