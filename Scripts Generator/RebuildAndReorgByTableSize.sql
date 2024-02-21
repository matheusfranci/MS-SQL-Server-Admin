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
	 script = case
        when dm.avg_fragmentation_in_percent > 30 then 'ALTER INDEX ['+ i.name +'] ON ['+ s.name +'].['+ t.name +'] REBUILD;
		GO'
        when dm.avg_fragmentation_in_percent >= 5 and avg_fragmentation_in_percent <= 30 then 'ALTER INDEX ['+ i.name +'] ON ['+ s.name +'].['+ t.name +'] REORGANIZE
		GO'
    end
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
GROUP BY    
    t.[name],   
    s.[name],   
    i.[name],   
    i.[type_desc],  
    p.[rows],
    dm.avg_fragmentation_in_percent    
ORDER BY    
    [size_mb] DESC;
