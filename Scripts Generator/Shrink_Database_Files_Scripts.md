# Geração de Scripts para Reduzir o Tamanho dos Arquivos de Dados dos Bancos de Dados

Estes scripts SQL geram dinamicamente scripts `DBCC SHRINKFILE` para reduzir o tamanho dos arquivos de dados dos bancos de dados. O primeiro script gera scripts para todos os bancos de dados de usuário, excluindo os bancos de dados do sistema. O segundo script gera scripts para bancos de dados específicos.

## Visão Geral do Script

Os scripts executam as seguintes etapas:

1.  **Consulta `sys.master_files` e `sys.databases`:** Consultam as tabelas `sys.master_files` e `sys.databases` para obter informações sobre os arquivos de dados dos bancos de dados.
2.  **Filtragem de Arquivos de Dados:** Filtram os arquivos para incluir apenas aqueles do tipo `ROWS` (dados).
3.  **Geração de Scripts `DBCC SHRINKFILE`:** Geram scripts `DBCC SHRINKFILE (N'[file_name]', 0)` para cada arquivo de dados filtrado.
4.  **Exclusão de Bancos de Dados do Sistema (Primeiro Script):** Excluem os bancos de dados do sistema (`master`, `msdb`, `tempdb`, `model`).
5.  **Inclusão de Bancos de Dados Específicos (Segundo Script):** Incluem bancos de dados específicos.
6.  **Exibição dos Scripts:** Exibem os scripts gerados como resultado da consulta.

## Detalhes dos Scripts

### Primeiro Script (Todos os Bancos de Dados de Usuário)

```sql
SELECT
'USE ['+b.name+']
GO
DBCC SHRINKFILE (N'''  + a.name +  ''' , 0)
GO'
FROM
sys.master_files as a
INNER JOIN sys.databases as b
on a.database_id = b.database_id
WHERE a.type_desc='ROWS' and b.name not in('master', 'msdb', 'tempdb', 'model');
