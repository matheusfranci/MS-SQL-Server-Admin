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
'[dbo].[LCF_ATIVO_MOVIMENTO_PERIODO_IMPOSTO]',
'[dbo].[PRODUTIV_OPERACOES]',
'[dbo].[LF_DADOS_ARRECADACAO]',
'[dbo].[CTB_CENTRO_CUSTO]',
'[dbo].[FATURAMENTO_OCORRENCIAS]',
'[dbo].[CTB_CHEQUE_CARTAO]',
'[dbo].[LOG_OMS_HISTORICO_CONSULTA]',
'[dbo].[LF_LX_NATUREZA_JURIDICA]',
'[dbo].[LF_LX_NATUREZA_RENDIMENTO]',
'[dbo].[PRODUTOS_LINHA_NEGOCIO]',
'[dbo].[LF_LX_NATUREZA_RENDIMENTO_IMPOSTO]',
'[dbo].[CTB_CONTA_PLANO]',
'[dbo].[PRODUTOS_GRUPO]',
'[dbo].[LCF_APURACAO_ITEM]',
'[dbo].[LCF_REDUCAO_CUPOM]',
'[dbo].[LOJA_PEDIDO_VENDA]',
'[dbo].[CTB_HIST_PADRAO]',
'[dbo].[CTE_XML]',
'[dbo].[CTE_XML_ITEM]',
'[dbo].[PRODUTOS_CATEGORIA]',
'[dbo].[CATALOGSCHEMASP]',
'[dbo].[PRODUTOS_GRIFFE_GRUPO]',
'[dbo].[CTE_XML_LOG]',
'[dbo].[CTB_MOVIMENTO_B2C]',
'[dbo].[CATALOGTABLESP]',
'[dbo].[CTB_LANC_PADRAO_ITEM]',
'[dbo].[PRODUTOS_SUBCATEGORIA]',
'[dbo].[LCF_CFE_REFERENCIA]',
'[dbo].[CATALOGCOLSSP]',
'[dbo].[PRODUTOS_SUBGRUPO]',
'[dbo].[CATALOGDEFAULTSP]',
'[dbo].[PRODUTOS_TAB_MEDIDAS]',
'[dbo].[PRODUTOS_TAB_OPERACOES]',
'[dbo].[ADV_PRODUTOS_TIPOS]',
'[dbo].[CatalogIndexSP]',
'[dbo].[PRODUTOS_TIPOS]',
'[dbo].[LOJA_PEDIDO_PGTO]',
'[dbo].[CATALOGFOREIGNKEYSP]',
'[dbo].[ADV_PRODUTOS_MODELAGEM]',
'[dbo].[JOBS]',
'[dbo].[MEDIDAS]',
'[dbo].[CTB_LX_LANCAMENTO_TIPO]',
'[dbo].[LOJA_VENDA]',
'[dbo].[CONFIG_TRIBUTARIA]',
'[dbo].[ADV_PRODUTOS_FIT]',
'[dbo].[CONFIG_TRIBUTARIA_EXCECAO]',
'[dbo].[ADV_PRODUTOS_CINTURA]',
'[dbo].[TABELA_CODIGO_AJUSTE_SPED]',
'[dbo].[CONFIG_TRIBUTARIA_FILIAL]',
'[dbo].[ADV_PRODUTOS_MANGA]',
'[dbo].[CONFIG_TRIBUTARIA_DETALHAMENTO]',
'[dbo].[ADV_PRODUTOS_DECOTE]',
'[dbo].[TELAS_CUSTOMIZADAS]',
'[dbo].[ADV_PRODUTOS_COMPRIMENTO]',
'[dbo].[ADQUIRENTES_EQUALS]',
'[dbo].[BANDEIRAS_EQUALS]',
'[dbo].[LOJA_VENDA_PARCELAS]',
'[dbo].[LCF_CFE_PGTO]',
'[dbo].[LF_REGISTRO_SAIDA_ITEM]',
'[dbo].[ADMINISTRADORAS_DEPARA_EQUALS]',
'[dbo].[CTB_CONF_BAIXA_EQUALS]',
'[dbo].[LF_INTEGRACAO_GOVERNO_ARQUIVO]',
'[dbo].[ORCAMENTOS]',
'[dbo].[LF_SUB_ITEM_APURACAO]',
'[dbo].[CTB_CONF_BAIXA_EQUALS_CC]',
'[dbo].[PRODUTOS_MODELO]',
'[dbo].[ESTOQUE_RET1_MAT]',
'[dbo].[FATURAMENTO]',
'[dbo].[CTB_CONTROLE_RELATORIO_EQUALS_DOWNLOAD]',
'[dbo].[LCF_INF_CONTRIBUINTE_REINF]',
'[dbo].[CTB_CONTROLE_RELATORIO_EQUALS]',
'[dbo].[LCF_LANCAMENTO]',
'[dbo].[LCF_INF_CONTRIBUINTE_REINF_ALTERACAO]',
'[dbo].[LCF_TERCEIRO]',
'[dbo].[ESTOQUE_MAT_CTG_ITENS]',
'[dbo].[VENDAS_COTAS_TIPO_ITENS]',
'[dbo].[CTB_CONTROLE_RELATORIO_EQUALS_LOG]',
'[dbo].[PRODUTOS_LOG]',
'[dbo].[EQUALS_LOG_CTB_CHEQUE_CARTAO]',
'[dbo].[LCF_REDUCAO_CUPOM_PGTO]',
'[dbo].[EQUALS_LOG_CTB_LANCAMENTO_ITEM]',
'[dbo].[EQUALS_LOJA_VENDA_PARCELAS]',
'[dbo].[TIPO_MOVIMENTO_EQUALS]',
'[dbo].[FATURAMENTO_PGTO]',
'[dbo].[CTB_CHEQUE_CARTAO_ENVIADO]',
'[dbo].[FORMA_PGTO]',
'[dbo].[ESTOQUE_PROD_ENT]',
'[dbo].[FORMA_PGTO_PARCELA]',
'[dbo].[LF_LX_MDM]',
'[dbo].[LF_REGISTRO_SAIDA]',
'[dbo].[LCF_CFE]',
'[dbo].[PRODUTOS_GRIFFE_CATEGORIA]',
'[dbo].[LCF_CFE_IMPOSTO]',
'[dbo].[MODIFICACAO_FICHA_TECNICA]',
'[dbo].[LCF_CFE_ITEM]',
'[dbo].[DADOS_CADASTRO_XML_NFE]',
'[dbo].[CTB_A_RECEBER_FATURA]',
'[dbo].[B2C_PRODUTOS]',
'[dbo].[DOCA_GRUPO_PRODUTO]',
'[dbo].[PACOTE_MATERIAIS_ITEM]',
'[dbo].[DOCA_SUBGRUPO_PRODUTO]');

SELECT command FROM #IndexCreation;
DROP TABLE #IndexCreation;
