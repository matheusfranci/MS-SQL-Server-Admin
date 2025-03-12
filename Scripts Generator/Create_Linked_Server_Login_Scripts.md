# Geração de Scripts para Criar Logins de Servidor Vinculado

Este script SQL gera dinamicamente scripts para adicionar logins de servidor vinculado (`sp_addlinkedsrvlogin`) no banco de dados `msdb`. Ele consulta a tabela `sys.servers` para obter os nomes dos servidores vinculados e gera scripts para criar logins com credenciais específicas.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Consulta `sys.servers`:** Consulta a tabela `sys.servers` para obter os nomes dos servidores vinculados.
2.  **Filtragem de Servidores:** Filtra os servidores para excluir o servidor local (`@@servername`).
3.  **Geração de Scripts `sp_addlinkedsrvlogin`:** Gera scripts `sp_addlinkedsrvlogin` para cada servidor vinculado, com as seguintes opções:
    * `@rmtsrvname`: Nome do servidor vinculado.
    * `@locallogin`: `NULL` (usa o mesmo login para todos os logins locais).
    * `@useself`: `False` (especifica credenciais explícitas).
    * `@rmtuser`: `Conta.Jobs` (nome de usuário remoto).
    * `@rmtpassword`: `teste` (senha remota).
4.  **Exibição dos Scripts:** Exibe os scripts gerados como resultado da consulta.

## Detalhes do Script

```sql
SELECT '
USE [msdb]
GO
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N''' + name + ''', @locallogin = NULL , @useself = N''False'', @rmtuser = N''Conta.Jobs'', @rmtpassword = N''teste''
GO
'
FROM sys.servers
WHERE name not in (@@servername);
