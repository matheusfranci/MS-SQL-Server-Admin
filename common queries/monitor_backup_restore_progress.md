# Consulta para Monitorar Progresso de BACKUP e RESTORE no SQL Server

## Descrição da Consulta

Esta consulta monitora o progresso de operações de *BACKUP* e *RESTORE* no SQL Server, exibindo informações sobre o status e o tempo estimado de conclusão dessas operações.

### Detalhes:
1. **Fontes de Dados:**
   - `sys.dm_exec_requests`: Fornece informações sobre as solicitações em execução no SQL Server, como o ID da sessão (`session_id`), comando em execução, e o tempo de execução.
   - `sys.dm_exec_sql_text`: Utilizada para obter o texto da consulta SQL em execução associada à solicitação.

2. **Filtros:**
   - A consulta filtra as solicitações para incluir apenas aquelas associadas aos comandos `BACKUP DATABASE` e `RESTORE DATABASE`.

3. **Campos Retornados:**
   - **SPID**: ID da sessão do processo.
   - **Command**: O comando em execução (neste caso, `BACKUP DATABASE` ou `RESTORE DATABASE`).
   - **Query**: O texto SQL da consulta.
   - **Start Time**: O momento em que a operação foi iniciada.
   - **Percent Complete**: O progresso da operação em percentual.
   - **Estimated Completion Time**: O tempo estimado para a conclusão da operação, calculado com base no tempo estimado restante.

### Finalidade:
Esta consulta é útil para monitorar a execução de operações críticas como backup e restauração de banco de dados, permitindo que os administradores de banco de dados acompanhem o progresso dessas operações e estimem o tempo restante para a conclusão.

```SQL
SELECT session_id as SPID, command, a.text AS Query, start_time, percent_complete, dateadd(second,estimated_completion_time/1000, getdate()) as estimated_completion_time
FROM sys.dm_exec_requests r CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) a
WHERE r.command in ('BACKUP DATABASE','RESTORE DATABASE')
```