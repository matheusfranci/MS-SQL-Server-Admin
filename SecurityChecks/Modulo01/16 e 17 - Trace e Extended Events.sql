


-- Trace habilitado
SELECT 
    id,
    [status],
    [path],
    is_default,
    start_time,
    last_event_time,
    event_count
FROM
    sys.traces
WHERE
    is_default = 0
    AND [status] = 1
    AND [path] NOT LIKE '%Traces\Duracao.trc'










	
	
--------------------------------------------------------
-- Armazena os resultados do Trace na tabela
--------------------------------------------------------

DECLARE @Trace_Id INT, @Path VARCHAR(MAX)

SELECT 
    @Trace_Id = id,
    @Path = [path]
FROM 
    sys.traces
WHERE 
    [path] LIKE '%Query_Demorada.trc'


IF (@Trace_Id IS NOT NULL)
BEGIN


    -- Interrompe o rastreamento especificado.
    EXEC sys.sp_trace_setstatus
        @Trace_Id = @Trace_Id, 
        @status = 0


    -- Fecha o rastreamento especificado e exclui sua definição do servidor.
    EXEC sys.sp_trace_setstatus 
        @Trace_Id = @Trace_Id,
        @status = 2

    
    SELECT
        TextData,
        NTUserName,
        HostName,
        ApplicationName,
        LoginName,
        SPID,
        CAST(Duration / 1000 / 1000.00 AS NUMERIC(15, 2)) Duration,
        StartTime,
        EndTime,
        Reads,
        Writes,
        CPU,
        ServerName,
        DatabaseName,
        RowCounts,
        SessionLoginName
    FROM
        ::fn_trace_gettable(@Path, DEFAULT)
    WHERE
        Duration IS NOT NULL
        AND Reads < 100000000
    ORDER BY
        StartTime;


    --------------------------------------------------------
    -- Apaga o arquivo de trace
    --------------------------------------------------------
    
    DECLARE @Fl_Xp_CmdShell_Ativado BIT = (SELECT (CASE WHEN CAST([value] AS VARCHAR(MAX)) = '1' THEN 1 ELSE 0 END) FROM sys.configurations WHERE [name] = 'xp_cmdshell')
 
    IF (@Fl_Xp_CmdShell_Ativado = 0)
    BEGIN
 
        EXECUTE sp_configure 'show advanced options', 1;
        RECONFIGURE WITH OVERRIDE;
    
        EXEC sp_configure 'xp_cmdshell', 1;
        RECONFIGURE WITH OVERRIDE;
    
    END


    DECLARE @Cmd VARCHAR(4000) = 'del ' + @Path + ' /Q'
    EXEC sys.xp_cmdshell @Cmd


    IF (@Fl_Xp_CmdShell_Ativado = 0)
    BEGIN
 
        EXEC sp_configure 'xp_cmdshell', 0;
        RECONFIGURE WITH OVERRIDE;
 
        EXECUTE sp_configure 'show advanced options', 0;
        RECONFIGURE WITH OVERRIDE;
 
    END


END



--------------------------------------------------------
-- Ativa o trace novamenmte
--------------------------------------------------------

DECLARE
    @resource INT,
    @maxfilesize BIGINT = 50,
    @on BIT = 1, -- Habilitado
    @bigintfilter BIGINT = (1000000 * 1) -- 1 segundos


-- Criação do trace
SET @Trace_Id = NULL

EXEC @resource = sys.sp_trace_create @Trace_Id OUTPUT, 0, N'C:\Traces\Query_Demorada', @maxfilesize, NULL 

IF (@resource = 0)
BEGIN

    EXEC sys.sp_trace_setevent @Trace_Id, 10, 1, @on  
    EXEC sys.sp_trace_setevent @Trace_Id, 10, 6, @on  
    EXEC sys.sp_trace_setevent @Trace_Id, 10, 8, @on  
    EXEC sys.sp_trace_setevent @Trace_Id, 10, 10, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 10, 11, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 10, 12, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 10, 13, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 10, 14, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 10, 15, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 10, 16, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 10, 17, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 10, 18, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 10, 26, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 10, 35, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 10, 40, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 10, 48, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 10, 64, @on 

    EXEC sys.sp_trace_setevent @Trace_Id, 12, 1,  @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 12, 6,  @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 12, 8,  @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 12, 10, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 12, 11, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 12, 12, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 12, 13, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 12, 14, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 12, 15, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 12, 16, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 12, 17, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 12, 18, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 12, 26, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 12, 35, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 12, 40, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 12, 48, @on 
    EXEC sys.sp_trace_setevent @Trace_Id, 12, 64, @on 


    -- Aqui é onde filtramos o tempo da query que irá cair no trace
    EXEC sys.sp_trace_setfilter @Trace_Id, 13, 0, 4, @bigintfilter -- O 4 significa >= @bigintfilter 


    -- Ativa o trace
    EXEC sys.sp_trace_setstatus @Trace_Id, 1


END


WAITFOR DELAY '00:00:08'


SELECT * FROM dbo.Historico_Query_Demorada














-- XE habilitado
SELECT
    A.event_session_id,
    A.[name],
    B.create_time,
    C.target_name,
    C.execution_count,
    C.execution_duration_ms,
    A.event_retention_mode_desc,
    CAST(C.target_data AS VARCHAR(MAX)) AS target_data
FROM
    sys.server_event_sessions AS A WITH(NOLOCK) 
    LEFT JOIN sys.dm_xe_sessions AS B WITH(NOLOCK) ON A.[name] = B.[name]
    LEFT JOIN sys.dm_xe_session_targets AS C WITH(NOLOCK) ON C.event_session_address = B.[address]
WHERE
    A.[name] NOT IN ( 'system_health', 'StretchDatabase_Health', 'telemetry_xevents', 'hkenginexesession', 'sp_server_diagnostics session', 'AlwaysOn_health', 'QuickSessionStandard', 'QuickSessionTSQL' )
ORDER BY
    2


























-- Query Lenta XE
-- Apaga a sessão, caso ela já exista
IF ((SELECT COUNT(*) FROM sys.dm_xe_sessions WHERE [name] = 'Query Lenta') > 0) DROP EVENT SESSION [Query Lenta] ON SERVER 
GO

-- Cria o Extended Event no servidor, configurado para iniciar automaticamente quando o serviço do SQL é iniciado
CREATE EVENT SESSION [Query Lenta] ON SERVER 
ADD EVENT sqlserver.sql_batch_completed (
    ACTION (
        sqlserver.session_id,
        sqlserver.client_app_name,
        sqlserver.client_hostname,
        sqlserver.database_name,
        sqlserver.username,
        sqlserver.session_nt_username,
        sqlserver.session_server_principal_name,
        sqlserver.sql_text
    )
    WHERE
        duration > (3000000) -- 3 segundos
)
ADD TARGET package0.event_file (
    SET filename=N'C:\Traces\Query_Lenta_XE',
    max_file_size=(10),
    max_rollover_files=(10)
)
WITH (STARTUP_STATE=ON)
GO

-- Ativa o Extended Event
ALTER EVENT SESSION [Query Lenta] ON SERVER STATE = START
GO


WAITFOR DELAY '00:00:04'


DECLARE 
    @TimeZone INT = DATEDIFF(HOUR, GETUTCDATE(), GETDATE())
    
 
IF (OBJECT_ID('tempdb..#Eventos') IS NOT NULL) DROP TABLE #Eventos
;WITH CTE AS (
    SELECT CONVERT(XML, event_data) AS event_data
    FROM sys.fn_xe_file_target_read_file(N'C:\Traces\Query_Lenta_XE*.xel', NULL, NULL, NULL)
)
SELECT
    DATEADD(HOUR, @TimeZone, CTE.event_data.value('(//event/@timestamp)[1]', 'datetime')) AS Dt_Evento,
    CTE.event_data
INTO
    #Eventos
FROM
    CTE
    
 
SELECT
    A.Dt_Evento,
    xed.event_data.value('(action[@name="session_id"]/value)[1]', 'int') AS session_id,
    xed.event_data.value('(action[@name="database_name"]/value)[1]', 'varchar(128)') AS [database_name],
    xed.event_data.value('(action[@name="username"]/value)[1]', 'varchar(128)') AS username,
    xed.event_data.value('(action[@name="session_server_principal_name"]/value)[1]', 'varchar(128)') AS session_server_principal_name,
    xed.event_data.value('(action[@name="session_nt_username"]/value)[1]', 'varchar(128)') AS [session_nt_username],
    xed.event_data.value('(action[@name="client_hostname"]/value)[1]', 'varchar(128)') AS [client_hostname],
    xed.event_data.value('(action[@name="client_app_name"]/value)[1]', 'varchar(128)') AS [client_app_name],
    CAST(xed.event_data.value('(//data[@name="duration"]/value)[1]', 'bigint') / 1000000.0 AS NUMERIC(18, 2)) AS duration,
    CAST(xed.event_data.value('(//data[@name="cpu_time"]/value)[1]', 'bigint') / 1000000.0 AS NUMERIC(18, 2)) AS cpu_time,
    xed.event_data.value('(//data[@name="logical_reads"]/value)[1]', 'bigint') AS logical_reads,
    xed.event_data.value('(//data[@name="physical_reads"]/value)[1]', 'bigint') AS physical_reads,
    xed.event_data.value('(//data[@name="writes"]/value)[1]', 'bigint') AS writes,
    xed.event_data.value('(//data[@name="row_count"]/value)[1]', 'bigint') AS row_count,
    TRY_CAST(xed.event_data.value('(//action[@name="sql_text"]/value)[1]', 'varchar(max)') AS XML) AS sql_text,
    TRY_CAST(xed.event_data.value('(//data[@name="batch_text"]/value)[1]', 'varchar(max)') AS XML) AS batch_text,
    xed.event_data.value('(//data[@name="result"]/text)[1]', 'varchar(100)') AS result
FROM
    #Eventos A
    CROSS APPLY A.event_data.nodes('//event') AS xed (event_data)


