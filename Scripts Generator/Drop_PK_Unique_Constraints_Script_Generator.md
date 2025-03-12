# Gerador de Scripts para Remover Constraints de Chave Primária e Única

Este script SQL gera dinamicamente scripts para remover constraints de chave primária (PK) e única (UNIQUE) de tabelas em um banco de dados. Ele itera por todos os índices que representam PKs ou constraints UNIQUE e gera os scripts `ALTER TABLE ... DROP CONSTRAINT` correspondentes.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Declaração de Variáveis:** Declara variáveis para armazenar metadados de tabelas e índices.
2.  **Cursor para Índices:** Utiliza um cursor `CursorIndexes` para percorrer todos os índices, filtrando apenas aqueles que são chaves primárias ou constraints únicas.
3.  **Geração de Script:** Constrói dinamicamente scripts `ALTER TABLE ... DROP CONSTRAINT` para cada constraint PK ou UNIQUE.
4.  **Exibição dos Scripts:** Exibe os scripts gerados como resultado da consulta.

## Detalhes do Script

```sql
-- SCRIPT TO GENERATE THE DROP SCRIPT OF ALL PK AND UNIQUE CONSTRAINTS.
DECLARE @SchemaName VARCHAR(256)
DECLARE @TableName VARCHAR(256)
DECLARE @IndexName VARCHAR(256)
DECLARE @TSQLDropIndex VARCHAR(MAX)

DECLARE CursorIndexes CURSOR FOR
SELECT  schema_name(t.schema_id), t.name,  i.name
FROM sys.indexes i
INNER JOIN sys.tables t ON t.object_id= i.object_id
WHERE i.type>0 and t.is_ms_shipped=0 and t.name<>'sysdiagrams'
and (is_primary_key=1 or is_unique_constraint=1)

OPEN CursorIndexes
FETCH NEXT FROM CursorIndexes INTO @SchemaName,@TableName,@IndexName
WHILE @@fetch_status = 0
BEGIN
    SET @TSQLDropIndex = 'ALTER TABLE '+QUOTENAME(@SchemaName)+ '.' + QUOTENAME(@TableName) + ' DROP CONSTRAINT ' +QUOTENAME(@IndexName)
    PRINT @TSQLDropIndex
    FETCH NEXT FROM CursorIndexes INTO @SchemaName,@TableName,@IndexName
END

CLOSE CursorIndexes
DEALLOCATE CursorIndexes
