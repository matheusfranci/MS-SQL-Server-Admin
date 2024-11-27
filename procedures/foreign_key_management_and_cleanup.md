#Este script realiza diversas tarefas de gerenciamento de chaves estrangeiras e limpeza de dados nas tabelas.

## Passos:

1. **Verificar Tabelas com Registros**: Consulta a quantidade de registros em tabelas com mais de zero registros.
2. **Gerar DDLs para Criação de Chaves Estrangeiras**: Gera os comandos para recriar todas as chaves estrangeiras da instância.
3. **Gerar Comandos para Dropar Chaves Estrangeiras**: Gera os comandos para remover todas as chaves estrangeiras da instância.
4. **Deletar Dados de Todas as Tabelas**: Gera os comandos para deletar todos os dados de todas as tabelas.

## Benefícios:
- Facilita o gerenciamento de chaves estrangeiras e a limpeza de dados.
```SQL
-- Verificando a quantidade de tabelas com o número maior que zero em seus registros
CREATE TABLE #counts
(
    table_name varchar(255),
    row_count int
)

EXEC sp_MSForEachTable @command1='INSERT #counts (table_name, row_count) SELECT ''?'', COUNT(*) FROM ?'
SELECT table_name, row_count FROM #counts WHERE row_count > 0 ORDER BY table_name, row_count DESC
DROP TABLE #counts

-- Gerando ddls das fks antes de realizar o delete from 
--- SCRIPT TO GENERATE THE CREATION SCRIPT OF ALL FOREIGN KEY CONSTRAINTS
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
--Written by Percy Reyes www.percyreyes.com
declare CursorFK cursor for select object_id--, name, object_name( parent_object_id) 
from sys.foreign_keys
open CursorFK
fetch next from CursorFK into @ForeignKeyID
while (@@FETCH_STATUS=0)
begin
 set @StrParentColumn=''
 set @StrReferencedColumn=''
 declare CursorFKDetails cursor for
  select  fk.name ForeignKeyName, schema_name(t1.schema_id) ParentTableSchema,
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
 fetch next from CursorFKDetails into  @ForeignKeyName, @ParentTableSchema, @ParentTableName, @ParentColumn, @ReferencedTableSchema, @ReferencedTable, @ReferencedColumn
 while (@@FETCH_STATUS=0)
 begin    
  set @StrParentColumn=@StrParentColumn + ', ' + quotename(@ParentColumn)
  set @StrReferencedColumn=@StrReferencedColumn + ', ' + quotename(@ReferencedColumn)
  
     fetch next from CursorFKDetails into  @ForeignKeyName, @ParentTableSchema, @ParentTableName, @ParentColumn, @ReferencedTableSchema, @ReferencedTable, @ReferencedColumn
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

-- Gerando os comandos para dropar todas as fks
--- SCRIPT TO GENERATE THE DROP SCRIPT OF ALL FOREIGN KEY CONSTRAINTS
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

-- DELETE TODOS OS DADOS DE TODAS AS TABELAS
SELECT 'DELETE FROM ['+ TABLE_SCHEMA +'].['+ TABLE_NAME +']
GO'
FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
```