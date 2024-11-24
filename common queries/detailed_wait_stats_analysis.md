### Descrição da Query

Esta query fornece uma análise detalhada das estatísticas de espera no SQL Server, com um foco na distribuição do tempo de espera, tempo de espera de recursos, e tempo de espera de sinalização. Ela utiliza a view `sys.dm_os_wait_stats` e cria uma CTE chamada `Waits` para filtrar e calcular as estatísticas de espera, excluindo os tipos de espera de baixo impacto.

A query retorna as seguintes colunas:
- **`WaitType`**: O tipo de espera.
- **`Wait_S`**: O tempo total de espera (em segundos).
- **`Resource_S`**: O tempo de espera para recursos (em segundos).
- **`Signal_S`**: O tempo de espera de sinalização (em segundos).
- **`WaitCount`**: O número de tarefas em espera.
- **`Percentage`**: A porcentagem de tempo de espera em relação ao total.
- **`AvgWait_S`**: A média de tempo de espera por tarefa.
- **`AvgRes_S`**: A média de tempo de espera de recursos por tarefa.
- **`AvgSig_S`**: A média de tempo de espera de sinalização por tarefa.

A query também limita os resultados, retornando apenas os tipos de espera que, juntos, representam menos de 95% do total de tempo de espera, fornecendo uma visão mais concentrada nas esperas mais impactantes.### Descrição da Query

Esta query fornece uma análise detalhada das estatísticas de espera no SQL Server, com um foco na distribuição do tempo de espera, tempo de espera de recursos, e tempo de espera de sinalização. Ela utiliza a view `sys.dm_os_wait_stats` e cria uma CTE chamada `Waits` para filtrar e calcular as estatísticas de espera, excluindo os tipos de espera de baixo impacto.

A query retorna as seguintes colunas:
- **`WaitType`**: O tipo de espera.
- **`Wait_S`**: O tempo total de espera (em segundos).
- **`Resource_S`**: O tempo de espera para recursos (em segundos).
- **`Signal_S`**: O tempo de espera de sinalização (em segundos).
- **`WaitCount`**: O número de tarefas em espera.
- **`Percentage`**: A porcentagem de tempo de espera em relação ao total.
- **`AvgWait_S`**: A média de tempo de espera por tarefa.
- **`AvgRes_S`**: A média de tempo de espera de recursos por tarefa.
- **`AvgSig_S`**: A média de tempo de espera de sinalização por tarefa.

A query também limita os resultados, retornando apenas os tipos de espera que, juntos, representam menos de 95% do total de tempo de espera, fornecendo uma visão mais concentrada nas esperas mais impactantes.

```SQL
WITH [Waits] AS
    (SELECT
        [wait_type],
        [wait_time_ms] / 1000.0 AS [WaitS],
        ([wait_time_ms] - [signal_wait_time_ms]) / 1000.0 AS [ResourceS],
        [signal_wait_time_ms] / 1000.0 AS [SignalS],
        [waiting_tasks_count] AS [WaitCount],
        100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
        ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]
    FROM sys.dm_os_wait_stats
    WHERE [wait_type] NOT IN (
        N'BROKER_EVENTHANDLER',             N'BROKER_RECEIVE_WAITFOR',
        N'BROKER_TASK_STOP',                N'BROKER_TO_FLUSH',
        N'BROKER_TRANSMITTER',              N'CHECKPOINT_QUEUE',
        N'CHKPT',                           N'CLR_AUTO_EVENT',
        N'CLR_MANUAL_EVENT',                N'CLR_SEMAPHORE',
        N'DBMIRROR_DBM_EVENT',              N'DBMIRROR_EVENTS_QUEUE',
        N'DBMIRROR_WORKER_QUEUE',           N'DBMIRRORING_CMD',
        N'DIRTY_PAGE_POLL',                 N'DISPATCHER_QUEUE_SEMAPHORE',
        N'EXECSYNC',                        N'FSAGENT',
        N'FT_IFTS_SCHEDULER_IDLE_WAIT',     N'FT_IFTSHC_MUTEX',
        N'HADR_CLUSAPI_CALL',               N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
        N'HADR_LOGCAPTURE_WAIT',            N'HADR_NOTIFICATION_DEQUEUE',
        N'HADR_TIMER_TASK',                 N'HADR_WORK_QUEUE',
        N'KSOURCE_WAKEUP',                  N'LAZYWRITER_SLEEP',
        N'LOGMGR_QUEUE',                    N'ONDEMAND_TASK_QUEUE',
        N'PWAIT_ALL_COMPONENTS_INITIALIZED',
        N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
        N'QDS_SHUTDOWN_QUEUE',
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
        N'REQUEST_FOR_DEADLOCK_SEARCH',     N'RESOURCE_QUEUE',
        N'SERVER_IDLE_CHECK',               N'SLEEP_BPOOL_FLUSH',
        N'SLEEP_DBSTARTUP',                 N'SLEEP_DCOMSTARTUP',
        N'SLEEP_MASTERDBREADY',             N'SLEEP_MASTERMDREADY',
        N'SLEEP_MASTERUPGRADED',            N'SLEEP_MSDBSTARTUP',
        N'SLEEP_SYSTEMTASK',                N'SLEEP_TASK',
        N'SLEEP_TEMPDBSTARTUP',             N'SNI_HTTP_ACCEPT',
        N'SP_SERVER_DIAGNOSTICS_SLEEP',     N'SQLTRACE_BUFFER_FLUSH',
        N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
        N'SQLTRACE_WAIT_ENTRIES',           N'WAIT_FOR_RESULTS',
        N'WAITFOR',                         N'WAITFOR_TASKSHUTDOWN',
        N'WAIT_XTP_HOST_WAIT',              N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
        N'WAIT_XTP_CKPT_CLOSE',             N'XE_DISPATCHER_JOIN',
        N'XE_DISPATCHER_WAIT',              N'XE_TIMER_EVENT')
    AND [waiting_tasks_count] > 0
 )
SELECT
    MAX ([W1].[wait_type]) AS [WaitType],
    CAST (MAX ([W1].[WaitS]) AS DECIMAL (16,2)) AS [Wait_S],
    CAST (MAX ([W1].[ResourceS]) AS DECIMAL (16,2)) AS [Resource_S],
    CAST (MAX ([W1].[SignalS]) AS DECIMAL (16,2)) AS [Signal_S],
    MAX ([W1].[WaitCount]) AS [WaitCount],
    CAST (MAX ([W1].[Percentage]) AS DECIMAL (5,2)) AS [Percentage],
    CAST ((MAX ([W1].[WaitS]) / MAX ([W1].[WaitCount])) AS DECIMAL (16,4)) AS [AvgWait_S],
    CAST ((MAX ([W1].[ResourceS]) / MAX ([W1].[WaitCount])) AS DECIMAL (16,4)) AS [AvgRes_S],
    CAST ((MAX ([W1].[SignalS]) / MAX ([W1].[WaitCount])) AS DECIMAL (16,4)) AS [AvgSig_S]
FROM [Waits] AS [W1]
INNER JOIN [Waits] AS [W2]
    ON [W2].[RowNum] <= [W1].[RowNum]
GROUP BY [W1].[RowNum]
HAVING SUM ([W2].[Percentage]) - MAX ([W1].[Percentage]) < 95; -- percentage threshold
GO
```