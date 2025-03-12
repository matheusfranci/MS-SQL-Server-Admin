# Geração de Scripts para Reduzir o Tamanho dos Bancos de Dados com DBCC SHRINKDATABASE

Este script SQL gera dinamicamente scripts `DBCC SHRINKDATABASE` para reduzir o tamanho dos bancos de dados, excluindo os bancos de dados do sistema.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Consulta `sys.master_files` e `sys.databases`:** Consultam as tabelas `sys.master_files` e `sys.databases` para obter informações sobre os arquivos de log e bancos de dados.
2.  **Filtragem de Arquivos de Log:** Filtram os arquivos para incluir apenas aqueles do tipo `LOG`.
3.  **Exclusão de Bancos de Dados do Sistema:** Excluem os bancos de dados do sistema (`master`, `msdb`, `tempdb`, `model`).
4.  **Geração de Scripts `DBCC SHRINKDATABASE`:** Geram scripts `DBCC SHRINKDATABASE (N'[database_name]', 0)` para cada banco de dados filtrado.
5.  **Exibição dos Scripts:** Exibem os scripts gerados como resultado da consulta.

## Detalhes do Script

```sql
SELECT
'USE ['+b.name+']
GO
DBCC SHRINKDATABASE (N'''  + b.name +  ''' , 0)
GO'
FROM
sys.master_files as a
INNER JOIN sys.databases as b
on a.database_id = b.database_id
WHERE a.type_desc='LOG' and b.name not in('master', 'msdb', 'tempdb', 'model');
