-- Check Index
SELECT
DATABASENAME,
SCHEMANAME,
OBJECTNAME,
INDEXNAME,
COMMAND,
FORMAT (StartTime, 'dd/MM/yyyy hh:mm:ss') AS Inicio,
FORMAT (EndTime, 'dd/MM/yyyy hh:mm:ss') AS Fim,
datediff (minute, StartTime, EndTime) AS "Duração"
FROM
CommandLog
WHERE CommandType = 'ALTER_INDEX'
AND StartTime >= dateadd(day,datediff(day,1,GETDATE()),0)
AND StartTime < dateadd(day,datediff(day,0,GETDATE()),0)



-- Check checkdb job
SELECT databasename AS "Banco de dados",
command AS Comando,
FORMAT (StartTime, 'dd/MM/yyyy hh:mm:ss') AS Inicio,
FORMAT (EndTime, 'dd/MM/yyyy hh:mm:ss') AS Fim,
datediff (minute, StartTime, EndTime) AS "Duração",
ErrorNumber,
ErrorMessage
FROM ORION.dbo.CommandLog WHERE CommandType='DBCC_CHECKDB'
AND StartTime >= dateadd(day,datediff(day,1,GETDATE()),0)
AND StartTime < dateadd(day,datediff(day,0,GETDATE()),0)
