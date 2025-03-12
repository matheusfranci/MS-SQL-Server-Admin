# Geração de Scripts para Colocar Bancos de Dados Offline

Este script SQL gera dinamicamente scripts `ALTER DATABASE ... SET OFFLINE` para colocar todos os bancos de dados online, exceto os bancos de dados do sistema, offline.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Consulta `sys.databases`:** Consulta a tabela `sys.databases` para obter informações sobre todos os bancos de dados no servidor.
2.  **Filtragem de Bancos de Dados Online:** Filtra os bancos de dados para incluir apenas aqueles que estão online (`state_desc = 'ONLINE'`).
3.  **Exclusão de Bancos de Dados do Sistema:** Exclui os bancos de dados do sistema (`master`, `tempdb`, `msdb`, `model`).
4.  **Geração de Scripts `ALTER DATABASE ... SET OFFLINE`:** Gera scripts `ALTER DATABASE [database_name] SET OFFLINE GO` para cada banco de dados filtrado.
5.  **Exibição dos Scripts:** Exibe os scripts gerados como resultado da consulta.

## Detalhes do Script

```sql
SELECT 'ALTER DATABASE ['+ name +'] SET OFFLINE
GO'
FROM sys.databases
WHERE state_desc = 'ONLINE'
AND name NOT IN ('master', 'tempdb', 'msdb', 'model');
