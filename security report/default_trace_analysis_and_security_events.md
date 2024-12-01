## Descrição do Script

Este script realiza a verificação, análise e ativação do trace padrão do SQL Server, com foco em eventos de segurança e uso do banco de dados. O trace padrão é uma ferramenta útil para monitoramento e auditoria, permitindo identificar atividades importantes no servidor.

### 1. **Verificando se o Default Trace Está Habilitado**
   - O script consulta a tabela `sys.traces` para verificar se o default trace está habilitado na instância SQL Server. O default trace é utilizado para registrar eventos e atividades críticas no banco de dados, como logins, falhas de autenticação e outros eventos importantes.

### 2. **Listando os Eventos do Trace Padrão**
   - Após identificar que o default trace está habilitado, o script obtém os eventos registrados no trace utilizando a função `fn_trace_geteventinfo`. Os eventos listados são provenientes da tabela `sys.trace_events`, que contém os detalhes dos tipos de eventos de trace.

### 3. **Ativando o Default Trace**
   - Embora o default trace já esteja habilitado por padrão, o script configura explicitamente a opção para garantir que ele esteja ativado. Para isso, utiliza o procedimento `sp_configure` para ajustar a configuração `default trace enabled`.

### 4. **Identificando e Sumarizando os Eventos**
   - O script identifica e sumariza os eventos registrados no default trace. Ele agrupa os eventos por nome e calcula a quantidade de ocorrências para cada tipo de evento, ajudando na análise de atividades e padrões no servidor SQL.

### 5. **Analisando Eventos Relacionados à Segurança**
   - O script realiza uma análise aprofundada dos eventos relacionados à segurança, como logins, falhas de autenticação, mudanças de permissões e outras atividades sensíveis. São filtrados eventos com IDs específicos (20, 22, 46, 47, etc.) e excluídos registros irrelevantes ou de fontes conhecidas, como o `NETWORK SERVICE`.

### 6. **Teste: Criar, Alterar e Excluir Tabelas**
   - O script realiza um teste simples de criação, alteração e exclusão de tabelas no banco de dados. Ele cria uma tabela chamada `Teste`, adiciona uma coluna, concede permissões de `SELECT` para um usuário e, em seguida, exclui a tabela.

```SQL
USE [DB]
GO

-- Verificando se o default trace está habilitado
SELECT * FROM sys.traces WHERE is_default = 1
```

```SQL
-- Listando os eventos do trace padrão
DECLARE @id INT = ( SELECT id FROM sys.traces WHERE is_default = 1 )

SELECT DISTINCT
    eventid,
    name
FROM
    fn_trace_geteventinfo(@id) EI
    JOIN sys.trace_events TE ON EI.eventid = TE.trace_event_id;
```
	
```SQL
-- Ativando o Trace Padrão (Já vem habilitado após a instalação)
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
-- Analisando os eventos relacionados à segurança
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