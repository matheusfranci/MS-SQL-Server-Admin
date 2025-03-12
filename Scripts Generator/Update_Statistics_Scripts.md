# Geração de Scripts para Atualizar Estatísticas de Bancos de Dados

Este script SQL gera dinamicamente scripts `EXEC sp_updatestats` para atualizar as estatísticas de todos os bancos de dados de usuário, excluindo os bancos de dados do sistema.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Consulta `sys.databases`:** Consulta a tabela `sys.databases` para obter informações sobre todos os bancos de dados no servidor.
2.  **Exclusão de Bancos de Dados do Sistema:** Exclui os bancos de dados do sistema (`master`, `msdb`, `tempdb`, `model`).
3.  **Geração de Scripts `EXEC sp_updatestats`:** Gera scripts `USE [database_name] GO EXEC sp_updatestats GO` para cada banco de dados de usuário.
4.  **Exibição dos Scripts:** Exibe os scripts gerados como resultado da consulta.

## Detalhes do Script

```sql
SELECT 'USE ['+ db.name +']
GO
EXEC sp_updatestats
GO'
FROM sys.databases db
WHERE db.name NOT IN ('master', 'msdb', 'tempdb', 'model');
