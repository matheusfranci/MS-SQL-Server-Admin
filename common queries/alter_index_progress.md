### Descrição
Essa query retorna informações sobre o progresso de uma operação de alteração de índice (`ALTER INDEX`) no SQL Server. Ela fornece detalhes sobre a sessão de execução, comando, percentual de conclusão, tempo estimado de conclusão, tempo de execução total e a consulta SQL sendo executada.

### Detalhes
1. **`sys.dm_exec_requests`:** Exibe informações sobre as solicitações em execução no SQL Server.
2. **`sys.dm_exec_sql_text`:** Retorna o texto SQL associado à execução de uma solicitação.
3. **Conversões de tempo:**
   - **`Percent Complete`:** Percentual de conclusão da operação.
   - **`ETA Completion Time`:** Tempo estimado para conclusão da operação, baseado no tempo restante.
   - **`Elapsed Min`, `ETA Min`, `ETA Hours`:** Conversões para exibir o tempo decorrido e o tempo estimado de conclusão em minutos e horas.
4. **Filtragem por comando `ALTER INDEX`:** A consulta retorna apenas as operações que estão executando o comando `ALTER INDEX`.

### Exemplo de Uso
```sql
SELECT r.session_id,
       r.command,
       CONVERT(NUMERIC(6,2),r.percent_complete) AS [Percent Complete],
       CONVERT(VARCHAR(20),DATEADD(ms,r.estimated_completion_time,GetDate()),20) AS [ETA Completion Time],
       CONVERT(NUMERIC(10,2),r.total_elapsed_time/1000.0/60.0) AS [Elapsed Min],
       CONVERT(NUMERIC(10,2),r.estimated_completion_time/1000.0/60.0) AS [ETA Min],
       CONVERT(NUMERIC(10,2),r.estimated_completion_time/1000.0/60.0/60.0) AS [ETA Hours],
       CONVERT(VARCHAR(1000),(
           SELECT SUBSTRING(text,r.statement_start_offset/2,
               CASE WHEN r.statement_end_offset = -1 THEN 1000 
                    ELSE (r.statement_end_offset-r.statement_start_offset)/2 END)
           FROM sys.dm_exec_sql_text(sql_handle)))
FROM sys.dm_exec_requests r 
WHERE command IN ('ALTER INDEX');
