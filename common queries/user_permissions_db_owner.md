# Descrição da Consulta para Verificar Permissões de Usuários em Bancos de Dados

## Descrição da Consulta

Esta consulta cria uma tabela temporária `#UserPermission` para armazenar informações sobre os usuários de cada banco de dados e suas permissões. A consulta executa a seguinte lógica:

1. **Criação de Tabela Temporária:**
   - A tabela `#UserPermission` armazena as seguintes informações:
     - **ServerName**: Nome do servidor.
     - **DbName**: Nome do banco de dados.
     - **UserName**: Nome do usuário.
     - **TypeOfLogIn**: Tipo de login do usuário (como SQL Login ou Windows Login).
     - **PermissionLevel**: Nível de permissão do usuário no banco de dados.
     - **TypeOfRole**: Tipo de função do usuário no banco de dados (como `db_owner`).

2. **Uso de `sp_MSforeachdb`:**
   - O comando `sp_MSforeachdb` é utilizado para executar a consulta em todos os bancos de dados no servidor, exceto nos bancos `master`, `model`, `msdb`, e `tempdb`.
   
3. **Lógica de Seleção de Permissões:**
   - A consulta seleciona usuários que são membros da função `db_owner` e exclui o usuário `dbo`, retornando informações sobre o nome do servidor, nome do banco de dados, nome do usuário, tipo de login e tipo de função.

4. **Resultado Final:**
   - Após a execução do código, a tabela temporária `#UserPermission` é exibida, mostrando a relação de usuários com permissões de `db_owner` em cada banco de dados, excluindo o usuário `dbo`.

5. **Limpeza:**
   - Após a execução, a tabela temporária `#UserPermission` é excluída para liberar recursos.

```SQL
CREATE TABLE #UserPermission
(
   ServerName SYSNAME,
   DbName SYSNAME,
   UserName SYSNAME,
   TypeOfLogIn VARCHAR(50),
   PermissionLevel VARCHAR(50),
   TypeOfRole VARCHAR(50)
)

INSERT #UserPermission
EXEC sp_MSforeachdb '

use [?]

IF ''?'' <> ''master'' AND ''?'' <> ''model'' AND ''?'' <> ''msdb'' AND ''?'' <> ''tempdb''
BEGIN

  SELECT ServerName=@@servername, dbname=db_name(db_id()),p.name as UserName, p.type_desc as TypeOfLogin,
  pp.name as PermissionLevel, pp.type_desc as TypeOfRole 
  FROM sys.database_role_members roles
  JOIN sys.database_principals p ON roles.member_principal_id = p.principal_id
  JOIN sys.database_principals pp ON roles.role_principal_id = pp.principal_id
  where pp.name=''db_owner'' and p.name<>''dbo''   

END '

SELECT * FROM  #UserPermission

DROP TABLE #UserPermission
```