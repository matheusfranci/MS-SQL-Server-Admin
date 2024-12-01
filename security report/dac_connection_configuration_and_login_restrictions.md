## Descri��o do Script

Este script aborda a��es relacionadas � configura��o e manipula��o de conex�es de administra��o remota no SQL Server (DAC - Dedicated Administrator Connection), incluindo a verifica��o, habilita��o e monitoramento dessas conex�es, al�m de impedir logins n�o autorizados e alterar a quantidade m�xima de conex�es de usu�rios.

### 1. **Verificando a Configura��o da Conex�o DAC**
   - A primeira parte do script verifica se a configura��o de `remote admin connections` est� desabilitada (valor 0). Em seguida, a consulta nas tabelas `sys.configurations` e `sys.endpoints` retorna a configura��o e os pontos finais ativos relacionados a conex�es administrativas remotas.

### 2. **Habilitando a Conex�o DAC**
   - O script altera a configura��o de `remote admin connections` para 1, habilitando a conex�o DAC. A execu��o � seguida pela confirma��o com `RECONFIGURE` para aplicar as mudan�as.

### 3. **Identificando Sess�es Utilizando a Conex�o DAC**
   - Ap�s habilitar a DAC, o script realiza uma consulta para identificar as sess�es ativas que est�o utilizando o ponto de extremidade DAC (identificado por `is_admin_endpoint = 1`), exibindo informa��es como `session_id`, `connect_time`, `client_net_address`, entre outros.

### 4. **Criando e Ativando uma Trigger para Impedir Logins**
   - Uma trigger chamada `trgAudit_Login` � criada para impedir logins de usu�rios n�o autorizados, como o `sa` ou usu�rios de sistema. Se o login n�o for permitido, a conex�o � interrompida com um `ROLLBACK`, e uma mensagem � exibida.

### 5. **Desabilitando a Trigger Durante a Conex�o DAC**
   - Durante a conex�o DAC, o script desabilita a trigger de auditoria de logins para permitir que a configura��o seja alterada sem ser bloqueada pela trigger.

### 6. **Alterando a Quantidade M�xima de Conex�es de Usu�rios**
   - A configura��o de `user connections` � alterada para 0 (zero), o que impede qualquer usu�rio adicional de se conectar ao servidor. A configura��o de `show advanced options` � habilitada para permitir essa altera��o.

### 7. **Restaurando a Configura��o de Conex�es de Usu�rios**
   - Ap�s as altera��es necess�rias, a configura��o de `user connections` � restaurada para o valor desejado, voltando a permitir a quantidade de conex�es usuais.

```SQL
-- Verificando se a configura��o est� habilitada
EXEC sp_configure 'remote admin connections', 0
RECONFIGURE

SELECT * FROM sys.configurations WHERE [name] = 'remote admin connections'
SELECT * FROM sys.endpoints
```

```SQL
-- Habilitando a conex�o DAC
EXEC sp_configure 'remote admin connections', 1
GO

RECONFIGURE
GO
```

```SQL
-- Identificar quem est� utilizando a conex�o DAC
SELECT
    B.session_id,
    A.[name],
    B.connect_time,
    B.last_read,
    B.last_write,
    B.client_net_address
FROM
    sys.endpoints A
    JOIN sys.dm_exec_connections B ON A.endpoint_id = B.endpoint_id
WHERE
    A.is_admin_endpoint = 1
```

```SQL
-- Criar uma trigger para impedir logins
USE [master]
GO

IF ((SELECT COUNT(*) FROM sys.server_triggers WHERE name = 'trgAudit_Login') > 0) DROP TRIGGER [trgAudit_Login] ON ALL SERVER
GO

CREATE OR ALTER TRIGGER [trgAudit_Login] ON ALL SERVER 
FOR LOGON 
AS
BEGIN


    SET NOCOUNT ON
    
    
    -- N�o loga conex�es de usu�rios de sistema
    IF (ORIGINAL_LOGIN() IN ('sa', 'AUTORIDADE NT\SISTEMA', 'NT AUTHORITY\SYSTEM') OR ORIGINAL_LOGIN() LIKE '%SQLServerAgent')
        RETURN
        

    PRINT 'Usu�rio n�o permitido para logar neste servidor. Favor entrar em contato com a equipe de Banco de Dados'
    ROLLBACK


END
GO

ENABLE TRIGGER [trgAudit_Login] ON ALL SERVER  
GO
```

```SQL
-- Conectado via DAC, Desativa a trigger
DISABLE TRIGGER [trgAudit_Login] ON ALL SERVER  
GO
```

```SQL
-- Altera a quantidade m�xima de usu�rios para 1
sp_configure N'show advanced options', N'1'
GO

RECONFIGURE
GO

sp_configure N'user connections', 0

SELECT * FROM sys.configurations WHERE name = 'user connections'

RECONFIGURE
GO
```

```SQL
-- Conectado utilizando a DAC, volto a configura��o para o valor correto
sp_configure N'show advanced options', N'1'
GO

RECONFIGURE
GO

sp_configure N'user connections', 0

RECONFIGURE
GO
```