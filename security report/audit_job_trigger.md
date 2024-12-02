# Auditoria de Jobs no SQL Server

## Descrição
Este script implementa uma auditoria completa para monitorar alterações em jobs e seus agendamentos no SQL Server. Ele cria uma estrutura de tabela e triggers para capturar eventos relacionados a jobs e seus schedules, fornecendo um registro detalhado para análise.

### Principais Funcionalidades
1. **Criação de Tabela de Auditoria:**
   - A tabela `Auditoria.dbo.Job_Audit` é criada para armazenar registros de eventos, incluindo:
     - Data do evento.
     - Usuário responsável.
     - Nome do job.
     - Nome do host.
     - Query executada.
     - Situação (ativado/desativado).

2. **Triggers de Auditoria:**
   - **`trgJobs_Status`:** Monitora alterações no status dos jobs (`enabled`).
   - **`trgAudit_Schedules`:** Captura alterações nos schedules dos jobs (update ou delete).
   - **`trgAudit_Jobs_Schedules`:** Captura inserções de novos schedules para jobs.

3. **Captura de Query Executada:**
   - Utiliza `DBCC INPUTBUFFER` para registrar a última query executada no evento.

4. **Armazenamento de Eventos:**
   - Cada trigger insere os dados capturados na tabela de auditoria, permitindo uma análise centralizada.

### Observações
- **Compressão de Dados:** A tabela de auditoria utiliza compressão de página para otimizar o armazenamento.
- **Permissões Necessárias:**
  - O usuário que executa o script deve ter permissões suficientes para criar tabelas, triggers e usar `DBCC INPUTBUFFER`.
- **Configurações de Ambiente:**
  - Certifique-se de que o banco `Auditoria` esteja disponível antes de executar o script.
- **Manutenção:** Inclui um bloco comentado para remoção dos triggers, caso necessário.

```SQL
USE [Auditoria]
GO

IF (OBJECT_ID('Auditoria.dbo.Job_Audit') IS NULL)
BEGIN

    -- DROP TABLE Auditoria.[dbo].[Job_Audit]
    CREATE TABLE Auditoria.[dbo].[Job_Audit] (
        [Id_Auditoria] [INT] IDENTITY(1,1) PRIMARY KEY CLUSTERED NOT NULL,
        [Dt_Evento] [DATETIME] NULL DEFAULT (GETDATE()),
        [Ds_Usuario] [VARCHAR](50) NULL,
        [Ds_Job] [sysname] NULL,
        [Ds_Hostname] [VARCHAR](50) NULL,
        [Ds_Query] [VARCHAR](MAX) NULL,
        [Fl_Situacao] [TINYINT] NULL
    )
    WITH (DATA_COMPRESSION=PAGE)

END
```

```SQL
USE [msdb]
GO

/***************************************************************************************************
-- Trigger para os Jobs
***************************************************************************************************/
IF ((SELECT COUNT(*) FROM sys.triggers WHERE name = 'trgJobs_Status') > 0)
    DROP TRIGGER dbo.trgJobs_Status
GO

CREATE TRIGGER trgJobs_Status ON sysjobs
AFTER INSERT, UPDATE, DELETE AS
BEGIN
    
    
    SET NOCOUNT ON  


    DECLARE 
        @UserName VARCHAR(50) = SYSTEM_USER, 
        @HostName VARCHAR(50) = HOST_NAME(),  
        @JobName sysname,  
        @New_Enabled INT,  
        @Old_Enabled INT,  
        @ExecStr VARCHAR(100),
        @Qry VARCHAR(MAX)

        
    SELECT @New_Enabled = [enabled] FROM Inserted
    SELECT @Old_Enabled = [enabled] FROM Deleted
    SELECT @JobName = [name] FROM Deleted


    IF (@JobName IS NULL)
        SELECT @JobName = [name] FROM Inserted


    -- Identificando a query executada
    CREATE TABLE #inputbuffer (
        [EventType] NVARCHAR(60), 
        [Parameters] INT, 
        [EventInfo] VARCHAR(MAX)
    )

    SET @ExecStr = 'DBCC INPUTBUFFER(' + STR(@@SPID) + ')'

    INSERT INTO #inputbuffer 
    EXEC (@ExecStr)

    SET @Qry = (SELECT EventInfo FROM #inputbuffer)


    -- Verifica se houve alteração de status
    IF (@New_Enabled != @Old_Enabled)
    BEGIN  
        

        IF (@New_Enabled = 1)
        BEGIN  

            INSERT INTO Auditoria.dbo.Job_Audit ( Ds_Usuario, Ds_Job, Ds_Hostname, Ds_Query, Fl_Situacao )
            SELECT @UserName, @JobName, @HostName, @Qry, 1

        END  


        IF (@New_Enabled = 0)
        BEGIN  
            
            INSERT INTO Auditoria.dbo.Job_Audit ( Ds_Usuario, Ds_Job, Ds_Hostname, Ds_Query, Fl_Situacao )
            SELECT @UserName, @JobName, @HostName, @Qry, 0

        END  

    END
    ELSE BEGIN

        INSERT INTO Auditoria.dbo.Job_Audit ( Ds_Usuario, Ds_Job, Ds_Hostname, Ds_Query )
        SELECT @UserName, @JobName, @HostName, @Qry

    END

END
GO
```

```SQL
/***************************************************************************************************
-- Trigger para os Schedules dos Jobs
***************************************************************************************************/
IF ((SELECT COUNT(*) FROM sys.triggers WHERE name = 'trgAudit_Schedules') > 0)
    DROP TRIGGER dbo.trgAudit_Schedules
GO

CREATE TRIGGER [dbo].[trgAudit_Schedules] ON [dbo].[sysschedules]
AFTER UPDATE, DELETE 
AS
BEGIN
    
    
    SET NOCOUNT ON  


    DECLARE 
        @UserName VARCHAR(50) = SYSTEM_USER, 
        @HostName VARCHAR(50) = HOST_NAME(),  
        @JobName VARCHAR(MAX) = '',  
        @ExecStr VARCHAR(100),
        @Qry VARCHAR(MAX)


    IF ((SELECT COUNT(*) FROM Inserted) > 0)
    BEGIN

        SELECT @JobName += (CASE WHEN @JobName != '' THEN ' | ' ELSE '' END) + A.[name]
        FROM msdb.dbo.sysjobs A
        JOIN msdb.dbo.sysjobschedules B ON A.job_id = B.job_id
        JOIN Inserted C ON B.schedule_id = C.schedule_id

    END
    ELSE BEGIN

        SELECT @JobName += (CASE WHEN @JobName != '' THEN ' | ' ELSE '' END) + A.[name]
        FROM msdb.dbo.sysjobs A
        JOIN msdb.dbo.sysjobschedules B ON A.job_id = B.job_id
        JOIN Deleted C ON B.schedule_id = C.schedule_id

    END
```

```SQL       
    -- Identificando a query executada
    CREATE TABLE #inputbuffer (
        [EventType] NVARCHAR(60), 
        [Parameters] INT, 
        [EventInfo] VARCHAR(MAX)
    )

    SET @ExecStr = 'DBCC INPUTBUFFER(' + STR(@@SPID) + ')'

    INSERT INTO #inputbuffer 
    EXEC (@ExecStr)

    SET @Qry = (SELECT EventInfo FROM #inputbuffer)

    IF (@JobName != '')
    BEGIN
    
        INSERT INTO Auditoria.dbo.Job_Audit ( Ds_Usuario, Ds_Job, Ds_Hostname, Ds_Query )
        SELECT @UserName, @JobName, @HostName, @Qry

    END


END
GO
```

```SQL
ALTER TABLE [dbo].[sysschedules] ENABLE TRIGGER [trgAudit_Schedules]
GO
```

```SQL
/***************************************************************************************************
-- Trigger para os Schedules
***************************************************************************************************/
IF ((SELECT COUNT(*) FROM sys.triggers WHERE name = 'trgAudit_Jobs_Schedules') > 0) DROP TRIGGER dbo.trgAudit_Jobs_Schedules
GO

CREATE TRIGGER [dbo].[trgAudit_Jobs_Schedules] ON [dbo].[sysjobschedules]  
AFTER INSERT 
AS
BEGIN
    
    
    SET NOCOUNT ON  


    DECLARE 
        @UserName VARCHAR(50) = SYSTEM_USER, 
        @HostName VARCHAR(50) = HOST_NAME(),  
        @JobName sysname,  
        @ExecStr VARCHAR(100),
        @Qry VARCHAR(MAX)


    IF ((SELECT COUNT(*) FROM Inserted) > 0)
    BEGIN

        SELECT @JobName = A.[name]
        FROM msdb.dbo.sysjobs A
        JOIN Inserted B ON A.job_id = B.job_id

    END
    ELSE BEGIN

        SELECT @JobName = A.[name]
        FROM msdb.dbo.sysjobs A
        JOIN Deleted B ON A.job_id = B.job_id

    END
```

```SQL    
    -- Identificando a query executada
    CREATE TABLE #inputbuffer (
        [EventType] NVARCHAR(60), 
        [Parameters] INT, 
        [EventInfo] VARCHAR(MAX)
    )

    SET @ExecStr = 'DBCC INPUTBUFFER(' + STR(@@SPID) + ')'

    INSERT INTO #inputbuffer 
    EXEC (@ExecStr)

    SET @Qry = (SELECT EventInfo FROM #inputbuffer)

    
    INSERT INTO Auditoria.dbo.Job_Audit ( Ds_Usuario, Ds_Job, Ds_Hostname, Ds_Query )
    SELECT @UserName, @JobName, @HostName, @Qry


END
GO
```

```SQL
ALTER TABLE [dbo].[sysjobschedules] ENABLE TRIGGER [trgAudit_Jobs_Schedules]
GO
```


```SQL
SELECT * FROM Auditoria.[dbo].[Job_Audit]
```

```SQL
USE [msdb]
GO

IF ((SELECT COUNT(*) FROM sys.triggers WHERE name = 'trgJobs_Status') > 0)
    DROP TRIGGER dbo.trgJobs_Status
GO

IF ((SELECT COUNT(*) FROM sys.triggers WHERE name = 'trgAudit_Schedules') > 0)
    DROP TRIGGER dbo.trgAudit_Schedules
GO

IF ((SELECT COUNT(*) FROM sys.triggers WHERE name = 'trgAudit_Jobs_Schedules') > 0)
    DROP TRIGGER dbo.trgAudit_Jobs_Schedules
GO
```

