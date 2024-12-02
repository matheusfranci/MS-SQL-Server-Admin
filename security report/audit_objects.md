# Descri��o do Script

Este script tem como objetivo auditar e registrar altera��es em objetos do banco de dados no SQL Server. Ele cria um trigger que monitora eventos de DDL (Data Definition Language) em n�vel de banco de dados, capturando informa��es sobre a cria��o, modifica��o e exclus�o de objetos, al�m de realizar a��es espec�ficas para opera��es realizadas em bancos de dados do sistema.

1. **Remo��o do Trigger Existente**: Caso j� exista um trigger chamado `trgAlteracao_Objetos`, o script o remove para criar uma nova vers�o.

2. **Cria��o do Trigger de Altera��o de Objetos**: Cria um trigger chamado `trgAlteracao_Objetos` que � executado para eventos de altera��o de objetos em todos os bancos de dados (exceto `tempdb`). O trigger captura informa��es detalhadas sobre o evento, como:
   - Data e hora do evento.
   - Tipo de evento (cria��o ou modifica��o).
   - Nome do banco de dados, usu�rio, esquema, objeto e tipo de objeto afetado.
   - Texto completo da query executada.

3. **Verifica��o e A��es Espec�ficas para Bancos de Dados de Sistema**: Se o evento ocorrer em um banco de dados de sistema (`master`, `model`, `msdb`), o script gera uma mensagem de alerta indicando que a opera��o foi realizada nesse banco e solicita que a a��o seja repetida no banco de dados correto. As mensagens s�o personalizadas para eventos de cria��o ou modifica��o de objetos.

4. **Cria��o da Tabela de Auditoria**: Caso a tabela de auditoria `Alteracao_Objetos` n�o exista, o script a cria no banco de dados `Auditoria` para armazenar os eventos de altera��o. A tabela possui os seguintes campos:
   - `Id_Auditoria`: Identificador �nico para o evento.
   - `Dt_Evento`: Data e hora do evento.
   - `Ds_Tipo_Evento`: Tipo do evento (cria��o ou modifica��o).
   - `Ds_Database`: Nome do banco de dados afetado.
   - `Ds_Usuario`: Nome do usu�rio que executou a opera��o.
   - `Ds_Schema`: Nome do esquema afetado.
   - `Ds_Objeto`: Nome do objeto afetado.
   - `Ds_Tipo_Objeto`: Tipo de objeto (por exemplo, tabela, �ndice).
   - `Ds_Query`: Query executada que gerou o evento.

5. **Inser��o na Tabela de Auditoria**: Quando o evento ocorre em um banco de dados n�o-sistema (exceto `tempdb`), os detalhes do evento s�o registrados na tabela `Alteracao_Objetos`.

6. **Concess�o de Permiss�es**: O script concede permiss�es para o usu�rio `guest` se conectar ao banco de dados `Auditoria` e para o p�blico (`public`) inserir dados na tabela de auditoria.

Esse mecanismo de auditoria garante que todas as altera��es importantes nos objetos do banco de dados sejam registradas e analisadas, especialmente para evitar mudan�as em bancos de dados cr�ticos do sistema e garantir que as opera��es sejam realizadas nos bancos corretos.

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
 
            SET @Mensagem = 'Voc� (' + @Ds_Usuario + ') acabou de criar um objeto na database de sistema ' + @Ds_Database + ' e essa opera��o foi logada. 
 
Favor excluir e criar na database correta. 
 
A equipe de Banco de Dados agradece a sua colabora��o.'
 
 
            PRINT @Mensagem
 
 
        END
        ELSE BEGIN
 
            IF (LEFT(@Ds_Tipo_Evento, 5) = 'ALTER')
            BEGIN
 
                SET @Mensagem = 'Voc� (' + @Ds_Usuario + ') acabou de modificar um objeto na database de sistema ' + @Ds_Database + ' e essa opera��o foi logada. 
 
Favor criar o objeto na database correta. 
 
A equipe de Banco de Dados agradece a sua colabora��o.'
 
 
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