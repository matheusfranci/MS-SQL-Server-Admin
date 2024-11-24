### Descrição
Essa query retorna informações sobre os trabalhos (`Jobs`) agendados no SQL Server, incluindo o ID do trabalho, nome, data e hora da última execução, status da última execução, duração da última execução, mensagem associada e a data/hora da próxima execução. Ela também filtra os trabalhos habilitados que tiveram execução bem-sucedida na última execução.

### Detalhes
1. **`msdb.dbo.sysjobs`:** Contém informações sobre os trabalhos no SQL Server.
2. **`msdb.dbo.sysjobschedules`:** Contém detalhes sobre os agendamentos de cada trabalho, incluindo a próxima execução.
3. **`msdb.dbo.sysjobhistory`:** Contém o histórico de execuções dos trabalhos, com status e mensagens de cada execução.
4. **Conversões de tempo:**
   - **Última execução (`LastRunDateTime`):** Exibe a data e hora da última execução do trabalho.
   - **Status da última execução (`LastRunStatus`):** Exibe o status da última execução, como 'Falhou', 'Sucesso', etc.
   - **Duração da última execução (`LastRunDuration`):** Exibe a duração da última execução no formato HH:MM:SS.
   - **Próxima execução (`NextRunDateTime`):** Exibe a data e hora da próxima execução do trabalho.

### Exemplo de Uso
```sql
SELECT 
    [sJOB].[job_id] AS [JobID]
    , [sJOB].[name] AS [JobName]
    , CASE 
        WHEN [sJOBH].[run_date] IS NULL OR [sJOBH].[run_time] IS NULL THEN NULL
        ELSE CAST(
                CAST([sJOBH].[run_date] AS CHAR(8))
                + ' ' 
                + STUFF(
                    STUFF(RIGHT('000000' + CAST([sJOBH].[run_time] AS VARCHAR(6)),  6)
                        , 3, 0, ':')
                    , 6, 0, ':')
                AS DATETIME)
      END AS [LastRunDateTime]
    , CASE [sJOBH].[run_status]
        WHEN 0 THEN 'Failed'
        WHEN 1 THEN 'Succeeded'
        WHEN 2 THEN 'Retry'
        WHEN 3 THEN 'Canceled'
        WHEN 4 THEN 'Running'
      END AS [LastRunStatus]
    , STUFF(
            STUFF(RIGHT('000000' + CAST([sJOBH].[run_duration] AS VARCHAR(6)),  6)
                , 3, 0, ':')
            , 6, 0, ':') 
        AS [LastRunDuration (HH:MM:SS)]
    , [sJOBH].[message] AS [LastRunStatusMessage]
    , CASE [sJOBSCH].[NextRunDate]
        WHEN 0 THEN NULL
        ELSE CAST(
                CAST([sJOBSCH].[NextRunDate] AS CHAR(8))
                + ' ' 
                + STUFF(
                    STUFF(RIGHT('000000' + CAST([sJOBSCH].[NextRunTime] AS VARCHAR(6)),  6)
                        , 3, 0, ':')
                    , 6, 0, ':')
                AS DATETIME)
      END AS [NextRunDateTime]
FROM 
    [msdb].[dbo].[sysjobs] AS [sJOB]
    LEFT JOIN (
                SELECT
                    [job_id]
                    , MIN([next_run_date]) AS [NextRunDate]
                    , MIN([next_run_time]) AS [NextRunTime]
                FROM [msdb].[dbo].[sysjobschedules]
                GROUP BY [job_id]
            ) AS [sJOBSCH]
        ON [sJOB].[job_id] = [sJOBSCH].[job_id]
    LEFT JOIN (
                SELECT 
                    [job_id]
                    , [run_date]
                    , [run_time]
                    , [run_status]
                    , [run_duration]
                    , [message]
                    , ROW_NUMBER() OVER (
                                            PARTITION BY [job_id] 
                                            ORDER BY [run_date] DESC, [run_time] DESC
                      ) AS RowNumber
                FROM [msdb].[dbo].[sysjobhistory]
                WHERE [step_id] = 0
            ) AS [sJOBH]
        ON [sJOB].[job_id] = [sJOBH].[job_id]
        AND [sJOBH].[RowNumber] = 1
        AND [sJOB].[enabled] = 1
        AND [sJOBH].[run_status] = 1
ORDER BY [JobName];