USE [master]
GO

--------------------------------------------------
-- Cria o login e os usuários nos bancos
--------------------------------------------------

IF (EXISTS(SELECT NULL FROM sys.server_principals WHERE [name] = 'pedro')) DROP LOGIN [pedro]
GO

CREATE LOGIN [pedro] WITH PASSWORD='aaa', CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF, DEFAULT_DATABASE=[master]
GO



USE [teste]
GO

IF (EXISTS(SELECT NULL FROM sys.database_principals WHERE [name] = 'pedro')) DROP USER [pedro]
GO

CREATE USER [pedro] FOR LOGIN [pedro]
GO


USE [dirceuresende]
GO

IF (EXISTS(SELECT NULL FROM sys.database_principals WHERE [name] = 'pedro')) DROP USER [pedro]
GO

CREATE USER [pedro] FOR LOGIN [pedro]
GO

CREATE TABLE dbo.Clientes (
	Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	Nome VARCHAR(50) NOT NULL
)
GO

INSERT INTO dbo.Clientes VALUES('Dirceu Resende')
GO


CREATE TABLE dbo.Alteracao_Objetos (
	Id_Alteracao INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	Dt_Alteracao DATETIME NOT NULL,
	Ds_Objeto_Alterado VARCHAR(50) NOT NULL
)
GO

INSERT INTO dbo.Alteracao_Objetos (Dt_Alteracao, Ds_Objeto_Alterado)
VALUES('2019-04-10 23:54:33', 'stpTeste1'), ('2019-04-10 23:58:31', 'stpTeste2')
GO


USE [CLR]
GO

IF (EXISTS(SELECT NULL FROM sys.database_principals WHERE [name] = 'pedro')) DROP USER [pedro]
GO

CREATE USER [pedro] FOR LOGIN [pedro]
GO


--------------------------------------------------
-- Cria a view vwClientes
--------------------------------------------------

USE [teste]
GO

IF (OBJECT_ID('dbo.vwClientes') IS NOT NULL) DROP VIEW dbo.vwClientes
GO 

CREATE VIEW vwClientes
AS
SELECT *
FROM dirceuresende.dbo.Clientes
GO

GRANT SELECT ON vwClientes TO [pedro]
GO


--------------------------------------------------
-- Tenta acessar a view utilizando o usuário "pedro"
--------------------------------------------------

USE [teste]
GO

SELECT * FROM dbo.vwClientes


--------------------------------------------------
-- utilizando cross db chain para acessar a view (logado como um usuário sysadmin agora)
--------------------------------------------------

USE [teste]
GO

ALTER DATABASE teste SET DB_CHAINING ON
GO

ALTER DATABASE dirceuresende SET DB_CHAINING ON
GO


--------------------------------------------------
-- testa o select novamente com o usuário "pedro"
--------------------------------------------------

USE [teste]
GO

SELECT TOP 100 * FROM dbo.vwClientes
GO

SELECT TOP 100 * FROM dirceuresende.dbo.Clientes
GO

--------------------------------------------------
-- e a brecha de segurança?
-- OBS: essa brecha só funciona quando o owner dos databases envolvidos é o mesmo
--------------------------------------------------

USE [teste]
GO

ALTER ROLE db_ddladmin ADD MEMBER [pedro]
GO

ALTER ROLE db_datareader ADD MEMBER [pedro]
GO

ALTER ROLE db_datawriter ADD MEMBER [pedro]
GO

--------- conecta com o usuário pedro de novo ------------

USE [teste]
GO

IF (OBJECT_ID('dbo.vwTeste1') IS NOT NULL) DROP VIEW dbo.vwTeste1
GO

CREATE VIEW dbo.vwTeste1
AS
SELECT *
FROM dirceuresende.dbo.Alteracao_Objetos
GO


IF (OBJECT_ID('dbo.vwTeste2') IS NOT NULL) DROP VIEW dbo.vwTeste2
GO

CREATE VIEW dbo.vwTeste2
AS
SELECT *
FROM CLR.dbo.Teste
GO


--------- conectado com dirceu.resende ------------

USE [teste]
GO

SELECT TOP 100 * FROM vwTeste1
GO

SELECT TOP 100 * FROM vwTeste2
GO

--------- liberando a nível de instância ------------

USE [master]
GO

ALTER DATABASE [CLR] SET DB_CHAINING ON
GO


--------- consultando os dados da vwTeste2 -----------

USE [teste]
GO

SELECT TOP 100 * FROM dbo.vwTeste2
GO


------------ removendo o cross db ownership --------------

USE [CLR]
GO

ALTER DATABASE [CLR] SET DB_CHAINING OFF
GO

ALTER DATABASE dirceuresende SET DB_CHAINING OFF
GO

ALTER DATABASE teste SET DB_CHAINING OFF
GO


------------ testando os acessos --------------

USE [teste]
GO

SELECT * FROM dbo.vwClientes
GO

SELECT TOP 100 * FROM vwTeste1
GO

SELECT TOP 100 * FROM vwTeste2
GO


------------ liberando a nível de instância --------------

sp_configure 'show advanced options', 1
GO

RECONFIGURE
GO

sp_configure 'cross db ownership chaining', 1
GO

RECONFIGURE
GO



--------- conecta com o usuário pedro de novo ------------

USE [teste]
GO

SELECT * FROM dbo.vwClientes
GO

SELECT TOP 100 * FROM vwTeste1
GO

SELECT TOP 100 * FROM vwTeste2
GO



--------- verifica os bancos que estão com essa propriedade marcada ------------

SELECT [name], is_db_chaining_on 
FROM sys.databases

