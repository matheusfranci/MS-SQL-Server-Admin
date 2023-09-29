---------------
|sp_BlitzCache|
---------------
"Which queries have been using the most resources?"
EXEC sp_BlitzCache 
@Top = 20, @ExportToExcel = 1, @DatabaseName = 'S2'

----------------------------
|Speed Check: sp_BlitzFirst|
----------------------------
"Why is my SQL Server slow right now?"

EXEC sp_BlitzFirst 
  @OutputDatabaseName = 'ORION', 
  @OutputSchemaName = 'dbo', 
  @OutputTableName = 'BlitzFirst',
  @OutputTableNameFileStats = 'BlitzFirst_FileStats',
  @OutputTableNamePerfmonStats = 'BlitzFirst_PerfmonStats',
  @OutputTableNameWaitStats = 'BlitzFirst_WaitStats',
  @OutputTableNameBlitzCache = 'BlitzCache',
  @OutputType = 'none'
  

----------
|sp_Blitz|
----------
"Is my SQL Server healthy, or sick?"
EXEC sp_Blitz @CheckUserDatabaseObjects = 0;

---------------
|sp_BlitzIndex|
---------------
"Are my indexes designed for speed?"
EXEC sp_BlitzIndex


-------------
|sp_BlitzWho|
-------------
"Who’s running what queries right now?"
EXEC sp_BlitzWho
