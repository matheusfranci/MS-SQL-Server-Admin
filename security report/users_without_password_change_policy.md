### Política de Senha
O primeiro bloco de código descreve as diretrizes para a complexidade de senhas no SQL Server, baseadas nas políticas de segurança. A política exige que as senhas tenham um comprimento mínimo de 8 caracteres e contenham caracteres de pelo menos três das quatro categorias: letras maiúsculas, letras minúsculas, dígitos numéricos e caracteres não alfanuméricos. A senha pode ter até 128 caracteres. O uso de senhas complexas é recomendado para evitar ataques de força bruta.

### Identificar Logins Sem Política de Senha
O segundo bloco de código é uma consulta SQL que identifica logins no SQL Server que não seguem as políticas de senha. Ele verifica se a política de senha (`is_policy_checked`) ou a expiração de senha (`is_expiration_checked`) estão desativadas. A consulta também recupera informações adicionais sobre o login, como contagem de tentativas de senha incorreta, tempo da última alteração de senha e status do login (se está bloqueado, expirado, etc.).

### Criar um Login com Política de Senha Habilitada
Esse script mostra como criar logins com políticas de senha habilitadas. O login "teste3" é criado com a senha '1234567890' sem a exigência de expiração de senha, mas com a política de senha ativada. O segundo login, "teste", é criado com a senha '123I*', que já segue a política de complexidade de senha. O comando `ALTER LOGIN` é utilizado para garantir que a política de senha e a expiração de senha estejam ativadas.

### MUST_CHANGE
Este bloco de código manipula a opção `MUST_CHANGE` para forçar a alteração de senha de um login ao ser criado. Quando um login é criado com a opção `MUST_CHANGE`, a senha precisa ser alterada pelo usuário na primeira vez que ele fizer login. A consulta `SELECT LOGINPROPERTY('teste3','IsMustChange')` retorna o estado da propriedade `MUST_CHANGE` para o login. Em seguida, o login "teste3" tem sua senha alterada e a política de expiração e de complexidade de senha é aplicada novamente.

### LOCK
Este trecho demonstra como verificar o status de bloqueio de um login utilizando a função `LOGINPROPERTY`. A consulta mostra se o login está bloqueado (`IsLocked`), a contagem de senhas incorretas e o tempo da última falha de senha. O login "teste3" tem sua senha alterada e desbloqueada utilizando o comando `ALTER LOGIN ... UNLOCK`, permitindo que o login seja reativado após atingir o limite de tentativas de senha incorretas.

Este conjunto de scripts fornece uma abordagem robusta para gerenciar e aplicar políticas de segurança de senha no SQL Server, garantindo que as senhas sigam diretrizes de complexidade, expirando adequadamente, e permitindo a aplicação de regras de bloqueio e necessidade de alteração de senha.

```sql
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
```   
    
```sql
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
```

```sql
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
```

```sql
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
```