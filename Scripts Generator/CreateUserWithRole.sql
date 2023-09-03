-- Usuário precisa ser criado na instância antes.
-- Criação  da tabela temporária para armazenar as ddl's dos usuário nos bancos
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

