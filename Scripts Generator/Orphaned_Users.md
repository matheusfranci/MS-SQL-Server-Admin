# Geração de Scripts para Alterar Mapeamento de Usuários de Banco de Dados para Logins

Este script SQL gera dinamicamente scripts `ALTER USER` para remapear usuários de banco de dados para logins do SQL Server. Ele consulta a tabela `sys.database_principals` para identificar usuários do tipo SQL Server e gera scripts para associá-los aos logins correspondentes.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Consulta `sys.database_principals`:** Consulta a tabela `sys.database_principals` para obter informações sobre usuários do banco de dados.
2.  **Filtragem de Usuários:** Filtra os usuários para incluir apenas aqueles do tipo SQL Server (`TYPE = 'S'`) e exclui usuários padrão (`dbo`, `guest`, `INFORMATION_SCHEMA`).
3.  **Geração de Scripts `ALTER USER ... WITH LOGIN ...`:** Gera scripts `ALTER USER [user_name] WITH LOGIN = [login_name]` para cada usuário filtrado.
4.  **Exibição dos Scripts:** Exibe os scripts gerados como resultado da consulta.

## Detalhes do Script

```sql
SELECT
'ALTER USER [' + name + '] WITH LOGIN = [' + name + ']
GO'
FROM sys.database_principals
WHERE TYPE = 'S'
AND name NOT IN ('dbo', 'guest', 'INFORMATION_SCHEMA')
