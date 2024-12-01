## Descrição do Script

Este script aborda ações relacionadas à configuração e manipulação de conexões de administração remota no SQL Server (DAC - Dedicated Administrator Connection), incluindo a verificação, habilitação e monitoramento dessas conexões, além de impedir logins não autorizados e alterar a quantidade máxima de conexões de usuários.

### 1. **Verificando a Configuração da Conexão DAC**
   - A primeira parte do script verifica se a configuração de `remote admin connections` está desabilitada (valor 0). Em seguida, a consulta nas tabelas `sys.configurations` e `sys.endpoints` retorna a configuração e os pontos finais ativos relacionados a conexões administrativas remotas.

### 2. **Habilitando a Conexão DAC**
   - O script altera a configuração de `remote admin connections` para 1, habilitando a conexão DAC. A execução é seguida pela confirmação com `RECONFIGURE` para aplicar as mudanças.

### 3. **Identificando Sessões Utilizando a Conexão DAC**
   - Após habilitar a DAC, o script realiza uma consulta para identificar as sessões ativas que estão utilizando o ponto de extremidade DAC (identificado por `is_admin_endpoint = 1`), exibindo informações como `session_id`, `connect_time`, `client_net_address`, entre outros.

### 4. **Criando e Ativando uma Trigger para Impedir Logins**
   - Uma trigger chamada `trgAudit_Login` é criada para impedir logins de usuários não autorizados, como o `sa` ou usuários de sistema. Se o login não for permitido, a conexão é interrompida com um `ROLLBACK`, e uma mensagem é exibida.

### 5. **Desabilitando a Trigger Durante a Conexão DAC**
   - Durante a conexão DAC, o script desabilita a trigger de auditoria de logins para permitir que a configuração seja alterada sem ser bloqueada pela trigger.

### 6. **Alterando a Quantidade Máxima de Conexões de Usuários**
   - A configuração de `user connections` é alterada para 0 (zero), o que impede qualquer usuário adicional de se conectar ao servidor. A configuração de `show advanced options` é habilitada para permitir essa alteração.

### 7. **Restaurando a Configuração de Conexões de Usuários**
   - Após as alterações necessárias, a configuração de `user connections` é restaurada para o valor desejado, voltando a permitir a quantidade de conexões usuais.

```SQL
-- Verificando se a configuração está habilitada
EXEC sp_configure 'remote admin connections', 0
RECONFIGURE

SELECT * FROM sys.configurations WHERE [name] = 'remote admin connections'
SELECT * FROM sys.endpoints
```

```SQL
-- Habilitando a conexão DAC
EXEC sp_configure 'remote admin connections', 1
GO

RECONFIGURE
GO
```

```SQL
-- Identificar quem está utilizando a conexão DAC
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
    
    
    -- Não loga conexões de usuários de sistema
    IF (ORIGINAL_LOGIN() IN ('sa', 'AUTORIDADE NT\SISTEMA', 'NT AUTHORITY\SYSTEM') OR ORIGINAL_LOGIN() LIKE '%SQLServerAgent')
        RETURN
        

    PRINT 'Usuário não permitido para logar neste servidor. Favor entrar em contato com a equipe de Banco de Dados'
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
-- Altera a quantidade máxima de usuários para 1
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
-- Conectado utilizando a DAC, volto a configuração para o valor correto
sp_configure N'show advanced options', N'1'
GO

RECONFIGURE
GO

sp_configure N'user connections', 0

RECONFIGURE
GO
```