# Descrição do Script

Este script tem como objetivo auditar e registrar alterações em objetos do banco de dados no SQL Server. Ele cria um trigger que monitora eventos de DDL (Data Definition Language) em nível de banco de dados, capturando informações sobre a criação, modificação e exclusão de objetos, além de realizar ações específicas para operações realizadas em bancos de dados do sistema.

1. **Remoção do Trigger Existente**: Caso já exista um trigger chamado `trgAlteracao_Objetos`, o script o remove para criar uma nova versão.

2. **Criação do Trigger de Alteração de Objetos**: Cria um trigger chamado `trgAlteracao_Objetos` que é executado para eventos de alteração de objetos em todos os bancos de dados (exceto `tempdb`). O trigger captura informações detalhadas sobre o evento, como:
   - Data e hora do evento.
   - Tipo de evento (criação ou modificação).
   - Nome do banco de dados, usuário, esquema, objeto e tipo de objeto afetado.
   - Texto completo da query executada.

3. **Verificação e Ações Específicas para Bancos de Dados de Sistema**: Se o evento ocorrer em um banco de dados de sistema (`master`, `model`, `msdb`), o script gera uma mensagem de alerta indicando que a operação foi realizada nesse banco e solicita que a ação seja repetida no banco de dados correto. As mensagens são personalizadas para eventos de criação ou modificação de objetos.

4. **Criação da Tabela de Auditoria**: Caso a tabela de auditoria `Alteracao_Objetos` não exista, o script a cria no banco de dados `Auditoria` para armazenar os eventos de alteração. A tabela possui os seguintes campos:
   - `Id_Auditoria`: Identificador único para o evento.
   - `Dt_Evento`: Data e hora do evento.
   - `Ds_Tipo_Evento`: Tipo do evento (criação ou modificação).
   - `Ds_Database`: Nome do banco de dados afetado.
   - `Ds_Usuario`: Nome do usuário que executou a operação.
   - `Ds_Schema`: Nome do esquema afetado.
   - `Ds_Objeto`: Nome do objeto afetado.
   - `Ds_Tipo_Objeto`: Tipo de objeto (por exemplo, tabela, índice).
   - `Ds_Query`: Query executada que gerou o evento.

5. **Inserção na Tabela de Auditoria**: Quando o evento ocorre em um banco de dados não-sistema (exceto `tempdb`), os detalhes do evento são registrados na tabela `Alteracao_Objetos`.

6. **Concessão de Permissões**: O script concede permissões para o usuário `guest` se conectar ao banco de dados `Auditoria` e para o público (`public`) inserir dados na tabela de auditoria.

Esse mecanismo de auditoria garante que todas as alterações importantes nos objetos do banco de dados sejam registradas e analisadas, especialmente para evitar mudanças em bancos de dados críticos do sistema e garantir que as operações sejam realizadas nos bancos corretos.

```sql
USE [master]
GO

IF ((SELECT COUNT(*) FROM sys.server_triggers WHERE name = 'trgAlteracao_Objetos') > 0)
    DROP TRIGGER [trgAlteracao_Objetos] ON ALL SERVER
GO

CREATE TRIGGER [trgAlteracao_Objetos]
ON ALL SERVER -- ON DATABASE
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
 
 
    IF (@Ds_Database IN ('master', 'model', 'msdb'))
    BEGIN
 
        IF (LEFT(@Ds_Tipo_Evento, 6) = 'CREATE')
        BEGIN
 
            SET @Mensagem = 'Você (' + @Ds_Usuario + ') acabou de criar um objeto na database de sistema ' + @Ds_Database + ' e essa operação foi logada. 
 
Favor excluir e criar na database correta. 
 
A equipe de Banco de Dados agradece a sua colaboração.'
 
 
            PRINT @Mensagem
 
 
        END
        ELSE BEGIN
 
            IF (LEFT(@Ds_Tipo_Evento, 5) = 'ALTER')
            BEGIN
 
                SET @Mensagem = 'Você (' + @Ds_Usuario + ') acabou de modificar um objeto na database de sistema ' + @Ds_Database + ' e essa operação foi logada. 
 
Favor criar o objeto na database correta. 
 
A equipe de Banco de Dados agradece a sua colaboração.'
 
 
                PRINT @Mensagem
 
            END
 
        END
 
    END
```

```sql
    IF (OBJECT_ID('Auditoria.dbo.Alteracao_Objetos') IS NULL)
    BEGIN
 
        -- DROP TABLE Auditoria.dbo.Alteracao_Objetos
        CREATE TABLE Auditoria.dbo.Alteracao_Objetos (
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
        
        CREATE CLUSTERED INDEX SK01 ON Auditoria.dbo.Alteracao_Objetos(Id_Auditoria)
 
    END
 
 
    IF (@Ds_Database NOT IN ('tempdb'))
    BEGIN
 
        INSERT INTO Auditoria.dbo.Alteracao_Objetos
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
 
ENABLE TRIGGER [trgAlteracao_Objetos] ON ALL SERVER -- ON DATABASE
GO
```

```sql
USE [Auditoria]
GO

GRANT CONNECT TO [guest]
GRANT INSERT ON Auditoria.dbo.Alteracao_Objetos TO [public]
GO
```