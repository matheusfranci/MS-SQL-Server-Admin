# Geração de Scripts para Alterar o Modelo de Recuperação para FULL

Este script SQL gera dinamicamente scripts para alterar o modelo de recuperação de bancos de dados do SQL Server de `SIMPLE` para `FULL`. Ele consulta a tabela `sys.databases` e gera scripts `ALTER DATABASE ... SET RECOVERY FULL WITH NO_WAIT` para cada banco de dados que atende aos critérios.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Consulta `sys.databases`:** Consulta a tabela `sys.databases` para obter o nome e o modelo de recuperação de todos os bancos de dados.
2.  **Filtragem de Bancos de Dados:** Filtra os bancos de dados para incluir apenas aqueles com modelo de recuperação `SIMPLE` e excluir bancos de dados do sistema (`master`, `tempdb`, `msdb`, `model`).
3.  **Geração de Scripts:** Gera scripts `ALTER DATABASE ... SET RECOVERY FULL WITH NO_WAIT` para cada banco de dados filtrado.
4.  **Exibição dos Scripts:** Exibe os scripts gerados como resultado da consulta.

## Detalhes do Script

```sql
SELECT 'ALTER DATABASE ['+ name +'] SET RECOVERY FULL WITH NO_WAIT
GO'
FROM sys.databases
WHERE recovery_model_desc = 'SIMPLE'
AND name NOT IN ('master', 'tempdb', 'msdb', 'model');
