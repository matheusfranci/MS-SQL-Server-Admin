# Gerador de Scripts para Criar Constraints de Chave Primária e Única

Este script SQL gera dinamicamente scripts para criar constraints de chave primária (PK) e única (UNIQUE) em tabelas de um banco de dados. Ele itera por todas as tabelas e índices, filtrando apenas aqueles que representam PKs ou constraints UNIQUE, e gera os scripts `ALTER TABLE ... ADD CONSTRAINT` correspondentes.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Declaração de Variáveis:** Declara variáveis para armazenar metadados de tabelas, índices e colunas.
2.  **Cursor para Índices:** Utiliza um cursor `CursorIndex` para percorrer todos os índices, filtrando apenas aqueles que são chaves primárias ou constraints únicas.
3.  **Cursor para Colunas de Índice:** Para cada índice, utiliza um cursor `CursorIndexColumn` para percorrer suas colunas, determinando as colunas chave e as colunas incluídas.
4.  **Geração de Script:** Constrói dinamicamente scripts `ALTER TABLE ... ADD CONSTRAINT` para cada constraint PK ou UNIQUE, incluindo opções e informações de filegroup.
5.  **Exibição dos Scripts:** Exibe os scripts gerados como resultado da consulta.

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
        + case when ix.allow_row_locks=1 then 'ALLOW_ROW_LOCKS = ON, ' else 'ALLOW_ROW_LOCKS = OFF, ' end
        + case when INDEXPROPERTY(t.object_id, ix.name, 'IsStatistics') = 1 then 'STATISTICS_NORECOMPUTE = ON, ' else 'STATISTICS_NORECOMPUTE = OFF, ' end
        + case when ix.ignore_dup_key=1 then 'IGNORE_DUP_KEY = ON, ' else 'IGNORE_DUP_KEY = OFF, ' end
        + 'SORT_IN_TEMPDB = OFF, FILLFACTOR =' + CAST(ix.fill_factor AS VARCHAR(3)) AS IndexOptions
        , FILEGROUP_NAME(ix.data_space_id) FileGroupName
    from sys.tables t
    inner join sys.indexes ix on t.object_id=ix.object_id
    where ix.type>0 and (ix.is_primary_key=1 or ix.is_unique_constraint=1) --and schema_name(tb.schema_id)= @SchemaName and tb.name=@TableName
    and t.is_ms_shipped=0 and t.name<>'sysdiagrams'
    order by schema_name(t.schema_id), t.name, ix.name

open CursorIndex
fetch next from CursorIndex into @SchemaName, @TableName, @IndexName, @is_unique_constraint, @is_primary_key, @IndexTypeDesc, @IndexOptions, @FileGroupName

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
        inner join sys.columns col on ixc.object_id =col.object_id and ixc.column_id=col.column_id
        where ix.type>0 and (ix.is_primary_key=1 or ix.is_unique_constraint=1)
        and schema_name(tb.schema_id)=@SchemaName and tb.name=@TableName and ix.name=@IndexName
        order by ixc.key_ordinal

    open CursorIndexColumn
    fetch next from CursorIndexColumn into @ColumnName, @IsDescendingKey, @IsIncludedColumn

    while (@@fetch_status=0)
    begin
        if @IsIncludedColumn=0
            set @IndexColumns=@IndexColumns + @ColumnName + case when @IsDescendingKey=1 then ' DESC, ' else ' ASC, ' end
        else
            set @IncludedColumns=@IncludedColumns + @ColumnName +', '

        fetch next from CursorIndexColumn into @ColumnName, @IsDescendingKey, @IsIncludedColumn
    end

    close CursorIndexColumn
    deallocate CursorIndexColumn

    set @IndexColumns = substring(@IndexColumns, 1, len(@IndexColumns)-1)
    set @IncludedColumns = case when len(@IncludedColumns) >0 then substring(@IncludedColumns, 1, len(@IncludedColumns)-1) else '' end

    set @TSQLScripCreationIndex =''
    set @TSQLScripDisableIndex =''
    set @TSQLScripCreationIndex='ALTER TABLE '+ QUOTENAME(@SchemaName) +'.'+ QUOTENAME(@TableName)+ ' ADD CONSTRAINT ' + QUOTENAME(@IndexName) + @is_unique_constraint + @is_primary_key + @IndexTypeDesc + '('+@IndexColumns+') '+
        case when len(@IncludedColumns)>0 then CHAR(13) +'INCLUDE (' + @IncludedColumns+ ')' else '' end + CHAR(13)+'WITH (' + @IndexOptions+ ') ON ' + QUOTENAME(@FileGroupName) + ';'

    print @TSQLScripCreationIndex
    print @TSQLScripDisableIndex

    fetch next from CursorIndex into @SchemaName, @TableName, @IndexName, @is_unique_constraint, @is_primary_key, @IndexTypeDesc, @IndexOptions, @FileGroupName
end

close CursorIndex
deallocate CursorIndex
