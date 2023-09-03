-- Check Index
SELECT *
FROM
CommandLog
WHERE CommandType = 'ALTER_INDEX'



-- Check checkdb job
SELECT databasename,
command,
StartTime,
EndTime,
datediff (minute, StartTime, EndTime) AS Duration,
ErrorNumber,
ErrorMessage
FROM CommandLog WHERE CommandType='DBCC_CHECKDB'
