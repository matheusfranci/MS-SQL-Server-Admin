# Geração Avançada de Scripts de Criação de Índices Ausentes

Este script SQL realiza uma análise avançada de índices ausentes, gerando scripts `CREATE INDEX` personalizados com base em recomendações das DMVs do SQL Server. Ele inclui funções para manipular colunas de índice, um ranking baseado em impacto e filtros para refinar as recomendações.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Criação de Funções de Manipulação de Colunas:**
    * `dbo.fn_createindex_allcols`: Retorna todas as colunas de um índice ausente como uma string separada por vírgulas.
    * `dbo.fn_createindex_keycols`: Retorna as colunas de chave (igualdade e desigualdade) de um índice ausente como uma string separada por vírgulas.
    * `dbo.fn_createindex_includecols`: Retorna as colunas incluídas de um índice ausente como uma string separada por vírgulas.
2.  **Criação da Tabela Temporária `#IndexCreation`:** Cria uma tabela temporária para armazenar informações sobre índices ausentes.
3.  **Inserção de Dados na Tabela Temporária:**
    * Consulta as DMVs `sys.dm_db_missing_index_details`, `master.sys.databases`, `sys.dm_db_missing_index_groups` e `sys.dm_db_missing_index_group_stats` para obter informações sobre índices ausentes.
    * Calcula um score baseado no impacto, custo e buscas do usuário.
    * Utiliza as funções criadas para obter as colunas de chave e incluídas.
    * Gera um nome de índice personalizado.
    * Gera scripts `CREATE INDEX` com opções específicas (fillfactor, compressão, MAXDOP, online).
    * Adiciona comentários com informações sobre o impacto estimado e o número de índices na tabela.
    * Filtra os resultados por um banco de dados específico (database_id = 20), impacto mínimo (avg_user_impact > 75) e exclui tabelas específicas.
4.  **Seleção e Exibição dos Scripts:** Seleciona e exibe os scripts `CREATE INDEX` da tabela temporária.
5.  **Limpeza:** Remove a tabela temporária e as funções criadas.

## Detalhes do Script

```sql
EXEC ('USE tempdb; IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID(''tempdb.dbo.fn_createindex_allcols'')) DROP FUNCTION dbo.fn_createindex_allcols')
	EXEC ('USE tempdb; EXEC(''
CREATE FUNCTION dbo.fn_createindex_allcols (@ix_handle int)
RETURNS NVARCHAR(max)
AS
BEGIN
	DECLARE @ReturnCols NVARCHAR(max)
	;WITH ColumnToPivot ([data()]) AS ( 
		SELECT CONVERT(VARCHAR(3),ic.column_id) + N'''','''' 
		FROM sys.dm_db_missing_index_details id 
		CROSS APPLY sys.dm_db_missing_index_columns(id.index_handle) ic
		WHERE id.index_handle = @ix_handle 
		ORDER BY ic.column_id ASC
		FOR XML PATH(''''''''), TYPE 
		), 
		XmlRawData (CSVString) AS ( 
			SELECT (SELECT [data()] AS InputData 
			FROM ColumnToPivot AS d FOR XML RAW, TYPE).value(''''/row[1]/InputData[1]'''', ''''NVARCHAR(max)'''') AS CSVCol 
		) 
	SELECT @ReturnCols = CASE WHEN LEN(CSVString) <= 1 THEN NULL ELSE LEFT(CSVString, LEN(CSVString)-1) END
	FROM XmlRawData
	RETURN (@ReturnCols)
END'')
	')
GO
	EXEC ('USE tempdb; IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID(''tempdb.dbo.fn_createindex_keycols'')) DROP FUNCTION dbo.fn_createindex_keycols')
	EXEC ('USE tempdb; EXEC(''
CREATE FUNCTION dbo.fn_createindex_keycols (@ix_handle int)
RETURNS NVARCHAR(max)
AS
BEGIN
	DECLARE @ReturnCols NVARCHAR(max)
	;WITH ColumnToPivot ([data()]) AS ( 
		SELECT CONVERT(VARCHAR(3),ic.column_id) + N'''','''' 
		FROM sys.dm_db_missing_index_details id 
		CROSS APPLY sys.dm_db_missing_index_columns(id.index_handle) ic
		WHERE id.index_handle = @ix_handle
		AND (ic.column_usage = ''''EQUALITY'''' OR ic.column_usage = ''''INEQUALITY'''')
		ORDER BY ic.column_id ASC
		FOR XML PATH(''''''''), TYPE 
		), 
		XmlRawData (CSVString) AS ( 
			SELECT (SELECT [data()] AS InputData 
			FROM ColumnToPivot AS d FOR XML RAW, TYPE).value(''''/row[1]/InputData[1]'''', ''''NVARCHAR(max)'''') AS CSVCol 
		) 
	SELECT @ReturnCols = CASE WHEN LEN(CSVString) <= 1 THEN NULL ELSE LEFT(CSVString, LEN(CSVString)-1) END
	FROM XmlRawData
	RETURN (@ReturnCols)
END'')
	')
GO
	EXEC ('USE tempdb; IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID(''tempdb.dbo.fn_createindex_includecols'')) DROP FUNCTION dbo.fn_createindex_includecols')
	EXEC ('USE tempdb; EXEC(''
CREATE FUNCTION dbo.fn_createindex_includecols (@ix_handle int)
RETURNS NVARCHAR(max)
AS
BEGIN
	DECLARE @ReturnCols NVARCHAR(max)
	;WITH ColumnToPivot ([data()]) AS ( 
		SELECT CONVERT(VARCHAR(3),ic.column_id) + N'''','''' 
		FROM sys.dm_db_missing_index_details id 
		CROSS APPLY sys.dm_db_missing_index_columns(id.index_handle) ic
		WHERE id.index_handle = @ix_handle
		AND ic.column_usage = ''''INCLUDE''''
		ORDER BY ic.column_id ASC
		FOR XML PATH(''''''''), TYPE 
		), 
		XmlRawData (CSVString) AS ( 
			SELECT (SELECT [data()] AS InputData 
			FROM ColumnToPivot AS d FOR XML RAW, TYPE).value(''''/row[1]/InputData[1]'''', ''''NVARCHAR(max)'''') AS CSVCol 
		) 
	SELECT @ReturnCols = CASE WHEN LEN(CSVString) <= 1 THEN NULL ELSE LEFT(CSVString, LEN(CSVString)-1) END
	FROM XmlRawData
	RETURN (@ReturnCols)
END'')
	')
	GO

CREATE TABLE #IndexCreation (
    [database_id] INT,
    DBName VARCHAR(255),
    [Table] VARCHAR(255),
    [ix_handle] INT,
    [User_Hits_on_Missing_Index] INT,
    [Estimated_Improvement_Percent] VARCHAR(MAX),
    [Avg_Total_User_Cost] INT,
    [Unique_Compiles] INT,
    [Score] NUMERIC(19,3),
    [KeyCols] VARCHAR(1000),
    [IncludedCols] VARCHAR(4000),
    [Ix_Name] VARCHAR(255),
    [AllCols] NVARCHAR(MAX),
    [KeyColsOrdered] NVARCHAR(MAX),
    [IncludedColsOrdered] NVARCHAR(MAX),
    [Command] NVARCHAR(MAX),
    [Table_Count] INT,
    [Index_Count_in_Table] INT
);

INSERT INTO #IndexCreation
SELECT 
    i.database_id,
    m.[name] AS DBName,
    RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3)) AS [Table],
    i.index_handle AS [ix_handle],
    s.user_seeks + s.user_scans AS [User_Hits_on_Missing_Index],
    CONVERT(VARCHAR(MAX), s.avg_user_impact) AS [Estimated_Improvement_Percent],
    s.avg_total_user_cost AS [Avg_Total_User_Cost],
    s.unique_compiles AS [Unique_Compiles],
    (CONVERT(NUMERIC(19,3), s.user_seeks) + CONVERT(NUMERIC(19,3), s.user_scans)) 
        * CONVERT(NUMERIC(19,3), s.avg_total_user_cost) 
        * CONVERT(NUMERIC(19,3), s.avg_user_impact) AS Score,
    CASE WHEN (i.equality_columns IS NOT NULL AND i.inequality_columns IS NULL) THEN i.equality_columns
            WHEN (i.equality_columns IS NULL AND i.inequality_columns IS NOT NULL) THEN i.inequality_columns
            ELSE i.equality_columns + ',' + i.inequality_columns END AS [KeyCols],
    i.included_columns AS [IncludedCols],
    'IX_' + LEFT(RIGHT(RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3)), LEN(RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3))) - (CHARINDEX('.', RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3)), 1)) - 1),
        LEN(RIGHT(RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3)), LEN(RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3))) - (CHARINDEX('.', RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3)), 1)) - 1)) - 1) + '_' + CAST(i.index_handle AS NVARCHAR) AS [Ix_Name],
    tempdb.dbo.fn_createindex_allcols(i.index_handle), 
    tempdb.dbo.fn_createindex_keycols(i.index_handle),
    tempdb.dbo.fn_createindex_includecols(i.index_handle),
    '
USE [S2]
GO
CREATE INDEX [OrionIx001]'
+ ' ON ' + i.statement
+ ' (' + ISNULL(i.equality_columns,'')
+ CASE WHEN i.equality_columns IS NOT NULL AND i.inequality_columns IS NOT NULL THEN ',' ELSE '' END
+ ISNULL(i.inequality_columns, '') + ')'
+ ISNULL(' INCLUDE (' + i.included_columns + ')', '') + '
WITH (fillfactor = 80, data_compression = page, maxdop=8, online=on)
GO
-- Percentual de melhoria estimado em: ' + CONVERT(VARCHAR, s.avg_user_impact) + '%''
-- Sugerimos a criação de ' + CONVERT(VARCHAR, COUNT(*) OVER(PARTITION BY RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3)))) + ' indice(s) nessa tabela
-- contudo, essa tabela já possui '+(SELECT CONVERT(VARCHAR, COUNT(*)) FROM sys.indexes WHERE object_id = OBJECT_ID(m.[name] + '.' + RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3)))) +' indice(s)
' AS Command,
    COUNT(*) OVER(PARTITION BY RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3))) AS Table_Count,
    (SELECT COUNT(*) FROM sys.indexes WHERE object_id = OBJECT_ID(m.[name] + '.' + RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3)))) AS Index_Count_in_Table
FROM sys.dm_db_missing_index_details i
INNER JOIN master.sys.databases m ON i.database_id = m.database_id
INNER JOIN sys.dm_db_missing_index_groups g ON i.index_handle = g.index_handle
INNER JOIN sys.dm_db_missing_index_group_stats s ON s.group_handle = g.index_group_handle
WHERE i.database_id = 20
AND s.avg_user_impact > 75
AND RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3)) NOT IN ( 
-- Your exclusion list here, as before
'[dbo].[ADMINISTRADORAS_CARTAO_TARIFA]',
'[dbo].[LCF_ATIVO_MOVIMENTO_PERIODO_IMPOSTO]');

SELECT command FROM #IndexCreation;
DROP TABLE #IndexCreation;

EXEC ('USE tempdb; IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID(''tempdb.dbo.fn_createindex_allcols'')) DROP FUNCTION dbo.fn_createindex_allcols')
EXEC ('USE tempdb; IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID(''tempdb.dbo.fn_createindex_keycols'')) DROP FUNCTION dbo.fn_createindex_keycols')
EXEC ('USE tempdb; IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID(''tempdb.dbo.fn_createindex_includecols'')) DROP FUNCTION dbo.fn_createindex_includecols')
