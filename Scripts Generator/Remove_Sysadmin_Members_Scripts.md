# Geração de Scripts para Remover Membros da Função de Servidor sysadmin

Este script SQL gera dinamicamente scripts `ALTER SERVER ROLE` para remover logins que são membros da função de servidor `sysadmin`. Ele consulta a tabela `syslogins` para identificar esses logins e gera os scripts necessários.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Consulta `syslogins`:** Consulta a tabela `syslogins` para obter informações sobre os logins do servidor.
2.  **Filtragem de Membros `sysadmin`:** Filtra os logins para incluir apenas aqueles que são membros da função de servidor `sysadmin` usando `IS_SRVROLEMEMBER('sysadmin', name) = 1`.
3.  **Geração de Scripts `ALTER SERVER ROLE ... DROP MEMBER ...`:** Gera scripts `ALTER SERVER ROLE [sysadmin] DROP MEMBER [login_name]` para cada login filtrado.
4.  **Ordenação dos Resultados:** Ordena os resultados pelo nome do login (`ORDER BY name`).
5.  **Exibição dos Scripts:** Exibe os scripts gerados como resultado da consulta.

## Detalhes do Script

```sql
SELECT
'ALTER SERVER ROLE [sysadmin] DROP MEMBER ['+ loginname +']
GO'
FROM syslogins
WHERE     IS_SRVROLEMEMBER ('sysadmin',name) = 1
ORDER BY name
