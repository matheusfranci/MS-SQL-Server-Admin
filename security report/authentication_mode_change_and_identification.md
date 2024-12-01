# Descrição do Script: Alteração e Identificação do Modo de Autenticação no SQL Server

## 1. Alterando o Modo de Autenticação Utilizando T-SQL
Este bloco de código altera o modo de autenticação do SQL Server. Utiliza a função `xp_instance_regwrite` para modificar o valor da chave de registro `LoginMode` na máquina local, permitindo a configuração do modo de autenticação. O valor `2` define o modo "Windows and SQL Server Authentication" (Modo Misturado), enquanto o valor `1` é para "Windows Authentication" apenas.

## 2. Identificando o Modo de Autenticação com a Função SERVERPROPERTY
A função `SERVERPROPERTY('IsIntegratedSecurityOnly')` é utilizada para verificar o modo de autenticação atual. O retorno `1` indica "Windows Authentication", e `0` significa que o "Windows and SQL Server Authentication" está habilitado.

## 3. Identificando o Modo de Autenticação pelo Registro do Windows
Esse trecho de código lê a chave de registro `LoginMode` para verificar diretamente o modo de autenticação configurado. O valor lido é armazenado na variável `@AuthenticationMode` e, em seguida, é exibido.

## 4. Identificando o Tipo de Cada Login
O script consulta a tabela `sys.server_principals` para obter informações sobre os logins no SQL Server, filtrando os resultados para excluir os tipos de login `C` (Certificate Mapped Login) e `R` (Server Role). A consulta exibe o nome, tipo e a descrição do tipo de cada login.

```SQL
-- Como alterar o modo de autenticação utilizando T-SQL
USE [master]
GO

EXEC sys.xp_instance_regwrite 
	N'HKEY_LOCAL_MACHINE', 
	N'Software\Microsoft\MSSQLServer\MSSQLServer', 
	N'LoginMode', 
	REG_DWORD, 
	2 -- 1 = Windows Authentication / 2 = Windows and SQL Server Authentication (Mixed Mode)
```

```SQL
-- Como identificar o modo de autenticação pela função SERVERPROPERTY
SELECT
    CASE SERVERPROPERTY('IsIntegratedSecurityOnly')
		WHEN 1 THEN 'Windows Authentication' 
		WHEN 0 THEN 'Windows and SQL Server Authentication' 
	END AS [Authentication Mode]
```

```SQL
-- Como identificar o modo de autenticação pelo Registro do Windows
DECLARE @AuthenticationMode INT

EXEC master.dbo.xp_instance_regread 
	N'HKEY_LOCAL_MACHINE', 
	N'Software\Microsoft\MSSQLServer\MSSQLServer',   
	N'LoginMode',
	@AuthenticationMode OUTPUT  

SELECT @AuthenticationMode
```

```SQL
-- Como identificar o tipo de cada login
SELECT [name], [type], [type_desc]
FROM sys.server_principals
WHERE is_fixed_role = 0
AND [type] NOT IN ('C', 'R') -- CERTIFICATE_MAPPED_LOGIN / SERVER_ROLE
```