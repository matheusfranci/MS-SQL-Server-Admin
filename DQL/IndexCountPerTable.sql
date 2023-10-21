WITH CTE_Count AS (
    SELECT 
        i.[name] AS index_name,
        SUBSTRING(column_names, 1, LEN(column_names) - 1) AS [columns],
        CASE 
            WHEN i.[type] = 1 THEN 'Clustered index'
            WHEN i.[type] = 2 THEN 'Nonclustered unique index'
            WHEN i.[type] = 3 THEN 'XML index'
            WHEN i.[type] = 4 THEN 'Spatial index'
            WHEN i.[type] = 5 THEN 'Clustered columnstore index'
            WHEN i.[type] = 6 THEN 'Nonclustered columnstore index'
            WHEN i.[type] = 7 THEN 'Nonclustered hash index'
        END AS index_type,
        CASE 
            WHEN i.is_unique = 1 THEN 'Unique'
            ELSE 'Not unique' 
        END AS [unique],
        SCHEMA_NAME(t.schema_id) + '.' + t.[name] AS table_view,
        CASE 
            WHEN t.[type] = 'U' THEN 'Table'
            WHEN t.[type] = 'V' THEN 'View'
        END AS [object_type]
    FROM 
        sys.objects t
    INNER JOIN 
        sys.indexes i ON t.object_id = i.object_id
    CROSS APPLY (
        SELECT 
            col.[name] + ', '
        FROM 
            sys.index_columns ic
        INNER JOIN 
            sys.columns col ON ic.object_id = col.object_id
            AND ic.column_id = col.column_id
        WHERE 
            ic.object_id = t.object_id
            AND ic.index_id = i.index_id
        ORDER BY 
            key_ordinal
        FOR XML PATH('')
    ) D (column_names)
    WHERE 
        t.is_ms_shipped <> 1
        AND index_id > 0
        AND schema_name(t.schema_id) + '.' + t.[name] IN (
            'dbo.ADV_ARQUIVO_DISTRIBUICAO_PRODUTO',
'dbo.ADV_AUTOMATIZA_ENTRADA_DEVOLUCAO',
'dbo.ADV_CONTROLE_FATURAMENTO_AUTOMATICO',
'dbo.ADV_FATURAMENTO_VALIDACAO',
'dbo.ADV_PEDIDO_ECOM_TRANSF_VAREJO',
'dbo.CADASTRO_CLI_FOR',
'dbo.CLIENTES_VAREJO',
'dbo.COMPRAS',
'dbo.CONTATO',
'dbo.CONTATO_ENDERECO',
'dbo.CTB_A_PAGAR_PARCELA',
'dbo.CTB_ACOMPANHAMENTO',
'dbo.CTB_LOTE',
'dbo.ENTRADAS',
'dbo.ESTOQUE_PRODUTOS',
'dbo.ESTOQUE_SAI_MAT',
'dbo.FATURAMENTO_PROD',
'dbo.LF_REGISTRO_ENTRADA',
'dbo.LJ_LF_ECF_ITEM',
'dbo.LOG_CALCULO',
'dbo.LOJA_ENTRADAS',
'dbo.LOJA_NOTA_FISCAL',
'dbo.LOJA_NOTA_FISCAL_ITEM',
'dbo.LOJA_PEDIDO',
'dbo.LOJA_VENDA_PRODUTO',
'dbo.LOJA_VENDA_VENDEDORES',
'dbo.MIT_GNRE_LOG',
'dbo.PIT_CONTROLE_ALOCACAO_REMESSAS_OP',
'dbo.PRODUTO_VERSAO_MATERIAL',
'dbo.PRODUTOS',
'dbo.PRODUTOS_BARRA',
'dbo.PRODUTOS_PRECO_FILIAL',
'dbo.PROP_CLIENTES_VAREJO',
'dbo.PROP_COMPRAS',
'dbo.TRANSACOES_OBJETO',
'dbo.VENDAS',
'dbo.VENDAS_PROD_EMBALADO',
'dbo.VENDAS_PROD_EMBALADO_AUDIT',
'dbo.VENDAS_PRODUTO',
'SAR.USU_VTEX_PEDIDO_PAGTOS',
'SAR.USU_VTEX_PEDIDOS',
'SAR.USU_VTEX_PEDIDOS_CLIENTE',
'SAR.USU_VTEX_PRODUTOS_BARRA_KENNER'
        )
)

SELECT 
    index_name,
    [columns],
    index_type,
    [unique],
    table_view,
    object_type,
    (SELECT COUNT(*) FROM CTE_Count AS sub WHERE sub.table_view = main.table_view) AS IndexNumberPerTable
FROM 
    CTE_Count main
GROUP BY 
    index_name, [columns], index_type, [unique], table_view, object_type
ORDER BY 
    table_view;
