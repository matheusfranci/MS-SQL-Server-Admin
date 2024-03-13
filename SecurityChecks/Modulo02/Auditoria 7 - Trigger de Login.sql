USE [master]
GO


IF (OBJECT_ID('Auditoria.dbo.Logins') IS NULL)
BEGIN
    
    -- DROP TABLE Auditoria.dbo.Logins
    CREATE TABLE Auditoria.dbo.Logins (
        Id_Auditoria INT IDENTITY(1,1),
        Dt_Evento DATETIME,
        SPID SMALLINT,
        Ds_Usuario VARCHAR(100) NULL,
        Ds_Usuario_Original VARCHAR(100) NULL,
        Ds_Tipo_Usuario VARCHAR(30) NULL,
        Ds_Ip VARCHAR(30) NULL,
        Ds_Hostname VARCHAR(100) NULL,
        Ds_Software VARCHAR(500) NULL
    )

    CREATE CLUSTERED INDEX SK01 ON Auditoria.dbo.Logins(Id_Auditoria)

END



IF ((SELECT COUNT(*) FROM sys.server_triggers WHERE name = 'trgAudit_Login') > 0)
    DROP TRIGGER [trgAudit_Login] ON ALL SERVER
GO


CREATE TRIGGER [trgAudit_Login] ON ALL SERVER 
FOR LOGON 
AS
BEGIN


    SET NOCOUNT ON
    
    
    -- N�o loga conex�es de usu�rios de sistema
    IF (ORIGINAL_LOGIN() IN ('sa', 'AUTORIDADE NT\SISTEMA', 'NT AUTHORITY\SYSTEM') OR ORIGINAL_LOGIN() LIKE '%SQLServerAgent' OR ORIGINAL_LOGIN() LIKE 'NT AUTHORITY\%')
        RETURN
        
        
    -- N�o loga conex�es de softwares que ficam se conectando constantemente
    IF (PROGRAM_NAME() LIKE 'Red Gate%' OR PROGRAM_NAME() LIKE '%IntelliSense%' OR PROGRAM_NAME() IN ('Microsoft SQL Server', 'RSManagement', 'RSPowerBI', 'TransactionManager', 'SQLServerCEIP', 'Report Server'))
        RETURN


    DECLARE 
        @Evento XML, 
        @Dt_Evento DATETIME,
        @Ds_Usuario VARCHAR(100),
        @Ds_Usuario_Original VARCHAR(100),
        @Ds_Tipo_Usuario VARCHAR(30),
        @Ds_Ip VARCHAR(30),
        @SPID SMALLINT,
        @Ds_Hostname VARCHAR(100),
        @Ds_Software VARCHAR(100)
        


    SET @Evento = EVENTDATA()

    
    SELECT 
        @Dt_Evento = @Evento.value('(/EVENT_INSTANCE/PostTime/text())[1]','datetime'),
        @Ds_Usuario = @Evento.value('(/EVENT_INSTANCE/LoginName/text())[1]','varchar(100)'),
        @Ds_Tipo_Usuario = @Evento.value('(/EVENT_INSTANCE/LoginType/text())[1]','varchar(30)'),
        @Ds_Hostname = HOST_NAME(),
        @Ds_Ip = @Evento.value('(/EVENT_INSTANCE/ClientHost/text())[1]','varchar(100)'),
        @SPID = @Evento.value('(/EVENT_INSTANCE/SPID/text())[1]','smallint'),
        @Ds_Software = PROGRAM_NAME()
         

    -- Identifica o usu�rio original caso seja um usu�rio SQL
    IF (LEFT(@Ds_Tipo_Usuario, 7) != 'Windows')
    BEGIN
            
        SELECT @Ds_Usuario_Original = (
            SELECT 
                A.Ds_Usuario
            FROM 
                Auditoria.dbo.Logins A
                JOIN (
                    SELECT Ds_Hostname, MAX(Id_Auditoria) AS Id_MAX
                    FROM Auditoria.dbo.Logins	WITH(NOLOCK)
                    WHERE Ds_Tipo_Usuario LIKE 'Windows%'
                    GROUP BY Ds_Hostname
                ) B ON A.Ds_Hostname = B.Ds_Hostname AND A.Id_Auditoria = B.Id_MAX
        )

    END	


    -- Evita gravar v�rias vezes um mesmo login
    DECLARE @Dt_Ultima_Data DATETIME
    SELECT @Dt_Ultima_Data = MAX(Dt_Evento)
    FROM Auditoria.dbo.Logins
    WHERE Ds_Usuario = @Ds_Usuario
    AND SPID = @SPID
    

    
    IF (DATEDIFF(SECOND, ISNULL(@Dt_Ultima_Data, '1990-01-01'), @Dt_Evento) > 1)
    BEGIN
    
        INSERT INTO Auditoria.dbo.Logins
        SELECT 
            GETDATE(),
            @SPID,
            @Ds_Usuario,
            @Ds_Usuario_Original,
            @Ds_Tipo_Usuario,
            @Ds_Ip,
            @Ds_Hostname,
            @Ds_Software

    END
            

END
GO

ENABLE TRIGGER [trgAudit_Login] ON ALL SERVER  
GO


USE [Auditoria]
GO

GRANT CONNECT TO [guest]
GO

GRANT SELECT, INSERT ON Auditoria.dbo.Logins TO [public]
GO














--------------------------------------------------------------
-- Cria as tabelas tempor�rias
--------------------------------------------------------------

IF (OBJECT_ID('tempdb..#Arquivos_Log') IS NOT NULL) DROP TABLE #Arquivos_Log
CREATE TABLE #Arquivos_Log ( 
    [idLog] INT, 
    [dtLog] NVARCHAR(30) COLLATE SQL_Latin1_General_CP1_CI_AI, 
    [tamanhoLog] INT 
)

IF (OBJECT_ID('tempdb..#Login_Failed') IS NOT NULL) DROP TABLE #Login_Failed
CREATE TABLE #Login_Failed (
    [LogNumber] TINYINT,
    [LogDate] DATETIME, 
    [ProcessInfo] NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AI, 
    [Text] NVARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CI_AI,
    [Username] AS LTRIM(RTRIM(REPLACE(REPLACE(SUBSTRING(REPLACE([Text], 'Login failed for user ''', ''), 1, CHARINDEX('. Reason:', REPLACE([Text], 'Login failed for user ''', '')) - 2), CHAR(10), ''), CHAR(13), ''))),
    [IP] AS LTRIM(RTRIM(REPLACE(REPLACE(REPLACE((SUBSTRING([Text], CHARINDEX('[CLIENT: ', [Text]) + 9, LEN([Text]))), ']', ''), CHAR(10), ''), CHAR(13), '')))
)

--------------------------------------------------------------
-- Importa os arquivos do ERRORLOG
--------------------------------------------------------------

INSERT INTO #Arquivos_Log
EXEC sys.sp_enumerrorlogs


--------------------------------------------------------------
-- Loop para procurar por falhas de login nos arquivos
--------------------------------------------------------------

DECLARE
    @Contador INT = 0,
    @Total INT = (SELECT COUNT(*) FROM #Arquivos_Log)
    

WHILE(@Contador < @Total)
BEGIN
    
    -- Pesquisa por senha incorreta
    INSERT INTO #Login_Failed (LogDate, ProcessInfo, [Text]) 
    EXEC master.dbo.sp_readerrorlog @Contador, 1, N'Password did not match that for the login provided'

    -- Pesquisa por tentar conectar com usu�rio que n�o existe
    INSERT INTO #Login_Failed (LogDate, ProcessInfo, [Text]) 
    EXEC master.dbo.sp_readerrorlog @Contador, 1, N'Could not find a login matching the name provided.'

    -- Atualiza o n�mero do arquivo de log
    UPDATE #Login_Failed
    SET LogNumber = @Contador
    WHERE LogNumber IS NULL

    SET @Contador += 1
    
END


SELECT * FROM #Login_Failed