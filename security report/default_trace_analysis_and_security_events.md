## Descri��o do Script

Este script realiza a verifica��o, an�lise e ativa��o do trace padr�o do SQL Server, com foco em eventos de seguran�a e uso do banco de dados. O trace padr�o � uma ferramenta �til para monitoramento e auditoria, permitindo identificar atividades importantes no servidor.

### 1. **Verificando se o Default Trace Est� Habilitado**
   - O script consulta a tabela `sys.traces` para verificar se o default trace est� habilitado na inst�ncia SQL Server. O default trace � utilizado para registrar eventos e atividades cr�ticas no banco de dados, como logins, falhas de autentica��o e outros eventos importantes.

### 2. **Listando os Eventos do Trace Padr�o**
   - Ap�s identificar que o default trace est� habilitado, o script obt�m os eventos registrados no trace utilizando a fun��o `fn_trace_geteventinfo`. Os eventos listados s�o provenientes da tabela `sys.trace_events`, que cont�m os detalhes dos tipos de eventos de trace.

### 3. **Ativando o Default Trace**
   - Embora o default trace j� esteja habilitado por padr�o, o script configura explicitamente a op��o para garantir que ele esteja ativado. Para isso, utiliza o procedimento `sp_configure` para ajustar a configura��o `default trace enabled`.

### 4. **Identificando e Sumarizando os Eventos**
   - O script identifica e sumariza os eventos registrados no default trace. Ele agrupa os eventos por nome e calcula a quantidade de ocorr�ncias para cada tipo de evento, ajudando na an�lise de atividades e padr�es no servidor SQL.

### 5. **Analisando Eventos Relacionados � Seguran�a**
   - O script realiza uma an�lise aprofundada dos eventos relacionados � seguran�a, como logins, falhas de autentica��o, mudan�as de permiss�es e outras atividades sens�veis. S�o filtrados eventos com IDs espec�ficos (20, 22, 46, 47, etc.) e exclu�dos registros irrelevantes ou de fontes conhecidas, como o `NETWORK SERVICE`.

### 6. **Teste: Criar, Alterar e Excluir Tabelas**
   - O script realiza um teste simples de cria��o, altera��o e exclus�o de tabelas no banco de dados. Ele cria uma tabela chamada `Teste`, adiciona uma coluna, concede permiss�es de `SELECT` para um usu�rio e, em seguida, exclui a tabela.

```SQL
USE [DB]
GO

-- Verificando se o default trace est� habilitado
SELECT * FROM sys.traces WHERE is_default = 1
```

```SQL
-- Listando os eventos do trace padr�o
DECLARE @id INT = ( SELECT id FROM sys.traces WHERE is_default = 1 )

SELECT DISTINCT
    eventid,
    name
FROM
    fn_trace_geteventinfo(@id) EI
    JOIN sys.trace_events TE ON EI.eventid = TE.trace_event_id;
```
	
```SQL
-- Ativando o Trace Padr�o (J� vem habilitado ap�s a instala��o)
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
EXEC sp_configure 'default trace enabled', 1;
GO
RECONFIGURE;
GO
EXEC sp_configure 'show advanced options', 0;
GO
RECONFIGURE;
GO
```

```SQL
-- Identificando e sumarizando os eventos
DECLARE @path VARCHAR(MAX) = (SELECT [path] FROM sys.traces WHERE is_default = 1)

SELECT
    B.trace_event_id,
    B.name AS EventName,
    A.DatabaseName,
    A.ApplicationName,
    A.LoginName,
    COUNT(*) AS Quantity
FROM
    sys.fn_trace_gettable(@path, DEFAULT) A
    INNER JOIN sys.trace_events B ON A.EventClass = B.trace_event_id
GROUP BY
    B.trace_event_id,
    B.name,
    A.DatabaseName,
    A.ApplicationName,
    A.LoginName
ORDER BY
    B.name,
    A.DatabaseName,
    A.ApplicationName,
    A.LoginName
```

```SQL
-- Analisando os eventos relacionados � seguran�a
DECLARE @path VARCHAR(MAX) = (SELECT [path] FROM sys.traces WHERE is_default = 1)

SELECT
    A.HostName,
    A.ApplicationName,
    A.NTUserName,
    A.NTDomainName,
    A.LoginName,
    A.SPID,
    A.EventClass,
    B.name,
    A.EventSubClass,
    A.TextData,
    A.StartTime,
    A.ObjectName,
    A.DatabaseName,
    A.TargetLoginName,
    A.TargetUserName
FROM
    sys.fn_trace_gettable(@path, DEFAULT) A
    INNER JOIN sys.trace_events B ON A.EventClass = B.trace_event_id
WHERE
	A.EventClass IN (20, 22, 46, 47, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 115, 152, 164, 175)
	AND A.LoginName NOT IN ( 'NT AUTHORITY\NETWORK SERVICE' )
    AND A.LoginName NOT LIKE '%SQLTELEMETRY$%'
    AND A.DatabaseName <> 'tempdb'
    AND NOT (B.name LIKE 'Object:%' AND A.ObjectName IS NULL )
    AND NOT (A.ApplicationName LIKE 'Red Gate%' OR A.ApplicationName LIKE '%Intellisense%' OR A.ApplicationName = 'DacFx Deploy')
ORDER BY
	A.StartTime,
    B.name,
    A.DatabaseName,
    A.ApplicationName,
    A.LoginName
```

```SQL
-- Teste: criar uma nova tabela, alterar e excluir
CREATE TABLE dbo.Teste (
	Nome VARCHAR(10) NOT NULL
)

ALTER TABLE dbo.Teste ADD Id INT

GRANT SELECT ON dbo.Teste TO [dirceu.resende]

DROP TABLE dbo.Teste
```