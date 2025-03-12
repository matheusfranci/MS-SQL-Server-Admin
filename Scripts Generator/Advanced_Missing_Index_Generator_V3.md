# Geração Altamente Otimizada de Scripts de Criação de Índices Ausentes

Este script SQL realiza uma análise ainda mais refinada de índices ausentes, gerando scripts `CREATE INDEX` personalizados com base em recomendações das DMVs do SQL Server. Ele inclui funções para manipular colunas de índice, um ranking baseado em impacto, otimizações na criação e manipulação da tabela temporária, e ajustes no tipo de dados para maior precisão.

## Visão Geral do Script Atualizado

O script executa as seguintes etapas:

1.  **Criação de Funções de Manipulação de Colunas (tempdb):**
    * `dbo.fn_createindex_allcols`: Retorna todas as colunas de um índice ausente como uma string separada por vírgulas.
    * `dbo.fn_createindex_keycols`: Retorna as colunas de chave (igualdade e desigualdade) de um índice ausente como uma string separada por vírgulas.
    * `dbo.fn_createindex_includecols`: Retorna as colunas incluídas de um índice ausente como uma string separada por vírgulas.
2.  **Manipulação da Tabela Temporária `#IndexCreation`:**
    * Verifica se a tabela temporária `#IndexCreation` existe e a remove se necessário.
    * Cria a tabela temporária `#IndexCreation` com colunas relevantes para armazenar informações sobre índices ausentes, incluindo a alteração do tipo de dados `Estimated_Improvement_Percent` para `DECIMAL(5,2)`.
3.  **Inserção de Dados na Tabela Temporária (com Melhorias):**
    * Consulta as DMVs `sys.dm_db_missing_index_details`, `master.sys.databases`, `sys.dm_db_missing_index_groups` e `sys.dm_db_missing_index_group_stats` para obter informações sobre índices ausentes.
    * Calcula um score baseado no impacto, custo e buscas do usuário.
    * Utiliza as funções criadas para obter as colunas de chave e incluídas.
    * Gera um nome de índice personalizado.
    * Gera scripts `CREATE INDEX` com opções específicas (fillfactor = 90, compressão, MAXDOP, online).
    * Gera o script `CREATE INDEX` diretamente, utilizando `OBJECT_NAME` para obter o nome da tabela.
    * Filtra os resultados por um banco de dados específico (database_id = 20).
4.  **Seleção e Exibição dos Dados:** Seleciona e exibe todos os dados da tabela temporária `#IndexCreation`.
5.  **Limpeza:** Remove as funções criadas.

## Detalhes do Script Atualizado

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
IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#IndexCreation'))
	DROP TABLE #IndexCreation;
	IF NOT EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID('tempdb.dbo.#IndexCreation'))
	CREATE TABLE #IndexCreation (
		[database_id] int,
		DBName VARCHAR(255),
		[Table] VARCHAR(255),
		[ix_handle] int,
		[User_Hits_on_Missing_Index] int,
		[Estimated_Improvement_Percent] DECIMAL(5,2),
		[Avg_Total_User_Cost] int,
		[Unique_Compiles] int,
		[Score] NUMERIC(19,3),
		[KeyCols] VARCHAR(1000),
		[IncludedCols] VARCHAR(4000),
		[Ix_Name] VARCHAR(255),
		[AllCols] NVARCHAR(max),
		[KeyColsOrdered] NVARCHAR(max),
		[IncludedColsOrdered] NVARCHAR(max),
		[Command] NVARCHAR(max)
		)
GO

INSERT INTO #IndexCreation
	SELECT i.database_id,
		m.[name],
		RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3)) AS [Table],
		i.index_handle AS [ix_handle],
		[User_Hits_on_Missing_Index] = (s.user_seeks + s.user_scans),
		s.avg_user_impact, -- Query cost would reduce by this amount in percentage, on average.
		s.avg_total_user_cost, -- Average cost of the user queries that could be reduced by the index in the group.
		s.unique_compiles, -- Number of compilations and recompilations that would benefit from this missing index group.
		(CONVERT(NUMERIC(19,3), s.user_seeks) + CONVERT(NUMERIC(19,3), s.user_scans)) 
			* CONVERT(NUMERIC(19,3), s.avg_total_user_cost) 
			* CONVERT(NUMERIC(19,3), s.avg_user_impact) AS Score, -- The higher the score, higher is the anticipated improvement for user queries.
		CASE WHEN (i.equality_columns IS NOT NULL AND i.inequality_columns IS NULL) THEN i.equality_columns
				WHEN (i.equality_columns IS NULL AND i.inequality_columns IS NOT NULL) THEN i.inequality_columns
				ELSE i.equality_columns + ',' + i.inequality_columns END AS [KeyCols],
		i.included_columns AS [IncludedCols],
		'IX_' + LEFT(RIGHT(RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3)), LEN(RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3))) - (CHARINDEX('.', RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3)), 1)) - 1),
			LEN(RIGHT(RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3)), LEN(RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3))) - (CHARINDEX('.', RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3)), 1)) - 1)) - 1) + '_' + CAST(i.index_handle AS NVARCHAR) AS [Ix_Name],
		tempdb.dbo.fn_createindex_allcols(i.index_handle), 
		tempdb.dbo.fn_createindex_keycols(i.index_handle),
		tempdb.dbo.fn_createindex_includecols(i.index_handle),
		'CREATE INDEX [IX_' + OBJECT_NAME(i.OBJECT_ID,i.database_id) + '_'
+ REPLACE(REPLACE(REPLACE(ISNULL(i.equality_columns,''),', ','_'),'[',''),']','') 
+ CASE
WHEN i.equality_columns IS NOT NULL
AND i.inequality_columns IS NOT NULL THEN '_'
ELSE ''
END
+ REPLACE(REPLACE(REPLACE(ISNULL(i.inequality_columns,''),', ','_'),'[',''),']','')
+ ']'
+ ' ON ' + i.statement
+ ' (' + ISNULL (i.equality_columns,'')
+ CASE WHEN i.equality_columns IS NOT NULL AND i.inequality_columns 
IS NOT NULL THEN ',' ELSE
'' END
+ ISNULL (i.inequality_columns, '')
+ ')'
+ ISNULL (' INCLUDE (' + i.included_columns + ')', '') + ' WITH (fillfactor = 90, data_compression = page, maxdop=8, online=on)
GO' AS Command
	FROM sys.dm_db_missing_index_details i
	INNER JOIN master.sys.databases m ON i.database_id = m.database_id
	INNER JOIN sys.dm_db_missing_index_groups g ON i.index_handle = g.index_handle
	INNER JOIN sys.dm_db_missing_index_group_stats s ON s.group_handle = g.index_group_handle
	WHERE i.database_id = 20

	SELECT * FROM #IndexCreation
	
EXEC ('USE tempdb; IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID(''tempdb.dbo.fn_createindex_allcols'')) DROP FUNCTION dbo.fn_createindex_allcols')
EXEC ('USE tempdb; IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID(''tempdb.dbo.fn_createindex_keycols'')) DROP FUNCTION dbo.fn_createindex_keycols')
EXEC ('USE tempdb; IF EXISTS (SELECT [object_id] FROM tempdb.sys.objects (NOLOCK) WHERE [object_id] = OBJECT_ID(''tempdb.dbo.fn_createindex_includecols'')) DROP FUNCTION dbo.fn_createindex_includecols')
