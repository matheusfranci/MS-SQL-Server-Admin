

-- Verifica se o xp_cmdshell está habilitado
SELECT * FROM sys.configurations WHERE [name] = 'xp_cmdshell'


-- Habilita o xp_cmdshell
EXECUTE sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
EXECUTE sp_configure 'xp_cmdshell', 1
GO
RECONFIGURE
GO


-- Cria um novo usuário para testes
USE [master]
GO
CREATE LOGIN [teste] WITH PASSWORD=N'aaa', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
CREATE USER [teste] FOR LOGIN [teste]
GO
GRANT EXECUTE ON xp_cmdshell TO [teste]
GO

-- Tento executar a xp_cmdshell conectado com o novo usuário (ERRO)
xp_cmdshell 'mkdir C:\Teste'


-- Criando uma credencial para permitir que usuários SQL, sem ser sysadmin, consigam executar o xp_cmdshell
CREATE CREDENTIAL ##xp_cmdshell_proxy_account## 
    WITH IDENTITY = 'DIRCEU-VM\teste', SECRET = 'sdfh%dkc93vcMt0' -- Senha do usuário Windows

GRANT EXECUTE ON xp_cmdshell TO [DIRCEU-VM\teste]


-- Tento executar a xp_cmdshell conectado com o novo usuário (SUCESSO)
xp_cmdshell 'mkdir C:\Teste'



-- Desabilita o xp_cmdshell
EXECUTE sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
EXECUTE sp_configure 'xp_cmdshell', 0
GO
RECONFIGURE
GO



/*

REFERÊNCIAS

https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/xp-cmdshell-transact-sql?view=sql-server-ver15
https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/xp-cmdshell-server-configuration-option?view=sql-server-ver15
https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-xp-cmdshell-proxy-account-transact-sql?view=sql-server-ver15

https://www.mssqltips.com/sqlservertip/2143/creating-a-sql-server-proxy-account-to-run-xpcmdshell/
https://dbamohsin.wordpress.com/2017/02/22/xp_cmdshell_proxy_account-credential-could-not-be-created/

*/
