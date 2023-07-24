/*Se você fizer uma consulta na DMV sys.dm_os_waiting_tasks, você vai perceber que existem sempre uma tarefa de sistema com o evento REQUEST_FOR_DEADLOCK_SEARCH.*/
SELECT * FROM sys.dm_os_waiting_tasks WHERE wait_type ='REQUEST_FOR_DEADLOCK_SEARCH';
/*Essa thread é acionada a cada 5 segundos para verificar se existem deadlocks na instância. Se ela encontrar algum deadlock, ela vai matar uma das sessões
em deadlock para liberar os recursos travados para a outra sessão que está aguardando.*/


/*Como identificar os deadlocks que ocorreram na instância
Existem várias métodos que podem ser utilizados para identificar os locks que ocorreram na instância, de modo que você consiga identificar e avaliar os locks depois que eles ocorreram,
uma vez que o DBA não vai ficar monitorando manualmente todos os deadlocks, em todas as instâncias do ambiente, o tempo todo.

Como identificar os deadlocks utilizando Trace
Uma maneira fácil e prática de se identificar os locks da instância, é ativar um trace utilizando a trace flag 1222, conforme demonstro abaixo:*/

DBCC TRACEON (1222,-1);

-- Uma vez que esse trace está ativo, sempre que ocorrer um deadlock na instância, esse evento ficará gravado no log do SQL Server, no qual você pode consultar utilizando a sp_readerrorlog:
sp_readerrorlog

/*Para criar um histórico de deadlocks manualmente, basta criar um Job que execute esse comando:*/
USE [dirceuresende]
GO
 
IF (OBJECT_ID('dbo.Historico_Deadlocks_Resumido') IS NULL)
BEGIN
 
    CREATE TABLE dbo.Historico_Deadlocks_Resumido (
        Dt_Log DATETIME,
        Ds_Log XML
    )
 
END
 
 
DECLARE @Ultimo_Log DATETIME = ISNULL((SELECT MAX(Dt_Log) FROM dbo.Historico_Deadlocks_Resumido WITH(NOLOCK)), '1900-01-01')
 
INSERT INTO dbo.Historico_Deadlocks_Resumido
SELECT
    xed.value('@timestamp', 'datetime2(3)') as CreationDate,
    xed.query('.') AS XEvent
FROM
(
    SELECT 
        CAST([target_data] AS XML) AS TargetData
    FROM 
        sys.dm_xe_session_targets AS st
        INNER JOIN sys.dm_xe_sessions AS s ON s.[address] = st.event_session_address
    WHERE 
        s.[name] = N'system_health'
        AND st.target_name = N'ring_buffer'
) AS [Data]
CROSS APPLY TargetData.nodes('RingBufferTarget/event[@name="xml_deadlock_report"]') AS XEventData (xed)
WHERE
    xed.value('@timestamp', 'datetime2(3)') > @Ultimo_Log
ORDER BY 
    CreationDate DESC
