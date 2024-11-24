### Descrição
As consultas acima são usadas para identificar índices faltantes no banco de dados SQL Server e calcular o impacto que a criação desses índices teria no desempenho das consultas. A primeira consulta retorna as 20 principais recomendações de índices faltantes, enquanto a segunda consulta fornece uma análise detalhada dos índices faltantes e sugere comandos `CREATE INDEX` para adicioná-los.

### Primeira Consulta - Índices Faltantes Principais
A consulta abaixo retorna as 20 recomendações principais de índices faltantes, com base no custo total da consulta que poderia ser reduzido pela criação do índice.

```sql
SELECT TOP 20
    ROUND(s.avg_total_user_cost *
          s.avg_user_impact
          * (s.user_seeks + s.user_scans), 0) AS [Total Cost],
    d.[statement] AS [Table Name],
    equality_columns,
    inequality_columns,
    included_columns
FROM sys.dm_db_missing_index_groups g
INNER JOIN sys.dm_db_missing_index_group_stats s
  ON s.group_handle = g.index_group_handle
INNER JOIN sys.dm_db_missing_index_details d
  ON d.index_handle = g.index_handle
ORDER BY [Total Cost] DESC;
```

### Segunda Consulta - Índices Faltantes Detalhados
Essa consulta fornece uma análise detalhada dos índices faltantes, incluindo o impacto potencial que eles teriam nas consultas de usuários e no sistema, além de sugerir a criação de novos índices.


```sql
SELECT db.[name] AS [DatabaseName],
       id.[object_id] AS [ObjectID],
       OBJECT_NAME(id.[object_id], db.[database_id]) AS [ObjectName],
       id.[statement] AS [FullyQualifiedObjectName],
       id.[equality_columns] AS [EqualityColumns],
       id.[inequality_columns] AS [InEqualityColumns],
       id.[included_columns] AS [IncludedColumns],
       gs.[unique_compiles] AS [UniqueCompiles],
       gs.[user_seeks] AS [UserSeeks],
       gs.[user_scans] AS [UserScans],
       gs.[last_user_seek] AS [LastUserSeekTime],
       gs.[last_user_scan] AS [LastUserScanTime],
       gs.[avg_total_user_cost] AS [AvgTotalUserCost],
       gs.[avg_user_impact] AS [AvgUserImpact],
       gs.[system_seeks] AS [SystemSeeks],
       gs.[system_scans] AS [SystemScans],
       gs.[last_system_seek] AS [LastSystemSeekTime],
       gs.[last_system_scan] AS [LastSystemScanTime],
       gs.[avg_total_system_cost] AS [AvgTotalSystemCost],
       gs.[avg_system_impact] AS [AvgSystemImpact],
       gs.[user_seeks] * gs.[avg_total_user_cost] * (gs.[avg_user_impact] * 0.01) AS [IndexAdvantage],
       'CREATE INDEX [IX_' + OBJECT_NAME(id.[object_id], db.[database_id]) + '_' + REPLACE(REPLACE(REPLACE(ISNULL(id.[equality_columns], ''), ', ', '_'), '[', ''), ']', '') + CASE
           WHEN id.[equality_columns] IS NOT NULL
               AND id.[inequality_columns] IS NOT NULL
               THEN '_'
           ELSE ''
       END + REPLACE(REPLACE(REPLACE(ISNULL(id.), 5) + ']' + ' ON ' + id.[statement] + ' (' + ISNULL(id.[equality_columns], '') + CASE
           WHEN id.[equality_columns] IS NOT NULL
               AND id.[inequality_columns] IS NOT NULL
               THEN ','
           ELSE ''
       END + ISNULL(id.[inequality_columns], '') + ')' + ISNULL(' INCLUDE (' + id.[included_columns] + ')', '') AS [ProposedIndex],
       CAST(CURRENT_TIMESTAMP AS [smalldatetime]) AS [CollectionDate]
FROM [sys].[dm_db_missing_index_group_stats] gs WITH (NOLOCK)
INNER JOIN [sys].[dm_db_missing_index_groups] ig WITH (NOLOCK) ON gs.[group_handle] = ig.[index_group_handle]
INNER JOIN [sys].[dm_db_missing_index_details] id WITH (NOLOCK) ON ig.[index_handle] = id.[index_handle]
INNER JOIN [sys].[databases] db WITH (NOLOCK) ON db.[database_id] = id.[database_id]
WHERE db.[database_id] = DB_ID()
--AND OBJECT_NAME(id.[object_id], db.[database_id]) = 'YourTableName'
ORDER BY ObjectName, [IndexAdvantage] DESC
OPTION (RECOMPILE);
```