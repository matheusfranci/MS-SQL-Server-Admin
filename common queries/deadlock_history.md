### Descrição da Query

A consulta executa duas tarefas principais:

1. **Criação da Tabela Temporária `dbo.Historico_Deadlocks`**:
   - Caso a tabela `dbo.Historico_Deadlocks` não exista, ela é criada para armazenar informações sobre deadlocks no banco de dados.
   - A tabela possui diversas colunas para armazenar informações sobre o evento de deadlock, como `Dt_Log`, `processId`, `processSqlCommand`, `resourceDBName`, entre outras.

2. **Processamento de Arquivo de Deadlocks**:
   - A consulta lê um arquivo de logs de deadlock (no formato `.xel`) usando a função `sys.fn_xe_file_target_read_file`.
   - O arquivo contém dados sobre deadlocks no banco de dados. A consulta filtra esses dados para obter os eventos de deadlock mais recentes com base na data do último evento registrado na tabela `dbo.Historico_Deadlocks`.

3. **Inserção de Dados na Tabela `dbo.Historico_Deadlocks`**:
   - Os dados extraídos do arquivo `.xel` são inseridos na tabela `dbo.Historico_Deadlocks`.
   - A consulta inclui várias informações sobre o deadlock, como a identificação do processo envolvido, o comando SQL executado, o banco de dados afetado, o tipo de bloqueio, a transação, entre outros.

### Passos:
1. **Criação da Tabela Temporária `#Status`**: A tabela `dbo.Historico_Deadlocks` é criada apenas se não existir, para evitar erros de duplicação.
2. **Leitura e Processamento do Arquivo de Deadlock**: Lê-se o arquivo de deadlock gerado pelo SQL Server (`Deadlocks.xel`), processa-se os dados XML e filtra-se os eventos que ocorreram após o último registro na tabela `dbo.Historico_Deadlocks`.
3. **Inserção dos Dados**: As informações de deadlock são extraídas e inseridas na tabela de histórico.

```SQL
IF (OBJECT_ID('dbo.Historico_Deadlocks') IS NULL)
BEGIN
 
    -- DROP TABLE dbo.Historico_Deadlocks
    CREATE TABLE dbo.Historico_Deadlocks
    (
        [Dt_Log] DATETIME2,
        [isVictim] INT,
        [processId] VARCHAR(100),
        [processSqlCommand] XML,
        [resourceDBId] INT,
        [resourceDBName] NVARCHAR(128),
        [resourceObjectName] VARCHAR(128),
        [processWaitResource] VARCHAR(100),
        [processWaitTime] INT,
        [processTransactionName] VARCHAR(60),
        [processStatus] VARCHAR(60),
        [processSPID] INT,
        [processClientApp] VARCHAR(256),
        [processHostname] VARCHAR(256),
        [processLoginName] VARCHAR(256),
        [processIsolationLevel] VARCHAR(256),
        [processCurrentDb] VARCHAR(256),
        [processCurrentDbName] NVARCHAR(128),
        [processTranCount] INT,
        [processLockMode] VARCHAR(10),
        [resourceFileId] INT,
        [resourcePageId] INT,
        [resourceLockMode] VARCHAR(2),
        [resourceProcessOwner] VARCHAR(128),
        [resourceProcessOwnerMode] VARCHAR(2)
    )
 
END
 
    
DECLARE 
    @Ultimo_Log DATETIME2 = ISNULL((SELECT MAX(Dt_Log) FROM dbo.Historico_Deadlocks WITH(NOLOCK)), '1900-01-01'),
    @TimeZone INT = DATEDIFF(HOUR, GETUTCDATE(), GETDATE())
 
IF (OBJECT_ID('tempdb..#xml_deadlock') IS NOT NULL) DROP TABLE #xml_deadlock
SELECT
    *
INTO
    #xml_deadlock
FROM
(
    SELECT
        module_guid,
        package_guid,
        [object_name],
        [file_name],
        [file_offset],
        DATEADD(HOUR, @TimeZone, CAST(CURRENT_TIMESTAMP AS DATETIME2)) AS Dt_Evento,
        CAST(event_data AS XML) AS TargetData
    FROM 
        sys.fn_xe_file_target_read_file(N'C:\ORION\sia\scripts\Deadlocks.xel', NULL, NULL, NULL)
) AS [dados]
WHERE
    Dt_Evento > @Ultimo_Log
ORDER BY 
    Dt_Evento DESC
 
    
INSERT INTO dbo.Historico_Deadlocks
SELECT
    DATEADD(HOUR, @TimeZone, dados.event_data.value('@timestamp', 'datetime2')) AS [timestamp],
    (CASE WHEN vitima.dados.value('@id', 'varchar(100)') = processo.dados.value('@id', 'varchar(100)') THEN 1 ELSE 0 END) AS isVictim,
    processo.dados.value('@id', 'varchar(100)') AS [processId],
    processo.dados.query('(inputbuf/text())') AS [processSqlCommand],
    recurso.resourceDBId,
    DB_NAME(recurso.resourceDBId) AS resourceDBName,
    recurso.resourceObjectName,
    processo.dados.value('@waitresource', 'varchar(100)') AS [processWaitResource],
    processo.dados.value('@waittime', 'int') AS [processWaitTime],
    processo.dados.value('@transactionname', 'varchar(60)') AS [processTransactionName],
    processo.dados.value('@status', 'varchar(60)') AS [processStatus],
    processo.dados.value('@spid', 'int') AS [processSPID],
    processo.dados.value('@clientapp', 'varchar(256)') AS [processClientApp],
    processo.dados.value('@hostname', 'varchar(256)') AS [processHostname],
    processo.dados.value('@loginname', 'varchar(256)') AS [processLoginName],
    processo.dados.value('@isolationlevel', 'varchar(256)') AS [processIsolationLevel],
    processo.dados.value('@currentdb', 'varchar(256)') AS [processCurrentDb],
    DB_NAME(processo.dados.value('@currentdb', 'varchar(256)')) AS [processCurrentDbName],
    processo.dados.value('@trancount', 'int') AS [processTranCount],
    processo.dados.value('@lockMode', 'varchar(10)') AS [processLockMode],
    recurso.resourceFileId,
    recurso.resourcePageId,
    recurso.resourceLockMode,
    recurso.resourceProcessOwner,
    recurso.resourceProcessOwnerMode
FROM
    #xml_deadlock A
    CROSS APPLY A.TargetData.nodes('//event') AS dados(event_data)
    CROSS APPLY dados.event_data.nodes('data/value/deadlock/victim-list/victimProcess') AS vitima(dados)
    OUTER APPLY dados.event_data.nodes('data/value/deadlock/process-list/process') AS processo(dados)
    LEFT JOIN (
        SELECT
            A.Dt_Evento,
            recurso.dados.value('@fileid', 'int') AS [resourceFileId],
            recurso.dados.value('@pageid', 'int') AS [resourcePageId],
            recurso.dados.value('@dbid', 'int') AS [resourceDBId],
            recurso.dados.value('@objectname', 'varchar(128)') AS [resourceObjectName],
            recurso.dados.value('@mode', 'varchar(2)') AS [resourceLockMode],
            [owner].dados.value('@id', 'varchar(128)') AS [resourceProcessOwner],
            [owner].dados.value('@mode', 'varchar(2)') AS [resourceProcessOwnerMode]
        FROM 
            #xml_deadlock A
            CROSS APPLY A.TargetData.nodes('//ridlock') AS recurso(dados)
            OUTER APPLY recurso.dados.nodes('owner-list/owner') AS owner(dados)
    ) AS recurso ON recurso.resourceProcessOwner = processo.dados.value('@id', 'varchar(100)') AND recurso.Dt_Evento = A.Dt_Evento
```