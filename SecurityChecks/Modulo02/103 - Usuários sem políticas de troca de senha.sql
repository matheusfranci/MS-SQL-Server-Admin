
------------------------------------------------
-- POLÍTICA DE SENHA
------------------------------------------------

-- https://docs.microsoft.com/pt-br/sql/relational-databases/security/password-policy?view=sql-server-ver15

/*

Complexidade de senha

As políticas de complexidade de senha são projetadas para deter ataques de força bruta aumentando o número de possíveis senhas. 

Quando a política de complexidade de senha é imposta, as novas senhas devem atender às seguintes diretrizes:
    - A senha não contém o nome de conta do usuário.
    - A senha tem um comprimento de pelo menos oito caracteres.

A senha contém caracteres de três das quatro categorias seguintes:
    - Letras maiúsculas latinas (A a Z)
    - Letras minúsculas latinas (a a z)
    - 10 dígitos base (0 a 9)
    - Caracteres não alfanuméricos como: ponto de exclamação (!), cifrão ($), sinal numérico (#) ou porcentagem (%).
    
As senhas podem ter até 128 caracteres. Use senhas longas e complexas.

secpol.msc

*/


------------------------------------------------
-- IDENTIFICAR LOGINS SEM POLÍTICA DE SENHA
------------------------------------------------

SELECT
    A.*,
    LOGINPROPERTY(A.[name],'BadPasswordCount') AS [BadPasswordCount],
    LOGINPROPERTY(A.[name],'BadPasswordTime') AS [BadPasswordTime],
    LOGINPROPERTY(A.[name],'DaysUntilExpiration') AS [DaysUntilExpiration],
    LOGINPROPERTY(A.[name],'HistoryLength') AS [HistoryLength],
    LOGINPROPERTY(A.[name],'IsExpired') AS [IsExpired],
    LOGINPROPERTY(A.[name],'IsLocked') AS [IsLocked],
    LOGINPROPERTY(A.[name],'IsMustChange') AS [IsMustChange],
    LOGINPROPERTY(A.[name],'LockoutTime') AS [LockoutTime],
    LOGINPROPERTY(A.[name],'PasswordLastSetTime') AS [PasswordLastSetTime],
    LOGINPROPERTY(A.[name],'PasswordHashAlgorithm') AS [PasswordHashAlgorithm]
FROM 
    sys.sql_logins A
    JOIN sys.server_principals B ON A.[sid] = B.[sid]
WHERE
    A.is_disabled = 0
    AND B.is_fixed_role = 0
    AND (
        A.is_policy_checked = 0 -- Senha complexa
        OR A.is_expiration_checked = 0 -- Senha não expira
    )
    
    

------------------------------------------------
-- CRIAR UM LOGIN COM POLÍTICA DE SENHA HABILITADA
------------------------------------------------

USE [master]
GO


CREATE LOGIN [teste3] WITH PASSWORD = '1234567890', CHECK_EXPIRATION = OFF, CHECK_POLICY = ON, DEFAULT_DATABASE = [master]
GO

CREATE LOGIN [teste] WITH PASSWORD = '123I*', CHECK_EXPIRATION = OFF, CHECK_POLICY = ON, DEFAULT_DATABASE = [master]
GO

ALTER LOGIN [teste] WITH CHECK_POLICY = ON
GO

ALTER LOGIN [teste] WITH CHECK_EXPIRATION = ON
GO


------------------------------------------------
-- MUST_CHANGE
------------------------------------------------

USE [master]
GO

CREATE LOGIN [teste3] WITH PASSWORD=N'a*1' MUST_CHANGE, DEFAULT_DATABASE=[master], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
GO

ALTER LOGIN [teste3] WITH CHECK_EXPIRATION = OFF, CHECK_POLICY = OFF
GO

ALTER LOGIN [teste3] WITH PASSWORD = 'mesmasenha123*'
GO

ALTER LOGIN [teste3] WITH CHECK_EXPIRATION = OFF, CHECK_POLICY = OFF
GO

ALTER LOGIN [teste3] WITH CHECK_EXPIRATION = ON, CHECK_POLICY = ON
GO

SELECT LOGINPROPERTY('teste3','IsMustChange') AS [IsMustChange]
GO

ALTER LOGIN [teste3] WITH PASSWORD = 'mesmasenha123*' MUST_CHANGE, CHECK_EXPIRATION = ON, CHECK_POLICY = ON
GO

SELECT LOGINPROPERTY('teste3','IsMustChange') AS [IsMustChange]



------------------------------------------------
-- LOCK
------------------------------------------------

SELECT 
    LOGINPROPERTY('teste3','IsLocked') AS [IsLocked],
    LOGINPROPERTY('teste3','BadPasswordCount') AS [BadPasswordCount],
    LOGINPROPERTY('teste3','BadPasswordTime') AS [BadPasswordTime]

ALTER LOGIN [teste3] WITH PASSWORD = 'a*1'
GO

ALTER LOGIN [teste3] WITH PASSWORD = 'a*1' UNLOCK
GO

