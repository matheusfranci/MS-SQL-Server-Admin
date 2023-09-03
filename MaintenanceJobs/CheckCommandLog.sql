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
WHERE CommandType = 'ALTER_INDEX';



-- Check checkdb job
SELECT databasename AS "Banco de dados",
command AS Comando,
FORMAT (StartTime, 'dd/MM/yyyy hh:mm:ss') AS Inicio,
FORMAT (EndTime, 'dd/MM/yyyy hh:mm:ss') AS Fim,
datediff (minute, StartTime, EndTime) AS "Duração",
ErrorNumber,
ErrorMessage
FROM ORION.dbo.CommandLog WHERE CommandType='DBCC_CHECKDB'

