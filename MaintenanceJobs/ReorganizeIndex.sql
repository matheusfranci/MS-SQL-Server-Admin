declare @porcentagem_fragmentacao int 
set @porcentagem_fragmentacao = 30
DECLARE @DB_Name VARCHAR(100);
DECLARE @Command NVARCHAR(200);
DECLARE @tbl TABLE(string VARCHAR(MAX));
DECLARE database_cursor CURSOR
FOR SELECT name
    FROM sys.databases
    WHERE database_id not in (1,2,3,4,38) ;
OPEN database_cursor;
FETCH NEXT FROM database_cursor INTO @DB_Name;
WHILE @@FETCH_STATUS = 0
    BEGIN
        DELETE FROM @TBL
        INSERT INTO @tbl
        EXEC ('USE '+@DB_Name+' SELECT ''alter index '' + dbindexes.[name] + '' on ''+ dbschemas.[name] +''.'' + dbtables.[name] + '' reorganize''
 
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = DB_ID()  and avg_fragmentation_in_percent > 5 and avg_fragmentation_in_percent <'+ @porcentagem_fragmentacao +' and dbindexes.[name] is not null
ORDER BY indexstats.avg_fragmentation_in_percent desc');
        DECLARE @comando VARCHAR(MAX);
        DECLARE rebuildindice CURSOR
        FOR SELECT string
            FROM @tbl;
        OPEN rebuildindice;
        FETCH NEXT FROM rebuildindice INTO @comando;
        WHILE @@FETCH_STATUS = 0
            BEGIN
			
                DECLARE @cmd VARCHAR(MAX);
                SET @cmd = 'use ' + @DB_Name + ' ' + @comando;
                exec (@cmd);
				PRINT @cmd;
			
                FETCH NEXT FROM rebuildindice INTO @comando;
            END;
        CLOSE rebuildindice;
        DEALLOCATE rebuildindice;
        FETCH NEXT FROM database_cursor INTO @DB_Name;
    END;
	
CLOSE database_cursor; 
DEALLOCATE database_cursor;
