# Descri��o dos Scripts de Auditoria e Monitoramento no SQL Server

Este conjunto de scripts configura a auditoria no SQL Server para registrar e monitorar altera��es no banco de dados, incluindo opera��es DML (Delete, Insert, Update) e permiss�es de acesso. Cada script executa uma fun��o espec�fica para configurar a auditoria, registrar eventos e gerar relat�rios sobre os acessos e permiss�es.

## 1. Cria��o de uma auditoria no n�vel do servidor

Este script verifica se j� existe uma auditoria chamada "Auditoria_Arquivo" e, se sim, desativa e a exclui. Depois, cria uma nova auditoria, configurando o diret�rio de armazenamento dos logs e outras op��es, como o tamanho m�ximo de arquivos e o atraso na fila.

## 2. Cria��o da especifica��o de auditoria no n�vel do servidor

O script cria uma especifica��o de auditoria para monitorar as altera��es no banco de dados, especificamente utilizando o grupo de captura `DATABASE_CHANGE_GROUP`. A auditoria registra mudan�as de dados no n�vel do servidor.

## 3. Cria��o da especifica��o de auditoria no n�vel do banco de dados

No banco de dados "Auditoria", o script verifica se uma especifica��o de auditoria chamada "Audita_DML" existe, desativando e excluindo-a se necess�rio. Em seguida, cria uma nova especifica��o de auditoria que rastreia a��es de DELETE, INSERT e outras opera��es DML, especificando usu�rios ou esquemas.

## 4. Cria��o de uma tabela para testes e auditoria

Cria a tabela `dbo._Teste`, insere alguns dados de exemplo e ajusta o n�vel de compatibilidade do banco de dados "Auditoria" para 140.

## 5. Consultando arquivos de auditoria

Este script consulta os arquivos de auditoria gerados pela auditoria de servidor "Auditoria_Arquivo". Ele retorna informa��es como o tempo do evento, ID da a��o, nome do principal do servidor e a declara��o que gerou o evento, permitindo a an�lise dos logs de auditoria.

## 6. Cria��o de tabela para auditoria de acessos

Uma tabela chamada `Auditoria_Acesso` � criada para armazenar os registros de auditoria de acessos. Essa tabela registra dados como a data da auditoria, a��o executada, m�quina, usu�rio, database, objeto, query executada, e sucesso da opera��o.

## 7. Cria��o de uma auditoria para acessos

Cria uma auditoria chamada "Auditoria_Acessos" para monitorar permiss�es de usu�rios no SQL Server. Os logs de auditoria ser�o armazenados em arquivos espec�ficos e a auditoria est� configurada para registrar apenas certos tipos de a��es executadas por usu�rios espec�ficos, excluindo a��es de ferramentas como o SQL Server Management Studio.

## 8. Cria��o e configura��o da especifica��o de auditoria para permiss�es

Este script configura uma especifica��o de auditoria de banco de dados para rastrear a��es de DELETE, INSERT, SELECT, UPDATE e EXECUTE em todas as bases de dados, aplicando uma auditoria para acessos. A auditoria � configurada para capturar eventos relacionados a essas a��es e adicion�-los � especifica��o.

## 9. Cria��o de procedimento para carregar dados de auditoria

Cria e configura o procedimento armazenado `dbo.stpAuditoria_Acessos_Carrega_Dados`, que carrega os dados de auditoria para a tabela `Auditoria_Acesso`. O procedimento insere os dados de auditoria a partir dos arquivos de auditoria gerados no caminho especificado e filtra os eventos que ocorreram ap�s a �ltima inser��o na tabela.

## 10. Gera��o de comandos GRANT a partir dos dados de auditoria

O script gera comandos SQL para conceder permiss�es (como SELECT, INSERT, UPDATE) para os usu�rios baseados nos dados registrados na tabela de auditoria. Ele cria comandos GRANT din�micos para cada opera��o, permitindo a recria��o das permiss�es observadas a partir dos logs de auditoria.

```sql
USE [master]
GO

IF ((SELECT COUNT(*) FROM sys.server_audits WHERE [name] = 'Auditoria_Arquivo') > 0)
BEGIN

    ALTER SERVER AUDIT Auditoria_Arquivo WITH (STATE = OFF);

    DROP SERVER AUDIT [Auditoria_Arquivo];

END
GO
```

```sql
CREATE SERVER AUDIT [Auditoria_Arquivo]
TO FILE 
(	FILEPATH = N'C:\Auditoria\'
	,MAXSIZE = 100 MB
	,MAX_ROLLOVER_FILES = 4
	,RESERVE_DISK_SPACE = OFF
)
WITH
(	QUEUE_DELAY = 1000
	,ON_FAILURE = CONTINUE
)
GO
```

```sql
ALTER SERVER AUDIT Auditoria_Arquivo WITH (STATE = ON)
GO
```

```sql
USE [master]
GO

IF ((SELECT COUNT(*) FROM sys.server_audit_specifications WHERE [name] = 'Auditoria_Arquivo_Especificacao') > 0)
BEGIN
    
    ALTER SERVER AUDIT SPECIFICATION [Auditoria_Arquivo_Especificacao] WITH(STATE = OFF);

    DROP SERVER AUDIT SPECIFICATION [Auditoria_Arquivo_Especificacao];

END
GO
```

```sql
CREATE SERVER AUDIT SPECIFICATION [Auditoria_Arquivo_Especificacao]
FOR SERVER AUDIT [Auditoria_Arquivo]
ADD (DATABASE_CHANGE_GROUP)
WITH (STATE = ON)
GO
```

```sql
USE [Auditoria]
GO

IF ((SELECT COUNT(*) FROM sys.database_audit_specifications WHERE [name] = 'Audita_DML') > 0)
BEGIN

    ALTER DATABASE AUDIT SPECIFICATION [Audita_DML] WITH(STATE = OFF);

    DROP DATABASE AUDIT SPECIFICATION [Audita_DML];

END
GO
```

```sql
CREATE DATABASE AUDIT SPECIFICATION [Audita_DML]
FOR SERVER AUDIT [Auditoria_Arquivo]
ADD (DELETE ON DATABASE::[Auditoria] BY [DIRCEU-VM\dirceu]),
ADD (INSERT ON SCHEMA::[dbo] BY [public]),
ADD (INSERT ON OBJECT::[dbo].[Clientes] BY [public])
WITH (STATE = ON)
GO
```

```sql
IF (OBJECT_ID('dbo._Teste') IS NOT NULL) DROP TABLE dbo._Teste
CREATE TABLE dbo._Teste (
    Nome VARCHAR(100)
)

INSERT INTO dbo._Teste
VALUES('Teste'), ('Audit')
GO
```

```sql
ALTER DATABASE Auditoria SET COMPATIBILITY_LEVEL = 140
GO
```

```sql
-- Retorna as informa��es de um arquivo espec�fico
SELECT event_time,action_id,server_principal_name,statement,* 
FROM sys.fn_get_audit_file('C:\Auditoria\Auditoria_Arquivo_B8CA34F9-D2E9-4F28-98FF-1981A5F5F1BB_0_132455700720700000.sqlaudit',default,default)  
```

```sql
-- Retorna as informa��es de todos os arquivos
SELECT event_time,action_id,server_principal_name,statement,* 
FROM sys.fn_get_audit_file('C:\Auditoria\*.sqlaudit',default,default)
```

```sql
--------- PERMISS�ES REAIS ------------------

CREATE TABLE [dbo].[Auditoria_Acesso]
(
    [Id_Auditoria] [bigint] NOT NULL IDENTITY(1, 1),
    [Dt_Auditoria] [datetime] NOT NULL,
    [Cd_Acao] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
    [Ds_Maquina] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
    [Ds_Usuario] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
    [Ds_Database] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
    [Ds_Schema] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
    [Ds_Objeto] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
    [Ds_Query] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
    [Fl_Sucesso] [bit] NOT NULL,
    [Ds_IP] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
    [Ds_Programa] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
    [Qt_Duracao] [bigint] NOT NULL,
    [Qt_Linhas_Retornadas] [bigint] NOT NULL,
    [Qt_Linhas_Alteradas] [bigint] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
WITH
(
DATA_COMPRESSION = PAGE
)
GO
ALTER TABLE [dbo].[Auditoria_Acesso] ADD CONSTRAINT [PK__Auditori__E9F1DAD4EE3743FE] PRIMARY KEY CLUSTERED ([Id_Auditoria]) WITH (DATA_COMPRESSION = PAGE) ON [PRIMARY]
GO
```

```sql
USE [master]
GO

IF ((SELECT COUNT(*) FROM sys.server_audits WHERE [name] = 'Auditoria_Acessos') > 0)
BEGIN
    ALTER SERVER AUDIT [Auditoria_Acessos] WITH (STATE = OFF);
    DROP SERVER AUDIT [Auditoria_Acessos]
END
```

```sql
CREATE SERVER AUDIT [Auditoria_Acessos]
TO FILE
(	
    FILEPATH = N'C:\Auditoria\Permissoes\',
    MAXSIZE = 10 MB,
    MAX_ROLLOVER_FILES = 16,
    RESERVE_DISK_SPACE = OFF
)
WITH
(	
    QUEUE_DELAY = 1000,
    ON_FAILURE = CONTINUE,
    AUDIT_GUID = '0b5ad307-ee47-43db-a169-9af67cb661f9'
)
WHERE (([server_principal_name] LIKE '%User' OR [server_principal_name] LIKE 'LS_%') AND [application_name]<>'Microsoft SQL Server Management Studio - Transact-SQL IntelliSense' AND NOT [application_name] LIKE 'Red Gate Software%')
GO
```

```sql
ALTER SERVER AUDIT [Auditoria_Acessos] WITH (STATE = ON)
GO
```

```sql
DECLARE @Query VARCHAR(MAX)
SET @Query = '

IF (''?'' NOT IN (''master'', ''tempdb'', ''model'', ''msdb''))
BEGIN

    USE [?];

    IF ((SELECT COUNT(*) FROM sys.database_audit_specifications WHERE [name] = ''Auditoria_Acessos'') > 0)
    BEGIN

        ALTER DATABASE AUDIT SPECIFICATION [Auditoria_Acessos] WITH (STATE = OFF);
        DROP DATABASE AUDIT SPECIFICATION [Auditoria_Acessos];

    END

    CREATE DATABASE AUDIT SPECIFICATION [Auditoria_Acessos]
    FOR SERVER AUDIT [Auditoria_Acessos]
    ADD (DELETE ON DATABASE::[?] BY [public]),
    ADD (EXECUTE ON DATABASE::[?] BY [public]),
    ADD (INSERT ON DATABASE::[?] BY [public]),
    ADD (SELECT ON DATABASE::[?] BY [public]),
    ADD (UPDATE ON DATABASE::[?] BY [public])
    WITH (STATE = ON);
    
END'
```

```sql
EXEC sys.sp_MSforeachdb @Query

IF (OBJECT_ID('dbo.stpAuditoria_Acessos_Carrega_Dados') IS NULL) EXEC('CREATE PROCEDURE dbo.stpAuditoria_Acessos_Carrega_Dados AS SELECT 1')
GO

ALTER PROCEDURE dbo.stpAuditoria_Acessos_Carrega_Dados
AS
BEGIN

    DECLARE @TimeZone INT = DATEDIFF(HOUR, GETUTCDATE(), GETDATE())
    DECLARE @Dt_Max DATETIME = DATEADD(SECOND, 1, ISNULL((SELECT MAX(Dt_Auditoria) FROM dbo.Auditoria_Acesso), '1900-01-01'))

    INSERT INTO dbo.Auditoria_Acesso
    (
        Dt_Auditoria,
        Cd_Acao,
        Ds_Maquina,
        Ds_Usuario,
        Ds_Database,
        Ds_Schema,
        Ds_Objeto,
        Ds_Query
        Fl_Sucesso,
        Ds_IP,
        Ds_Programa,
        Qt_Duracao,
        Qt_Linhas_Retornadas,
        Qt_Linhas_Alteradas
    )
    SELECT DISTINCT
        DATEADD(HOUR, @TimeZone, event_time) AS event_time,
        action_id,
        server_instance_name,
        server_principal_name,
        [database_name],
        [schema_name],
        [object_name],
        [statement],
        succeeded,
        client_ip,
        application_name,
        duration_milliseconds,
        response_rows,
        affected_rows
    FROM 
        sys.fn_get_audit_file('C:\Auditoria\Permissoes\*.sqlaudit', DEFAULT, DEFAULT)
    WHERE 
        DATEADD(HOUR, @TimeZone, event_time) >= @Dt_Max

END
```

```sql
SELECT DISTINCT 
    Ds_Usuario,
    Ds_Database, 
    Cd_Acao, 
    Ds_Objeto,
    'USE [' + Ds_Database + ']; GRANT ' + (CASE Cd_Acao
        WHEN 'UP' THEN 'UPDATE'
        WHEN 'IN' THEN 'INSERT'
        WHEN 'DL' THEN 'DELETE'
        WHEN 'SL' THEN 'SELECT'
        WHEN 'EX' THEN 'EXECUTE'
    END) + ' ON [' + Ds_Schema + '].[' + Ds_Objeto + '] TO [' + Ds_Usuario + '];' AS Comando 
FROM 
    dbo.Auditoria_Acesso 
WHERE 
    Cd_Acao <> 'UNDO'
ORDER BY
    Ds_Usuario,
    Ds_Database,
    Ds_Objeto;
```