# Descrição das Consultas para Monitoramento de Jobs SQL Server

## Descrição da Consulta 1

### Objetivo:
A primeira consulta retorna informações detalhadas sobre os jobs no SQL Server, como o nome do job, o ID do job, a data de execução, o tempo decorrido desde o início da execução e o progresso atual do job (indicando se está executando o passo 1 ou outros passos subsequentes).

### Detalhes:
- **Objetivo:** Monitorar o progresso de execução dos jobs.
- **Parâmetros de Entrada:**
  - **job_name, job_id, originating_server:** Nome e ID do job, além do servidor de origem.
  - **run_requested_date, elapsed_time:** Data e hora de solicitação da execução e o tempo decorrido em segundos.
  - **last_executed_step_id:** Para determinar o passo atual de execução do job.
  
### Resultados Esperados:
- **Job Name:** Nome do job.
- **Job ID:** ID do job.
- **Server:** Servidor de origem.
- **Execution Date:** Data e hora em que o job foi solicitado.
- **Elapsed (sec):** Tempo decorrido em segundos desde a solicitação do job.
- **Progress:** Passo atual de execução, considerando a última etapa executada ou indicando que o passo 1 está em execução.

## Descrição da Consulta 2

### Objetivo:
A segunda consulta fornece detalhes mais avançados sobre a execução de jobs, incluindo o nome do job, a sessão que o executa, o tempo de execução, o passo atual do job e o texto SQL que está sendo executado no momento.

### Detalhes:
- **Objetivo:** Obter uma visão mais detalhada dos jobs em execução, incluindo o tempo de execução e o SQL sendo processado.
- **Parâmetros de Entrada:**
  - **session_id, job_id, job_name:** Identificação da sessão que executa o job e detalhes do job.
  - **login_name, host_name, program_name:** Detalhes do login, host e programa associado à execução do job.
  - **time_elapsed:** Tempo total de execução desde o início do job.
  - **current_executed_step_id:** Passo atual de execução do job.
  - **step_name:** Nome do passo sendo executado.
  - **SQL Text:** O código SQL executado no momento pelo job.
  
### Resultados Esperados:
- **session_id:** ID da sessão que executa o job.
- **job_id e job_name:** Identificação e nome do job.
- **login_name, host_name, program_name:** Detalhes do login e ambiente de execução.
- **start_execution_date:** Data e hora do início da execução do job.
- **time_elapsed:** Tempo decorrido desde o início da execução do job.
- **current_executed_step_id:** Passo atual da execução.
- **step_name:** Nome do passo executado.
- **SQL Text:** Código SQL que está sendo executado.

```SQL
SELECT  j.name AS 'Job Name',
    j.job_id AS 'Job ID',
    j.originating_server AS 'Server',
    a.run_requested_date AS 'Execution Date',
    DATEDIFF(SECOND, a.run_requested_date, GETDATE()) AS 'Elapsed(sec)',
    CASE WHEN a.last_executed_step_id is null
        THEN 'Step 1 executing'
        ELSE 'Step ' + CONVERT(VARCHAR(25), last_executed_step_id + 1)
                  + ' executing'
        END AS 'Progress'
FROM msdb.dbo.sysjobs_view j
    INNER JOIN msdb.dbo.sysjobactivity a ON j.job_id = a.job_id
    INNER JOIN msdb.dbo.syssessions s ON s.session_id = a.session_id
    INNER JOIN (SELECT MAX(agent_start_date) AS max_agent_start_date
          FROM msdb.dbo.syssessions) s2 ON s.agent_start_date = s2.max_agent_start_date
WHERE stop_execution_date IS NULL
AND run_requested_date IS NOT NULL
```

```SQL
--Com a duração
SELECT
    F.session_id,
    A.job_id,
    C.name AS job_name,
    F.login_name,
    F.[host_name],
    F.[program_name],
    A.start_execution_date,
    CONVERT(VARCHAR, CONVERT(VARCHAR, DATEADD(ms, ( DATEDIFF(SECOND, A.start_execution_date, GETDATE()) % 86400 ) * 1000, 0), 114)) AS time_elapsed,
    ISNULL(A.last_executed_step_id, 0) + 1 AS current_executed_step_id,
    D.step_name,
    H.[text]
FROM
    msdb.dbo.sysjobactivity                     A   WITH(NOLOCK)
    LEFT JOIN msdb.dbo.sysjobhistory            B   WITH(NOLOCK)    ON A.job_history_id = B.instance_id
    JOIN msdb.dbo.sysjobs                       C   WITH(NOLOCK)    ON A.job_id = C.job_id
    JOIN msdb.dbo.sysjobsteps                   D   WITH(NOLOCK)    ON A.job_id = D.job_id AND ISNULL(A.last_executed_step_id, 0) + 1 = D.step_id
    JOIN (
        SELECT CAST(CONVERT( BINARY(16), SUBSTRING([program_name], 30, 34), 1) AS UNIQUEIDENTIFIER) AS job_id, MAX(login_time) login_time
        FROM sys.dm_exec_sessions WITH(NOLOCK)
        WHERE [program_name] LIKE 'SQLAgent - TSQL JobStep (Job % : Step %)'
        GROUP BY CAST(CONVERT( BINARY(16), SUBSTRING([program_name], 30, 34), 1) AS UNIQUEIDENTIFIER)
    )                                           E                   ON C.job_id = E.job_id
    LEFT JOIN sys.dm_exec_sessions              F   WITH(NOLOCK)    ON E.job_id = (CASE WHEN BINARY_CHECKSUM(SUBSTRING(F.[program_name], 30, 34)) > 0 THEN CAST(TRY_CONVERT( BINARY(16), SUBSTRING(F.[program_name], 30, 34), 1) AS UNIQUEIDENTIFIER) ELSE NULL END) AND E.login_time = F.login_time
    LEFT JOIN sys.dm_exec_connections           G   WITH(NOLOCK)    ON F.session_id = G.session_id
    OUTER APPLY sys.dm_exec_sql_text(most_recent_sql_handle) H
WHERE
    A.session_id = ( SELECT TOP 1 session_id FROM msdb.dbo.syssessions    WITH(NOLOCK) ORDER BY agent_start_date DESC )
    AND A.start_execution_date IS NOT NULL
    AND A.stop_execution_date IS NULL
```