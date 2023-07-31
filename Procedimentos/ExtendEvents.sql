-- DeadLock
CREATE EVENT SESSION [Deadlocks] ON SERVER 
ADD EVENT sqlserver.xml_deadlock_report(
    ACTION(sqlos.worker_address,sqlserver.database_name,sqlserver.plan_handle,sqlserver.session_id,sqlserver.session_server_principal_name,sqlserver.sql_text,sqlserver.username))
ADD TARGET package0.event_file(SET filename=N'C:\ORION\sia\scripts\Deadlocks.xel')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO

-- Blocked Process
CREATE EVENT SESSION [Blocked Process] ON SERVER 
ADD EVENT sqlserver.blocked_process_report(
    ACTION(package0.process_id,sqlos.task_time,sqlos.worker_address,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.server_instance_name,sqlserver.server_principal_name,sqlserver.session_id,sqlserver.sql_text,sqlserver.username))
ADD TARGET package0.event_file(SET filename=N'C:\ORION\sia\scripts\Blocked Process')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO

-- Configura a sensibilidade do blocked process em segundos
sp_configure'blocked process threshold',5;
RECONFIGURE WITH OVERRIDE;  
