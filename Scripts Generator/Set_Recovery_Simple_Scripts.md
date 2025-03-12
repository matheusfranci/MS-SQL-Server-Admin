# Geração de Scripts para Alterar o Modelo de Recuperação para SIMPLE

Este script SQL gera dinamicamente scripts `ALTER DATABASE ... SET RECOVERY SIMPLE` para alterar o modelo de recuperação de todos os bancos de dados que estão no modelo `FULL` para o modelo `SIMPLE`, excluindo os bancos de dados do sistema.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Consulta `sys.databases`:** Consulta a tabela `sys.databases` para obter informações sobre todos os bancos de dados no servidor.
2.  **Filtragem de Bancos de Dados com Modelo de Recuperação FULL:** Filtra os bancos de dados para incluir apenas aqueles que estão no modelo de recuperação `FULL` (`recovery_model_desc = 'FULL'`).
3.  **Exclusão de Bancos de Dados do Sistema:** Exclui os bancos de dados do sistema (`master`, `tempdb`, `msdb`, `model`).
4.  **Geração de Scripts `ALTER DATABASE ... SET RECOVERY SIMPLE`:** Gera scripts `ALTER DATABASE [database_name] SET RECOVERY SIMPLE WITH NO_WAIT GO` para cada banco de dados filtrado.
5.  **Exibição dos Scripts:** Exibe os scripts gerados como resultado da consulta.

## Detalhes do Script

```sql
SELECT 'ALTER DATABASE ['+ name +'] SET RECOVERY SIMPLE WITH NO_WAIT
GO'
FROM sys.databases
WHERE recovery_model_desc = 'FULL'
AND name NOT IN ('master', 'tempdb', 'msdb', 'model');
