# Auditoria de Alterações de Privilégios no SQL Server

## Descrição
Este script implementa uma auditoria para monitorar eventos de segurança relacionados a privilégios em servidores e bancos de dados SQL Server. Ele cria uma tabela dedicada para armazenar informações detalhadas sobre esses eventos e um trigger de servidor que captura alterações em segurança.

### Principais Funcionalidades
1. **Criação de Tabela de Auditoria:**
   - A tabela `Auditoria.dbo.Alteracao_Privilegios` armazena os seguintes detalhes:
     - Tipo do evento (ex.: `GRANT`, `REVOKE`, `DENY`).
     - Data e hora do evento.
     - Banco de dados, schema, e objeto afetados.
     - Tipo do objeto (ex.: `USER`, `ROLE`).
     - Usuário que executou o comando e usuário/grupo afetado.
     - Comando executado (query).
     - Dados completos do evento em formato XML.

2. **Trigger de Auditoria de Segurança:**
   - O trigger `trgAudit_Privileges` captura eventos de segurança definidos por `DDL_SERVER_SECURITY_EVENTS` e `DDL_DATABASE_SECURITY_EVENTS`.
   - Eventos monitorados incluem alterações em logins, usuários, permissões, funções e regras de segurança.

3. **Captura de Detalhes do Evento:**
   - Utiliza `EVENTDATA()` para obter informações detalhadas sobre o evento e os armazena na tabela de auditoria.

4. **Permissões e Configurações:**
   - Permite que usuários conectados (guest/public) insiram dados na tabela de auditoria, garantindo que o trigger funcione adequadamente.

### Observações
- **Compressão de Dados:** A tabela de auditoria utiliza compressão de página para otimizar o armazenamento.
- **Escopo do Trigger:**
  - O trigger é criado no nível do servidor (`ON ALL SERVER`), garantindo que eventos de segurança sejam capturados independentemente do banco de dados.
- **Manutenção:**
- Inclui um comando para desabilitar/remover o trigger caso necessário.
  
```SQL
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
```

```SQL
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
```

```SQL
ENABLE TRIGGER trgAudit_Privileges ON ALL SERVER
```

```SQL
USE [Auditoria]
GO

GRANT CONNECT TO [guest];
GRANT INSERT ON [dbo].[Alteracao_Privilegios] TO [public];
```

```SQL
SELECT * FROM Auditoria.dbo.Alteracao_Privilegios
```