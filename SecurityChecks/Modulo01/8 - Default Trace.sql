USE [dirceuresende]
GO


-- Verificando se o default trace está habilitado
SELECT * FROM sys.traces WHERE is_default = 1












-- Listando os eventos do trace padrão
DECLARE @id INT = ( SELECT id FROM sys.traces WHERE is_default = 1 )

SELECT DISTINCT
    eventid,
    name
FROM
    fn_trace_geteventinfo(@id) EI
    JOIN sys.trace_events TE ON EI.eventid = TE.trace_event_id 






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











-- Teste: criar uma nova tabela, alterar e excluir
CREATE TABLE dbo.Teste (
	Nome VARCHAR(10) NOT NULL
)

ALTER TABLE dbo.Teste ADD Id INT

GRANT SELECT ON dbo.Teste TO [dirceu.resende]

DROP TABLE dbo.Teste


