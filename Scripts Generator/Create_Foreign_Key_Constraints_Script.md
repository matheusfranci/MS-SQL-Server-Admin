# Gerador de Scripts para Criar Constraints de Chave Estrangeira

Este script SQL gera dinamicamente scripts para criar constraints de chave estrangeira (FOREIGN KEY) em um banco de dados. Ele itera por todas as chaves estrangeiras, coletando informações sobre as tabelas e colunas envolvidas, e gera os scripts `ALTER TABLE ... ADD CONSTRAINT FOREIGN KEY` correspondentes.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Declaração de Variáveis:** Declara variáveis para armazenar metadados de chaves estrangeiras, tabelas e colunas.
2.  **Cursor para Chaves Estrangeiras:** Utiliza um cursor `CursorFK` para percorrer todas as chaves estrangeiras (`sys.foreign_keys`).
3.  **Cursor para Detalhes da Chave Estrangeira:** Para cada chave estrangeira, utiliza um cursor `CursorFKDetails` para percorrer as colunas envolvidas (`sys.foreign_key_columns`, `sys.columns`, `sys.tables`).
4.  **Geração de Script:** Constrói dinamicamente scripts `ALTER TABLE ... ADD CONSTRAINT FOREIGN KEY` para cada chave estrangeira, incluindo os nomes das tabelas e colunas envolvidas.
5.  **Exibição dos Scripts:** Exibe os scripts gerados como resultado da consulta.

## Detalhes do Script

```sql
-- SCRIPT TO GENERATE THE CREATION SCRIPT OF ALL FOREIGN KEY CONSTRAINTS
declare @ForeignKeyID int
declare @ForeignKeyName varchar(4000)
declare @ParentTableName varchar(4000)
declare @ParentColumn varchar(4000)
declare @ReferencedTable varchar(4000)
declare @ReferencedColumn varchar(4000)
declare @StrParentColumn varchar(max)
declare @StrReferencedColumn varchar(max)
declare @ParentTableSchema varchar(4000)
declare @ReferencedTableSchema varchar(4000)
declare @TSQLCreationFK varchar(max)
--Written by Percy Reyes [www.percyreyes.com](https://www.percyreyes.com)
declare CursorFK cursor for select object_id--, name, object_name( parent_object_id)
from sys.foreign_keys
open CursorFK
fetch next from CursorFK into @ForeignKeyID
while (@@FETCH_STATUS=0)
begin
    set @StrParentColumn=''
    set @StrReferencedColumn=''
    declare CursorFKDetails cursor for
        select fk.name ForeignKeyName, schema_name(t1.schema_id) ParentTableSchema,
            object_name(fkc.parent_object_id) ParentTable, c1.name ParentColumn,schema_name(t2.schema_id) ReferencedTableSchema,
            object_name(fkc.referenced_object_id) ReferencedTable,c2.name ReferencedColumn
        from --sys.tables t inner join
        sys.foreign_keys fk
        inner join sys.foreign_key_columns fkc on fk.object_id=fkc.constraint_object_id
        inner join sys.columns c1 on c1.object_id=fkc.parent_object_id and c1.column_id=fkc.parent_column_id
        inner join sys.columns c2 on c2.object_id=fkc.referenced_object_id and c2.column_id=fkc.referenced_column_id
        inner join sys.tables t1 on t1.object_id=fkc.parent_object_id
        inner join sys.tables t2 on t2.object_id=fkc.referenced_object_id
        where fk.object_id=@ForeignKeyID
    open CursorFKDetails
    fetch next from CursorFKDetails into @ForeignKeyName, @ParentTableSchema, @ParentTableName, @ParentColumn, @ReferencedTableSchema, @ReferencedTable, @ReferencedColumn
    while (@@FETCH_STATUS=0)
    begin
        set @StrParentColumn=@StrParentColumn + ', ' + quotename(@ParentColumn)
        set @StrReferencedColumn=@StrReferencedColumn + ', ' + quotename(@ReferencedColumn)

        fetch next from CursorFKDetails into @ForeignKeyName, @ParentTableSchema, @ParentTableName, @ParentColumn, @ReferencedTableSchema, @ReferencedTable, @ReferencedColumn
    end
    close CursorFKDetails
    deallocate CursorFKDetails

    set @StrParentColumn=substring(@StrParentColumn,2,len(@StrParentColumn)-1)
    set @StrReferencedColumn=substring(@StrReferencedColumn,2,len(@StrReferencedColumn)-1)
    set @TSQLCreationFK='ALTER TABLE '+quotename(@ParentTableSchema)+'.'+quotename(@ParentTableName)+' WITH CHECK ADD CONSTRAINT '+quotename(@ForeignKeyName)
        + ' FOREIGN KEY('+ltrim(@StrParentColumn)+') '+ char(13) +'REFERENCES '+quotename(@ReferencedTableSchema)+'.'+quotename(@ReferencedTable)+' ('+ltrim(@StrReferencedColumn)+') ' + char(13)+'GO'

    print @TSQLCreationFK

fetch next from CursorFK into @ForeignKeyID
end
close CursorFK
deallocate CursorFK
