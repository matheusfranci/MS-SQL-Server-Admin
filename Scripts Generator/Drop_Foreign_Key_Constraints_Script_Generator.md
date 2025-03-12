# Gerador de Scripts para Remover Constraints de Chave Estrangeira

Este script SQL gera dinamicamente scripts para remover constraints de chave estrangeira (FOREIGN KEY) de tabelas em um banco de dados. Ele itera por todas as chaves estrangeiras e gera os scripts `ALTER TABLE ... DROP CONSTRAINT` correspondentes.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Declaração de Variáveis:** Declara variáveis para armazenar metadados de chaves estrangeiras e tabelas.
2.  **Cursor para Chaves Estrangeiras:** Utiliza um cursor `CursorFK` para percorrer todas as chaves estrangeiras (`sys.foreign_keys`).
3.  **Geração de Script:** Constrói dinamicamente scripts `ALTER TABLE ... DROP CONSTRAINT` para cada chave estrangeira.
4.  **Exibição dos Scripts:** Exibe os scripts gerados como resultado da consulta.

## Detalhes do Script

```sql
-- SCRIPT TO GENERATE THE DROP SCRIPT OF ALL FOREIGN KEY CONSTRAINTS
declare @ForeignKeyName varchar(4000)
declare @ParentTableName varchar(4000)
declare @ParentTableSchema varchar(4000)

declare @TSQLDropFK varchar(max)

declare CursorFK cursor for select fk.name ForeignKeyName, schema_name(t.schema_id) ParentTableSchema, t.name ParentTableName
from sys.foreign_keys fk  inner join sys.tables t on fk.parent_object_id=t.object_id
open CursorFK
fetch next from CursorFK into  @ForeignKeyName, @ParentTableSchema, @ParentTableName
while (@@FETCH_STATUS=0)
begin
    set @TSQLDropFK ='ALTER TABLE '+quotename(@ParentTableSchema)+'.'+quotename(@ParentTableName)+' DROP CONSTRAINT '+quotename(@ForeignKeyName)+ char(13) + 'GO'

    print @TSQLDropFK

fetch next from CursorFK into  @ForeignKeyName, @ParentTableSchema, @ParentTableName
end
close CursorFK
deallocate CursorFK
