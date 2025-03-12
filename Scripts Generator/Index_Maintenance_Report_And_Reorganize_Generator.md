# Relatório de Fragmentação de Índices e Geração de Scripts de Reorganização

Este script SQL gera um relatório detalhado sobre a fragmentação de índices em um banco de dados, incluindo informações sobre esquema, tabela, índice, tipo de índice, contagem de linhas, tamanho em MB, fragmentação e scripts `ALTER INDEX REORGANIZE`. Ele filtra os índices para incluir apenas aqueles com fragmentação entre 5% e 30% e gera scripts para reorganizá-los.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Consulta `sys.tables`, `sys.indexes`, `sys.partitions`, `sys.allocation_units`, `sys.schemas`, `sys.dm_db_index_physical_stats`:** Consulta várias tabelas de sistema e DMFs para obter informações sobre tabelas, índices, partições, alocação de páginas, esquemas e fragmentação de índices.
2.  **Cálculo de Tamanho em MB:** Calcula o tamanho total, usado e não usado dos índices em megabytes.
3.  **Filtragem de Índices:** Filtra os índices para incluir apenas aqueles que não são de sistema, têm IDs de objeto maiores que 255, têm nomes válidos e fragmentação entre 5% e 30%.
4.  **Geração de Scripts `ALTER INDEX REORGANIZE`:** Gera scripts `ALTER INDEX REORGANIZE`.
5.  **Agrupamento e Ordenação:** Agrupa os resultados por tabela, esquema, índice, tipo de índice, contagem de linhas e fragmentação, e ordena os resultados por tamanho em MB decrescente.
6.  **Exibição dos Resultados:** Exibe o relatório detalhado e os scripts gerados.

## Detalhes do Script

```sql
SELECT
    s.[name] AS [schema],
    t.[name] AS [table_name],
    i.[name] AS [index_name],
    i.[type_desc],
    p.[rows] AS [row_count],
    CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS [size_mb],
    CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS [used_mb],
    CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS [unused_mb],
    dm.avg_fragmentation_in_percent AS [fragmentation],
    'ALTER INDEX ['+ i.name +'] ON ['+s.name+'].['+ t.name +'] REORGANIZE
GO' as Command
FROM
    sys.tables t
    JOIN sys.indexes i ON t.[object_id] = i.[object_id]
    JOIN sys.partitions p ON t.[object_id] = p.[object_id]
    JOIN sys.allocation_units a ON p.[partition_id] = a.container_id
    LEFT JOIN sys.schemas s ON t.[schema_id] = s.[schema_id]
    LEFT JOIN sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) dm ON t.[object_id] = dm.[object_id] AND i.[index_id] = dm.[index_id]
WHERE
    t.is_ms_shipped = 0
    AND i.[object_id] > 255
    AND i.name IS NOT NULL
    AND dm.avg_fragmentation_in_percent > 5
    AND dm.avg_fragmentation_in_percent < 30
GROUP BY
    t.[name],
    s.[name],
    i.[name],
    i.[type_desc],
    p.[rows],
    dm.avg_fragmentation_in_percent
ORDER BY
    [size_mb] DESC;
