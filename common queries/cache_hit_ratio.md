### Descrição
A consulta utiliza uma Common Table Expression (CTE) para calcular a porcentagem de "Cache Hit Ratio" no SQL Server. Ela compara o valor do contador para o cache de plano (`Plan Cache`) e o cache de buffer (`Buffer Cache`), para determinar a taxa de acerto (hit ratio) de cada tipo de cache.

### Consulta para Calculando Cache Hit Ratio
A consulta obtém a razão de acertos de cache dividindo o valor do contador do `Plan Cache` pelo valor do contador do `Buffer Cache` e multiplicando por 100 para obter o percentual.

```sql
WITH cte1 AS (
    SELECT 
        [dopc].[object_name],
        [dopc].[instance_name],
        [dopc].[counter_name],
        [dopc].[cntr_value],
        [dopc].[cntr_type],
        ROW_NUMBER() OVER (PARTITION BY [dopc].[object_name], [dopc].[instance_name] ORDER BY [dopc].[counter_name]) AS r_n
    FROM [sys].[dm_os_performance_counters] AS dopc
    WHERE [dopc].[counter_name] LIKE '%Cache Hit Ratio%'
        AND ([dopc].[object_name] LIKE '%Plan Cache%' OR [dopc].[object_name] LIKE '%Buffer Cache%')
        AND [dopc].[instance_name] LIKE '%_Total%'
)
SELECT
    GETDATE() AS [Data],
    CONVERT(DECIMAL(16, 2), ([c].[cntr_value] * 1.0 / [c1].[cntr_value]) * 100.0) AS [hit_pct]
FROM [cte1] AS c
INNER JOIN [cte1] AS c1
    ON c.[object_name] = c1.[object_name]
    AND c.[instance_name] = c1.[instance_name]
WHERE [c].[r_n] = 1
    AND [c1].[r_n] = 2;
```