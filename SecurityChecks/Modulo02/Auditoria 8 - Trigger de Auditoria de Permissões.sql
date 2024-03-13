USE [Auditoria]
GO

IF (OBJECT_ID('dbo.Alteracao_Privilegios') IS NULL)
BEGIN
    
    -- DROP TABLE dbo.Alteracao_Privilegios
    CREATE TABLE dbo.Alteracao_Privilegios (
        Id_Evento BIGINT IDENTITY(1, 1) PRIMARY KEY,
        Ds_Evento VARCHAR(255),
        Dt_Evento DATETIME,
        Ds_Database VARCHAR(255),
        Ds_Schema VARCHAR(255),
        Ds_Objeto VARCHAR(255),
        Ds_Tipo_Objeto VARCHAR(255),
        Ds_Usuario VARCHAR(255),
		Ds_Usuario_Afetado VARCHAR(255),
        Ds_Comando VARCHAR(MAX),
        Evento XML
    ) WITH(DATA_COMPRESSION=PAGE);

END



USE [master]
GO

IF ((SELECT COUNT(*) FROM sys.server_triggers WHERE name = 'trgAudit_Privileges') > 0)
    DROP TRIGGER [trgAudit_Privileges] ON ALL SERVER
GO

CREATE TRIGGER trgAudit_Privileges
ON ALL SERVER
FOR DDL_SERVER_SECURITY_EVENTS, DDL_DATABASE_SECURITY_EVENTS
AS
BEGIN
    
    
    DECLARE 
        @Ds_Evento NVARCHAR(255),
        @Ds_Schema NVARCHAR(255),
        @Ds_Database VARCHAR(255),
        @Ds_Objeto VARCHAR(255),
        @Ds_TipoObjeto VARCHAR(255),
        @Evento XML,
        @Ds_Comando VARCHAR(MAX),
		@Ds_Usuario NVARCHAR(255)

	SET @Evento = EVENTDATA()

    SELECT
        @Ds_Evento = @Evento.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(max)'),
        @Ds_Schema = @Evento.value('(/EVENT_INSTANCE/SchemaName)[1]', 'nvarchar(max)'),
        @Ds_Objeto = @Evento.value('(/EVENT_INSTANCE/ObjectName)[1]', 'nvarchar(max)'),
        @Ds_TipoObjeto = @Evento.value('(/EVENT_INSTANCE/ObjectType)[1]', 'nvarchar(max)'),
        @Ds_Database = @Evento.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'nvarchar(max)'),
		@Ds_Usuario = @Evento.value('(/EVENT_INSTANCE/Grantees)[1]', 'nvarchar(max)'),
        @Ds_Comando = @Evento.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]', 'nvarchar(max)')


    INSERT INTO Auditoria.dbo.Alteracao_Privilegios
    SELECT
        @Ds_Evento,
        GETDATE() AS Dt_Evento,
        @Ds_Database,
        @Ds_Schema,
        @Ds_Objeto,
        @Ds_TipoObjeto,
        ORIGINAL_LOGIN(),
		IIF(@Ds_TipoObjeto IN ('LOGIN', 'SQL USER'), @Ds_Objeto, @Ds_Usuario),
        @Ds_Comando,
        @Evento


END
GO

ENABLE TRIGGER trgAudit_Privileges ON ALL SERVER


USE [Auditoria]
GO

GRANT CONNECT TO [guest];
GRANT INSERT ON [dbo].[Alteracao_Privilegios] TO [public];


-- SELECT * FROM Auditoria.dbo.Alteracao_Privilegios
