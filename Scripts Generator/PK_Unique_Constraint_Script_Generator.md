# Geração de Scripts de Criação de Chaves Primárias e Constraints Unique

Este script SQL gera dinamicamente scripts `ALTER TABLE ADD CONSTRAINT` para criar chaves primárias e constraints unique em tabelas do SQL Server. Ele utiliza cursores para iterar sobre tabelas e índices, construindo os scripts com todas as opções relevantes.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Declaração de Variáveis:** Declara variáveis para armazenar informações sobre esquemas, tabelas, índices, colunas e opções.
2.  **Cursor `CursorIndex`:** Abre um cursor para iterar sobre índices de chaves primárias e constraints unique em tabelas de usuário.
    * Consulta `sys.tables` e `sys.indexes` para obter informações sobre tabelas e índices.
    * Filtra índices para incluir apenas chaves primárias e constraints unique em tabelas de usuário.
    * Constrói a string de opções do índice (`@IndexOptions`).
    * Obtém o nome do filegroup do índice.
3.  **Cursor `CursorIndexColumn`:** Abre um cursor aninhado para iterar sobre colunas de cada índice.
    * Consulta `sys.tables`, `sys.indexes`, `sys.index_columns` e `sys.columns` para obter informações sobre colunas do índice.
    * Constrói as listas de colunas chave (`@IndexColumns`) e colunas incluídas (`@IncludedColumns`).
4.  **Geração de Scripts `ALTER TABLE ADD CONSTRAINT`:**
    * Constrói o script `ALTER TABLE ADD CONSTRAINT` com todas as opções relevantes, incluindo nome do esquema, nome da tabela, nome do índice, tipo do índice (UNIQUE ou PRIMARY KEY), colunas chave, colunas incluídas, opções do índice e filegroup.
5.  **Impressão dos Scripts:** Imprime os scripts gerados.
6.  **Iteração dos Cursors:** Avança os cursores para processar o próximo índice e as próximas colunas.
7.  **Fechamento e Desalocação dos Cursors:** Fecha e desaloca os cursores após a conclusão.

## Detalhes do Script

```sql
-- SCRIPT TO GENERATE THE CREATION SCRIPT OF ALL PK AND UNIQUE CONSTRAINTS.
declare @SchemaName varchar(100)
declare @TableName varchar(256)
declare @IndexName varchar(256)
declare @ColumnName varchar(100)
declare @is_unique_constraint varchar(100)
declare @IndexTypeDesc varchar(100)
declare @FileGroupName varchar(100)
declare @is_disabled varchar(100)
declare @IndexOptions varchar(max)
declare @IndexColumnId int
declare @IsDescendingKey int
declare @IsIncludedColumn int
declare @TSQLScripCreationIndex varchar(max)
declare @TSQLScripDisableIndex varchar(max)
declare @is_primary_key varchar(100)

declare CursorIndex cursor for
    select schema_name(t.schema_id) [schema_name], t.name, ix.name,
    case when ix.is_unique_constraint = 1 then ' UNIQUE ' else '' END
        ,case when ix.is_primary_key = 1 then ' PRIMARY KEY ' else '' END
    , ix.type_desc,
     case when ix.is_padded=1 then 'PAD_INDEX = ON, ' else 'PAD_INDEX = OFF, ' end
    + case when ix.allow_page_locks=1 then 'ALLOW_PAGE_LOCKS = ON, ' else 'ALLOW_PAGE_LOCKS = OFF, ' end
    + case when ix.allow_row_locks=1 then  'ALLOW_ROW_LOCKS = ON, ' else 'ALLOW_ROW_LOCKS = OFF, ' end
    + case when INDEXPROPERTY(t.object_id, ix.name, 'IsStatistics') = 1 then 'STATISTICS_NORECOMPUTE = ON, ' else 'STATISTICS_NORECOMPUTE = OFF, ' end
    + case when ix.ignore_dup_key=1 then 'IGNORE_DUP_KEY = ON, ' else 'IGNORE_DUP_KEY = OFF, ' end
    + 'SORT_IN_TEMPDB = OFF, FILLFACTOR =' + CAST(ix.fill_factor AS VARCHAR(3)) AS IndexOptions
    , FILEGROUP_NAME(ix.data_space_id) FileGroupName
    from sys.tables t
    inner join sys.indexes ix on t.object_id=ix.object_id
    where ix.type>0 and  (ix.is_primary_key=1 or ix.is_unique_constraint=1) --and schema_name(tb.schema_id)= @SchemaName and tb.name=@TableName
    and t.is_ms_shipped=0 and t.name<>'sysdiagrams'
    order by schema_name(t.schema_id), t.name, ix.name
open CursorIndex
fetch next from CursorIndex into  @SchemaName, @TableName, @IndexName, @is_unique_constraint, @is_primary_key, @IndexTypeDesc, @IndexOptions, @FileGroupName
while (@@fetch_status=0)
begin
    declare @IndexColumns varchar(max)
    declare @IncludedColumns varchar(max)
    set @IndexColumns=''
    set @IncludedColumns=''
    declare CursorIndexColumn cursor for
    select col.name, ixc.is_descending_key, ixc.is_included_column
    from sys.tables tb
    inner join sys.indexes ix on tb.object_id=ix.object_id
    inner join sys.index_columns ixc on ix.object_id=ixc.object_id and ix.index_id= ixc.index_id
    inner join sys.columns col on ixc.object_id =col.object_id  and ixc.column_id=col.column_id
    where ix.type>0 and (ix.is_primary_key=1 or ix.is_unique_constraint=1)
    and schema_name(tb.schema_id)=@SchemaName and tb.name=@TableName and ix.name=@IndexName
    order by ixc.key_ordinal
    open CursorIndexColumn
    fetch next from CursorIndexColumn into  @ColumnName, @IsDescendingKey, @IsIncludedColumn
    while (@@fetch_status=0)
    begin
     if @IsIncludedColumn=0
        set @IndexColumns=@IndexColumns + @ColumnName  + case when @IsDescendingKey=1  then ' DESC, ' else  ' ASC, ' end
     else
        set @IncludedColumns=@IncludedColumns  + @ColumnName  +', '

     fetch next from CursorIndexColumn into @ColumnName, @IsDescendingKey, @IsIncludedColumn
    end
    close CursorIndexColumn
    deallocate CursorIndexColumn
    set @IndexColumns = substring(@IndexColumns, 1, len(@IndexColumns)-1)
    set @IncludedColumns = case when len(@IncludedColumns) >0 then substring(@IncludedColumns, 1, len(@IncludedColumns)-1) else '' end
--  print @IndexColumns
--  print @IncludedColumns

set @TSQLScripCreationIndex =''
set @TSQLScripDisableIndex =''
set  @TSQLScripCreationIndex='ALTER TABLE '+  QUOTENAME(@SchemaName) +'.'+ QUOTENAME(@TableName)+ ' ADD CONSTRAINT ' +  QUOTENAME(@IndexName) + @is_unique_constraint + @is_primary_key + +@IndexTypeDesc +  '('+@IndexColumns+') '+
    case when len(@IncludedColumns)>0 then CHAR(13) +'INCLUDE (' + @IncludedColumns+ ')' else '' end + CHAR(13)+'WITH (' + @IndexOptions+ ') ON ' + QUOTENAME(@FileGroupName) + ';'

print @TSQLScripCreationIndex
print @TSQLScripDisableIndex

fetch next from CursorIndex into  @SchemaName, @TableName, @IndexName, @is_unique_constraint, @is_primary_key, @IndexTypeDesc, @IndexOptions, @FileGroupName

end
close CursorIndex
deallocate CursorIndex
