### Descrição da Query

Esta consulta tem como objetivo obter informações sobre as estatísticas de tabelas e suas colunas em um banco de dados SQL Server, incluindo detalhes sobre a data de atualização das estatísticas, contagem de modificações, e outras propriedades associadas a elas. A query retorna as seguintes informações:

- **TableName**: Nome da tabela.
- **ColumnName**: Nome da coluna associada à estatística.
- **StatName**: Nome da estatística.
- **LastUpdated**: Data da última atualização da estatística.
- **DaysOld**: Quantidade de dias desde a última atualização da estatística.
- **modification_counter**: Contador de modificações da tabela que afetam a estatística.
- **auto_created**: Indica se a estatística foi criada automaticamente pelo SQL Server.
- **user_created**: Indica se a estatística foi criada pelo usuário.
- **no_recompute**: Indica se a estatística tem a opção de não ser recalculada automaticamente.
- **stats_column_id**: ID da coluna na estatística.
- **column_id**: ID da coluna na tabela.
- **Stats ID**: ID da estatística.

A consulta filtra apenas as tabelas de usuário e estatísticas que foram criadas automaticamente ou pelo usuário. Os resultados são ordenados pela quantidade de dias desde a última atualização da estatística (campo `DaysOld`), do mais antigo para o mais recente.

```SQL
SELECT DISTINCT
OBJECT_NAME(s.[object_id]) AS TableName,
c.name AS ColumnName,
s.name AS StatName,
STATS_DATE(s.[object_id], s.stats_id) AS LastUpdated,
DATEDIFF(d,STATS_DATE(s.[object_id], s.stats_id),getdate()) DaysOld,
dsp.modification_counter,
s.auto_created,
s.user_created,
s.no_recompute,
s.[object_id],
s.stats_id,
sc.stats_column_id,
sc.column_id
FROM sys.stats s
JOIN sys.stats_columns sc
ON sc.[object_id] = s.[object_id] AND sc.stats_id = s.stats_id
JOIN sys.columns c ON c.[object_id] = sc.[object_id] AND c.column_id = sc.column_id
JOIN sys.partitions par ON par.[object_id] = s.[object_id]
JOIN sys.objects obj ON par.[object_id] = obj.[object_id]
CROSS APPLY sys.dm_db_stats_properties(sc.[object_id], s.stats_id) AS dsp
WHERE OBJECTPROPERTY(s.OBJECT_ID,'IsUserTable') = 1
AND (s.auto_created = 1 OR s.user_created = 1)
ORDER BY DaysOld;
```