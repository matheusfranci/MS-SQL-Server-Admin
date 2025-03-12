Markdown

# Scripts de Monitoramento de SQL Server

Este documento descreve três scripts SQL para monitorar diferentes aspectos de um servidor SQL Server.

## 1. Verificação de Índices (Check Index)

Este script consulta a tabela `CommandLog` para obter informações sobre operações de `ALTER_INDEX` executadas no dia anterior.

```sql
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
```

## 2. Verificação do Job DBCC CHECKDB (Check checkdb job)
        
Este script consulta a tabela CommandLog para obter informações sobre operações DBCC_CHECKDB executadas no dia anterior.
        
```sql
SELECT databasename AS "Banco de dados",
command AS Comando,
FORMAT (StartTime, 'dd/MM/yyyy hh:mm:ss') AS Inicio,
FORMAT (EndTime, 'dd/MM/yyyy hh:mm:ss') AS Fim,
datediff (minute, StartTime, EndTime) AS "Duração",
        FORMAT (CONVERT(datetime, '19000101', 120) + 
            DATEADD(minute, datediff(minute, StartTime, EndTime), 0), 'HH:mm') AS "Duração Total (HH:mm)",
ErrorNumber,
ErrorMessage
FROM dbo.CommandLog WHERE CommandType='DBCC_CHECKDB'
AND StartTime >= dateadd(day,datediff(day,1,GETDATE()),0)
AND StartTime < dateadd(day,datediff(day,0,GETDATE()),0)
```
        
## 3. Verificação do Progresso do DBCC CHECKDB (CHECK DBCC CHECK progress)
        
Este script consulta a DMV sys.dm_exec_requests para obter informações sobre o progresso atual das operações DBCC_CHECKDB em execução.
```sql
SELECT 
    session_id AS [Session ID], 
    command AS [Command], 
    start_time AS [Start Time], 
    percent_complete AS [Percent Complete]
FROM 
    sys.dm_exec_requests 
WHERE 
    command LIKE 'DBCC%'
```
