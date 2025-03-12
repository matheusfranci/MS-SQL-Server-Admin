# Geração de Scripts para Colocar Bancos de Dados Online

Este script SQL gera dinamicamente scripts `ALTER DATABASE ... SET ONLINE` para colocar todos os bancos de dados offline, exceto os bancos de dados do sistema, online.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Consulta `sys.databases`:** Consulta a tabela `sys.databases` para obter informações sobre todos os bancos de dados no servidor.
2.  **Filtragem de Bancos de Dados Offline:** Filtra os bancos de dados para incluir apenas aqueles que estão offline (`state_desc = 'OFFLINE'`).
3.  **Exclusão de Bancos de Dados do Sistema:** Exclui os bancos de dados do sistema (`master`, `tempdb`, `msdb`, `model`).
4.  **Geração de Scripts `ALTER DATABASE ... SET ONLINE`:** Gera scripts `ALTER DATABASE [database_name] SET ONLINE GO` para cada banco de dados filtrado.
5.  **Exibição dos Scripts:** Exibe os scripts gerados como resultado da consulta.

## Detalhes do Script

```sql
SELECT 'ALTER DATABASE ['+ name +'] SET ONLINE
GO'
FROM sys.databases
WHERE state_desc = 'OFFLINE'
AND name NOT IN ('master', 'tempdb', 'msdb', 'model');
