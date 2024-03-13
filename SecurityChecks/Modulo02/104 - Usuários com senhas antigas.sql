
------------------------------------------------
-- USUÁRIOS COM SENHAS ANTIGAS
------------------------------------------------

SELECT 
    [name],
    LOGINPROPERTY([name], 'PasswordLastSetTime') AS PasswordLastSetTime,
    principal_id,
    is_policy_checked,
    is_expiration_checked,
    LOGINPROPERTY([name], 'DaysUntilExpiration') DaysUntilExpiration,
    LOGINPROPERTY([name], 'IsExpired') IsExpired,
    LOGINPROPERTY([name], 'IsLocked') IsLocked,
    LOGINPROPERTY([name], 'IsMustChange') IsMustChange,
    LOGINPROPERTY([name], 'BadPasswordCount') BadPasswordCount,
    LOGINPROPERTY([name], 'BadPasswordTime') BadPasswordTime
FROM
    sys.sql_logins
WHERE
    is_expiration_checked = 0
    AND is_disabled = 0
    AND LOGINPROPERTY([name], 'DaysUntilExpiration') IS NULL
    AND DATEDIFF(DAY, CONVERT(DATETIME, LOGINPROPERTY([name], 'PasswordLastSetTime')), GETDATE()) > 30
ORDER BY
    1
    
    

------------------------------------------------
-- SOLUÇÕES PARA SENHAS ANTIGAS
------------------------------------------------

USE [master]
GO

ALTER LOGIN [dirceu.resende] WITH PASSWORD=N'teste123*'
GO

ALTER LOGIN [dirceu.resende] WITH CHECK_EXPIRATION = ON
GO
