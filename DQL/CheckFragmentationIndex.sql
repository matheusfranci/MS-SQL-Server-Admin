SELECT object_name(ips.object_id) AS TableName,
    ips.index_id, name AS IndexName, avg_fragmentation_in_percent,db_name(ips.database_id) AS DatabaseName
FROM sys.dm_db_index_physical_stats
    (Db_id(DB_NAME())
        , NULL
        , NULL
        , NULL
        , NULL) AS ips
INNER JOIN sys.indexes AS SI
    ON ips.object_id = SI.object_id
    AND ips.index_id = SI.index_id
WHERE ips.avg_fragmentation_in_percent > 30 
     AND SI.index_id <> 0
GO
