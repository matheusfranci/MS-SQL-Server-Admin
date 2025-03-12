# Geração de Scripts para Criação de Usuários e Atribuição de Roles

Este script SQL gera dinamicamente scripts para criar usuários em bancos de dados e atribuir roles de banco de dados a esses usuários. Ele utiliza tabelas temporárias e o procedimento armazenado `sp_MSforeachdb` para percorrer todos os bancos de dados e gerar os scripts necessários.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Criação de Tabela Temporária para Usuários:** Cria uma tabela temporária `#tmpuserresult` para armazenar os scripts de criação de usuários.
2.  **Geração de Scripts de Criação de Usuários:** Utiliza `sp_MSforeachdb` para percorrer todos os bancos de dados e gerar scripts `CREATE USER` para um usuário específico (`usuariodestinoaqui`).
3.  **Exibição dos Scripts de Usuários:** Seleciona e exibe os scripts armazenados na tabela `#tmpuserresult`.
4.  **Remoção da Tabela Temporária de Usuários:** Remove a tabela `#tmpuserresult`.
5.  **Criação de Tabela Temporária para Roles:** Cria uma tabela temporária `#grantresult` para armazenar informações sobre roles de banco de dados atribuídas a um usuário específico.
6.  **Geração de Scripts de Atribuição de Roles:** Utiliza `sp_MSforeachdb` para percorrer todos os bancos de dados e inserir informações sobre as roles atribuídas ao usuário especificado (`POLIEDRO\JNMOURA.MARCUS.SOUZA`) na tabela `#grantresult`.
7.  **Geração de Scripts `ALTER ROLE`:** Seleciona e gera scripts `ALTER ROLE ... ADD MEMBER` para atribuir as roles encontradas ao usuário de destino (`usuariox`).
8.  **Remoção da Tabela Temporária de Roles:** Remove a tabela `#grantresult`.

## Detalhes do Script

```sql
-- Usuário precisa ser criado na instância antes.
-- Criação da tabela temporária para armazenar as ddl's dos usuário nos bancos
CREATE TABLE #tmpuserresult
(
Comando VARCHAR(MAX)
)

INSERT INTO #tmpuserresult
EXEC master.sys.sp_MSforeachdb'
USE [?]
SELECT "
USE ["+ DB_NAME() +"]
GO
CREATE USER [ usuariodestinoaqui ] FOR LOGIN [ usuariodestinoaqui ]" AS "--Database Users Creation--"
FROM sys.database_principals
WHERE NAME = "POLIEDRO\JNMOURA.MARCUS.SOUZA" ' -- Usuário de exemplo muito provavelmente utilzado como parâmetro na abertura do chamado

SELECT * FROM #tmpuserresult -- Extraia os comandos aqui e execute
DROP TABLE #tmpuserresult -- Apague a tabela temporária

----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Criação da tabela temporária para armazenamento das dcl's
CREATE TABLE #grantresult
(
role_principal_name VARCHAR(MAX),
member_principal_name VARCHAR(MAX),
Banco VARCHAR(MAX)
)

INSERT INTO #grantresult -- Inserção das database roles atribuídas a determinado usuário de exemplo que está no chamado
EXEC master.sys.sp_MSforeachdb
'USE [?]
SELECT r.name role_principal_name, m.name AS member_principal_name, DB_NAME() AS Banco
FROM sys.database_role_members rm
JOIN sys.database_principals r
  ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m
  ON rm.member_principal_id = m.principal_id
where m.name IN ("POLIEDRO\JNMOURA.MARCUS.SOUZA")
order by m.name;'

-- Permissão
SELECT '
USE ['+ t.Banco +']
GO
ALTER ROLE [ '+ t.role_principal_name +' ] ADD MEMBER [ usuariox ]
GO'
FROM #grantresult t

DROP TABLE #grantresult -- Apague a tabela temporária
