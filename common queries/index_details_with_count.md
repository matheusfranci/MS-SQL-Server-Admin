### Descrição
Essa query retorna informações detalhadas sobre os índices de uma tabela ou visão específica no SQL Server. Ela inclui o nome do índice, os campos indexados, o tipo de índice, se o índice é único, e a tabela ou visão associada ao índice. Além disso, conta o número de índices por tabela ou visão.

### Detalhes
1. **`CTE_Count` (Common Table Expression):** Utiliza uma CTE para coletar informações sobre os índices de uma tabela ou visão, incluindo os nomes das colunas indexadas, o tipo de índice, se é único, e o nome da tabela/visão.
2. **`sys.objects`, `sys.indexes`, `sys.index_columns`, `sys.columns`:** Tabelas do sistema que fornecem informações sobre objetos, índices e suas colunas associadas.
3. **`FOR XML PATH('')`:** Usado para concatenar os nomes das colunas indexadas em uma única string.
4. **Contagem de índices por tabela:** O número de índices para cada tabela ou visão é calculado pela subconsulta dentro da CTE.
5. **Filtragem por `table_view`:** A consulta filtra os resultados para uma tabela ou visão específica, como `'dbo.SampleTable'`.

### Exemplo de Uso
```sql
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
            'dbo.SampleTable'
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
	```