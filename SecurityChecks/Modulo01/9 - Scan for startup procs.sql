
-- marca uma stored procedure para ser executada ao iniciar o sql server
USE [master]
GO

-- DROP TABLE dbo.Teste
CREATE TABLE dbo.Teste (
	Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Dt_Evento DATETIME NOT NULL
)

SELECT * FROM dbo.Teste

CREATE OR ALTER PROCEDURE dbo.stpTeste
AS
BEGIN

	INSERT INTO dbo.Teste
	VALUES(GETDATE())

END


EXEC sp_procoption 
	@ProcName = 'dbo.stpTeste', 
	@OptionName = 'startup', 
	@OptionValue = 'on'



















-- verificando as procedures que são inicializadas no sql server
SELECT * FROM sys.procedures WHERE is_auto_executed = 1






















-- desabilita a configuração scan for startup procs
USE [master]
GO
EXEC sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
EXEC sp_configure 'scan for startup procs', 0
GO
RECONFIGURE
GO
