

-- Server trigger habilitada
SELECT DISTINCT 
    A.[name], 
    B.event_group_type_desc
FROM
    sys.server_triggers A WITH(NOLOCK)
    JOIN sys.server_trigger_events B WITH(NOLOCK) ON B.[object_id] = A.[object_id]
WHERE
    A.is_ms_shipped = 0
    AND A.is_disabled = 0
ORDER BY
    1
























-- Criar uma trigger para impedir logins
USE [master]
GO

IF ((SELECT COUNT(*) FROM sys.server_triggers WHERE name = 'trgAudit_Login') > 0) DROP TRIGGER [trgAudit_Login] ON ALL SERVER
GO

CREATE OR ALTER TRIGGER [trgAudit_Login] ON ALL SERVER 
FOR LOGON 
AS
BEGIN


    SET NOCOUNT ON
    
    
    -- Não loga conexões de usuários de sistema
    IF (ORIGINAL_LOGIN() IN ('sa', 'AUTORIDADE NT\SISTEMA', 'NT AUTHORITY\SYSTEM') OR ORIGINAL_LOGIN() LIKE '%SQLServerAgent')
        RETURN
        

    PRINT 'Usuário não permitido para logar neste servidor. Favor entrar em contato com a equipe de Banco de Dados'
    ROLLBACK


END
GO

ENABLE TRIGGER [trgAudit_Login] ON ALL SERVER  
GO

















-- Auditando os logons
USE [master]
GO

IF ((SELECT COUNT(*) FROM sys.server_triggers WHERE name = 'trgAudit_Login') > 0) DROP TRIGGER [trgAudit_Login] ON ALL SERVER
GO

CREATE TRIGGER [trgAudit_Login] ON ALL SERVER 
FOR LOGON 
AS
BEGIN


    IF (OBJECT_ID('master.dbo.Logins') IS NULL)
    BEGIN
    
        -- DROP TABLE master.dbo.Logins
        CREATE TABLE master.dbo.Logins (
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

        CREATE CLUSTERED INDEX SK01 ON master.dbo.Logins(Id_Auditoria)

    END


    
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
         SELECT * FROM master.dbo.Logins

    INSERT INTO master.dbo.Logins
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
GO

ENABLE TRIGGER [trgAudit_Login] ON ALL SERVER  
GO


















IF ((SELECT COUNT(*) FROM sys.server_triggers WHERE name = 'trgAlteracao_Objetos') > 0) DROP TRIGGER [trgAlteracao_Objetos] ON ALL SERVER
GO

CREATE TRIGGER [trgAlteracao_Objetos]
ON ALL SERVER
FOR DDL_DATABASE_LEVEL_EVENTS
AS
BEGIN
 
 
    SET NOCOUNT ON
 
 
    DECLARE 
        @Evento XML, 
        @Mensagem VARCHAR(MAX),
 
        @Dt_Evento DATETIME,
        @Ds_Tipo_Evento VARCHAR(30),
        @Ds_Database VARCHAR(50),
        @Ds_Usuario VARCHAR(100),
        @Ds_Schema VARCHAR(20),
        @Ds_Objeto VARCHAR(100),
        @Ds_Tipo_Objeto VARCHAR(20),
        @Ds_Query VARCHAR(MAX)
 
 
    SET @Evento = EVENTDATA()
 
    SELECT 
        @Dt_Evento = @Evento.value('(/EVENT_INSTANCE/PostTime/text())[1]','datetime'),
        @Ds_Tipo_Evento = @Evento.value('(/EVENT_INSTANCE/EventType/text())[1]','varchar(30)'),
        @Ds_Database = @Evento.value('(/EVENT_INSTANCE/DatabaseName/text())[1]','varchar(50)'),
        @Ds_Usuario = @Evento.value('(/EVENT_INSTANCE/LoginName/text())[1]','varchar(100)'),
        @Ds_Schema = @Evento.value('(/EVENT_INSTANCE/SchemaName/text())[1]','varchar(20)'),
        @Ds_Objeto = @Evento.value('(/EVENT_INSTANCE/ObjectName/text())[1]','varchar(100)'),
        @Ds_Tipo_Objeto = @Evento.value('(/EVENT_INSTANCE/ObjectType/text())[1]','varchar(20)'),
        @Ds_Query = @Evento.value('(/EVENT_INSTANCE/TSQLCommand/CommandText/text())[1]','varchar(max)')
 
 
    IF (OBJECT_ID('dbo.Alteracao_Objetos') IS NULL)
    BEGIN
 
        -- DROP TABLE dbo.Alteracao_Objetos
        CREATE TABLE dbo.Alteracao_Objetos (
            Id_Auditoria INT IDENTITY(1,1),
            Dt_Evento DATETIME,
            Ds_Tipo_Evento VARCHAR(30),
            Ds_Database VARCHAR(50),
            Ds_Usuario VARCHAR(100),
            Ds_Schema VARCHAR(20),
            Ds_Objeto VARCHAR(100),
            Ds_Tipo_Objeto VARCHAR(20),
            Ds_Query XML
        )
        
        CREATE CLUSTERED INDEX SK01 ON dbo.Alteracao_Objetos(Id_Auditoria)
 
    END
 
 
    IF (@Ds_Database NOT IN ('tempdb'))
    BEGIN
 
        INSERT INTO dbo.Alteracao_Objetos
        SELECT 
            @Dt_Evento,
            @Ds_Tipo_Evento,
            @Ds_Database,
            @Ds_Usuario,
            @Ds_Schema,
            @Ds_Objeto,
            @Ds_Tipo_Objeto,
            @Evento
            
    END
 
 
END
GO
 
ENABLE TRIGGER [trgAlteracao_Objetos] ON ALL SERVER
GO




USE [master]
GO

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'dirceuresende123_usa_uma_senha_forte_aqui_talquei';  
GO

CREATE CERTIFICATE MeuCertificadoDoServidor WITH SUBJECT = 'Meu Certificado da Instância';  
GO

SELECT * FROM Alteracao_Objetos