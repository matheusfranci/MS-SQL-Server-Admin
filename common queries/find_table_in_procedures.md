# Explicação da Query

## Objetivo
A query busca referências à tabela `xpto` no código-fonte (DDL) de todas as procedures definidas em um banco de dados no SQL Server. O objetivo é identificar quais procedures utilizam essa tabela.

```SQL
DECLARE @sql NVARCHAR(MAX) = N'';

-- Monta uma consulta dinâmica para todos os bancos
SELECT @sql += 'USE [' + name + ']; 
SELECT 
    ''' + name + ''' AS DatabaseName,
    p.name AS ProcedureName,
    SCHEMA_NAME(p.schema_id) AS SchemaName,
    m.definition AS ProcedureDefinition
FROM sys.procedures p
INNER JOIN sys.sql_modules m
    ON p.object_id = m.object_id
WHERE m.definition LIKE ''%XPTO%'';
'
FROM sys.databases
WHERE state_desc = 'ONLINE' -- Apenas bancos online
  AND database_id > 4;      -- Ignora bancos do sistema (master, model, msdb, tempdb)

-- Executa a consulta dinâmica
EXEC sp_executesql @sql;
```
