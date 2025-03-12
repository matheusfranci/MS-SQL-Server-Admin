# Geração de Scripts para Reduzir o Tamanho dos Arquivos de Log dos Bancos de Dados

Estes scripts SQL geram dinamicamente scripts `DBCC SHRINKFILE` para reduzir o tamanho dos arquivos de log dos bancos de dados, excluindo os bancos de dados do sistema. O segundo script inclui um `CHECKPOINT` antes de reduzir o arquivo de log.

## Visão Geral dos Scripts

Os scripts executam as seguintes etapas:

1.  **Consulta `sys.master_files` e `sys.databases`:** Consultam as tabelas `sys.master_files` e `sys.databases` para obter informações sobre os arquivos de log e bancos de dados.
2.  **Filtragem de Arquivos de Log:** Filtram os arquivos para incluir apenas aqueles do tipo `LOG`.
3.  **Exclusão de Bancos de Dados do Sistema:** Excluem os bancos de dados do sistema (`master`, `msdb`, `tempdb`, `model`).
4.  **Geração de Scripts `DBCC SHRINKFILE`:** Geram scripts `DBCC SHRINKFILE (N'[file_name]', 0)` para cada arquivo de log filtrado.
5.  **Adição de `CHECKPOINT` (Segundo Script):** O segundo script adiciona um `CHECKPOINT` antes de reduzir o arquivo de log.
6.  **Exibição dos Scripts:** Exibem os scripts gerados como resultado da consulta.

## Detalhes dos Scripts

### Primeiro Script (Redução Simples do Arquivo de Log)

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
WHERE a.type_desc='LOG' and b.name not in('master', 'msdb', 'tempdb', 'model');
```

### Segundo Script (Redução do Arquivo de Log com CHECKPOINT)
```sql
SELECT
'USE ['+b.name+']
GO
CHECKPOINT
GO
DBCC SHRINKFILE (N'''  + a.name +  ''' , 0)
GO'
FROM
sys.master_files as a
INNER JOIN sys.databases as b
on a.database_id = b.database_id
WHERE a.type_desc='LOG' and b.name not in('master', 'msdb', 'tempdb', 'model');
```
