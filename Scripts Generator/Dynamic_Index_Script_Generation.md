# Gerador Dinâmico de Scripts de Índices

Este script gera dinamicamente scripts SQL para criar e desabilitar índices em um banco de dados especificado. Ele itera por todos os índices não primários, não exclusivos e não de sistema, criando scripts para sua criação e desativação (se necessário). Os scripts gerados são então enviados por e-mail em formato HTML.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Declaração de Variáveis:** Declara variáveis para armazenar metadados de índice e tabela.
2.  **Cursor para Índices:** Usa um cursor `CursorIndex` para iterar por todos os índices no banco de dados (excluindo índices de sistema, chaves primárias e restrições exclusivas).
3.  **Cursor para Colunas de Índice:** Para cada índice, outro cursor `CursorIndexColumn` itera por suas colunas para determinar as colunas de chave de índice e as colunas incluídas.
4.  **Geração de Script:** Constrói scripts `CREATE INDEX` e `ALTER INDEX DISABLE` para cada índice, incluindo opções e informações de filegroup.
5.  **Formatação HTML:** Formata os scripts gerados em uma tabela HTML para e-mail.
6.  **Envio de E-mail:** Envia os scripts formatados em HTML por e-mail usando `msdb.dbo.sp_send_dbmail`.

## Detalhes do Script

```sql
USE dba;

DECLARE @SchemaName varchar(100);
DECLARE @TableName varchar(256);
DECLARE @IndexName varchar(256);
DECLARE @ColumnName varchar(100);
DECLARE @is_unique varchar(100);
DECLARE @IndexTypeDesc varchar(100);
DECLARE @FileGroupName varchar(100);
DECLARE @is_disabled varchar(100);
DECLARE @IndexOptions varchar(max);
DECLARE @IndexColumnId int;
DECLARE @IsDescendingKey int;
DECLARE @IsIncludedColumn INT;
DECLARE @TSQLScripCreationIndex varchar(max);
DECLARE @TSQLScripDisableIndex varchar(max);
DECLARE @scriptindex VARCHAR(MAX) = '';
DECLARE @HTML_Body VARCHAR(MAX);
DECLARE @HTML_Head VARCHAR(MAX);
DECLARE @HTML_Tail VARCHAR(MAX);
DECLARE @subject_db VARCHAR(MAX) = 'all index - ' + DB_NAME();

-- Cursor para iterar pelos índices
DECLARE CursorIndex CURSOR FOR
    SELECT schema_name(t.schema_id) [schema_name], t.name, ix.name,
           CASE WHEN ix.is_unique = 1 THEN 'UNIQUE ' ELSE '' END,
           ix.type_desc,
           CASE WHEN ix.is_padded = 1 THEN 'PAD_INDEX = ON, ' ELSE 'PAD_INDEX = OFF, ' END +
           CASE WHEN ix.allow_page_locks = 1 THEN 'ALLOW_PAGE_LOCKS = ON, ' ELSE 'ALLOW_PAGE_LOCKS = OFF, ' END +
           CASE WHEN ix.allow_row_locks = 1 THEN 'ALLOW_ROW_LOCKS = ON, ' ELSE 'ALLOW_ROW_LOCKS = OFF, ' END +
           CASE WHEN INDEXPROPERTY(t.object_id, ix.name, 'IsStatistics') = 1 THEN 'STATISTICS_NORECOMPUTE = ON, ' ELSE 'STATISTICS_NORECOMPUTE = OFF, ' END +
           CASE WHEN ix.ignore_dup_key = 1 THEN 'IGNORE_DUP_KEY = ON, ' ELSE 'IGNORE_DUP_KEY = OFF, ' END +
           'SORT_IN_TEMPDB = OFF, FILLFACTOR =' + CAST(ix.fill_factor AS VARCHAR(3)) AS IndexOptions,
           ix.is_disabled, FILEGROUP_NAME(ix.data_space_id) FileGroupName
    FROM sys.tables t
    INNER JOIN sys.indexes ix ON t.object_id = ix.object_id
    WHERE ix.type > 0 AND ix.is_primary_key = 0 AND ix.is_unique_constraint = 0
      AND t.is_ms_shipped = 0 AND t.name <> 'sysdiagrams'
    ORDER BY schema_name(t.schema_id), t.name, ix.name;

OPEN CursorIndex;
FETCH NEXT FROM CursorIndex INTO @SchemaName, @TableName, @IndexName, @is_unique, @IndexTypeDesc, @IndexOptions, @is_disabled, @FileGroupName;

WHILE (@@FETCH_STATUS = 0)
BEGIN
    DECLARE @IndexColumns varchar(max);
    DECLARE @IncludedColumns varchar(max);

    SET @IndexColumns = '';
    SET @IncludedColumns = '';

    -- Cursor para iterar pelas colunas do índice
    DECLARE CursorIndexColumn CURSOR FOR
        SELECT col.name, ixc.is_descending_key, ixc.is_included_column
        FROM sys.tables tb
        INNER JOIN sys.indexes ix ON tb.object_id = ix.object_id
        INNER JOIN sys.index_columns ixc ON ix.object_id = ixc.object_id AND ix.index_id = ixc.index_id
        INNER JOIN sys.columns col ON ixc.object_id = col.object_id AND ixc.column_id = col.column_id
        WHERE ix.type > 0 AND (ix.is_primary_key = 0 OR ix.is_unique_constraint = 0)
          AND schema_name(tb.schema_id) = @SchemaName AND tb.name = @TableName AND ix.name = @IndexName
        ORDER BY ixc.index_column_id;

    OPEN CursorIndexColumn;
    FETCH NEXT FROM CursorIndexColumn INTO @ColumnName, @IsDescendingKey, @IsIncludedColumn;

    WHILE (@@FETCH_STATUS = 0)
    BEGIN
        IF @IsIncludedColumn = 0
            SET @IndexColumns = @IndexColumns + @ColumnName + CASE WHEN @IsDescendingKey = 1 THEN ' DESC, ' ELSE ' ASC, ' END;
        ELSE
            SET @IncludedColumns = @IncludedColumns + @ColumnName + ', ';

        FETCH NEXT FROM CursorIndexColumn INTO @ColumnName, @IsDescendingKey, @IsIncludedColumn;
    END

    CLOSE CursorIndexColumn;
    DEALLOCATE CursorIndexColumn;

    SET @IndexColumns = SUBSTRING(@IndexColumns, 1, LEN(@IndexColumns) - 1);
    SET @IncludedColumns = CASE WHEN LEN(@IncludedColumns) > 0 THEN SUBSTRING(@IncludedColumns, 1, LEN(@IncludedColumns) - 1) ELSE '' END;

    SET @TSQLScripCreationIndex = '';
    SET @TSQLScripDisableIndex = '';
    SET @TSQLScripCreationIndex = 'CREATE ' + @is_unique + @IndexTypeDesc + ' INDEX ' + QUOTENAME(@IndexName) + ' ON ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + '(' + @IndexColumns + ') ' +
                                  CASE WHEN LEN(@IncludedColumns) > 0 THEN CHAR(13) + 'INCLUDE (' + @IncludedColumns + ')' ELSE '' END + CHAR(13) + 'WITH (' + @IndexOptions + ') ON ' + QUOTENAME(@FileGroupName) + '; ' + CHAR(13) + CHAR(13);

    IF @is_disabled = 1
        SET @TSQLScripDisableIndex = CHAR(13) + 'ALTER INDEX ' + QUOTENAME(@IndexName) + ' ON ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' DISABLE;' + CHAR(13);

    SELECT @scriptindex = @scriptindex + @TSQLScripCreationIndex;
    SELECT @scriptindex = @scriptindex + @TSQLScripDisableIndex;

    FETCH NEXT FROM CursorIndex INTO @SchemaName, @TableName, @IndexName, @is_unique, @IndexTypeDesc, @IndexOptions, @is_disabled, @FileGroupName;
END

CLOSE CursorIndex;
DEALLOCATE CursorIndex;

-- Formatação HTML
SET @HTML_Head = '<html><head></head><body><b>Index create script.</b><hr /><table><tr><th>Indexes Script</th></tr>';
SET @HTML_Tail = '</table></body></html>';

SET @HTML_Body = @HTML_Head + @scriptindex + @HTML_Tail;

-- Envio de e-mail
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'DBA',
    @recipients = 'vinicius.castro.fonseca@gmail.com',
    @subject = @subject_db,
    @body = @HTML_Body,
    @body_format = 'HTML
