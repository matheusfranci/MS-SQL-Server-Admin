## Objetivo
Este script cria sessões de eventos no SQL Server para monitorar e capturar informações detalhadas sobre:
1. **Deadlocks**: Conflitos de bloqueio entre processos que resultam em impasses.
2. **Blocked Processes**: Processos que ficam bloqueados por mais de 5 segundos (configurável).

## Entrada esperada
- O script cria duas sessões de eventos:
  - **Deadlocks**: Captura relatórios de deadlock com detalhes, incluindo o nome do banco de dados, SQL executado, e o usuário.
  - **Blocked Process**: Relatórios sobre processos bloqueados com informações do host, banco de dados, e query em execução.

## Saída esperada
- **Arquivos de evento**:
  - Deadlocks: `C:\Process\sia\scripts\Deadlocks.xel`
  - Blocked Processes: `C:\Process\sia\scripts\Blocked Process.xel`
- Informações detalhadas sobre os eventos capturados, incluindo sessões envolvidas, planos de execução, e texto SQL.

## Observações adicionais
- O **limite de bloqueio** (`blocked process threshold`) está configurado para 5 segundos. Você pode ajustar conforme a necessidade no comando:
  ```sql
  sp_configure 'blocked process threshold', <tempo_em_segundos>;
  RECONFIGURE WITH OVERRIDE;
  ```

```sql
-- DeadLock
CREATE EVENT SESSION [Deadlocks] ON SERVER 
ADD EVENT sqlserver.xml_deadlock_report(
    ACTION(sqlos.worker_address,sqlserver.database_name,sqlserver.plan_handle,sqlserver.session_id,sqlserver.session_server_principal_name,sqlserver.sql_text,sqlserver.username))
ADD TARGET package0.event_file(SET filename=N'C:\Process\sia\scripts\Deadlocks.xel')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO
```

```sql
-- Blocked Process
CREATE EVENT SESSION [Blocked Process] ON SERVER 
ADD EVENT sqlserver.blocked_process_report(
    ACTION(package0.process_id,sqlos.task_time,sqlos.worker_address,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.server_instance_name,sqlserver.server_principal_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username))
ADD TARGET package0.event_file(SET filename=N'C:\Process\sia\scripts\Blocked Process')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO
```

```sql
-- Configura a sensibilidade do blocked process em segundos
sp_configure'blocked process threshold',5;
RECONFIGURE WITH OVERRIDE;  
```