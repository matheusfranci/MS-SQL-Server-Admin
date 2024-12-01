## Descrição do Script

Este script realiza a marcação de uma stored procedure para ser executada automaticamente ao iniciar o SQL Server, além de configurar e desabilitar algumas opções relacionadas a esse comportamento.

### 1. **Criação de Tabela de Teste**
   - O script começa criando uma tabela chamada `dbo.Teste` no banco de dados `master`, com duas colunas: `Id` (um identificador único e auto-incremental) e `Dt_Evento` (data e hora do evento).

### 2. **Criação e Alteração da Stored Procedure**
   - Uma stored procedure chamada `dbo.stpTeste` é criada (ou alterada, caso já exista). Esta procedure insere a data e hora atual na tabela `dbo.Teste` sempre que for executada.

### 3. **Marcação da Stored Procedure para Execução ao Iniciar o SQL Server**
   - A stored procedure `dbo.stpTeste` é configurada para ser executada automaticamente sempre que o SQL Server for iniciado. Isso é feito utilizando o comando `sp_procoption` com a opção `startup` configurada como `on`.

### 4. **Verificação das Procedures que São Inicializadas no SQL Server**
   - O script consulta a tabela `sys.procedures` para listar todas as stored procedures que estão configuradas para serem executadas automaticamente durante o início do SQL Server.

### 5. **Desabilitação da Configuração `scan for startup procs`**
   - O script desabilita a configuração de "scan for startup procs" utilizando o procedimento `sp_configure`. Esta configuração, quando ativada, faz com que o SQL Server busque por stored procedures marcadas como `startup` para execução automática. O script desabilita essa configuração para impedir futuras verificações automáticas.

```SQL
-- marca uma stored procedure para ser executada ao iniciar o sql server
USE [master]
GO

-- DROP TABLE dbo.Teste
CREATE TABLE dbo.Teste (
	Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Dt_Evento DATETIME NOT NULL
)

SELECT * FROM dbo.Teste
```

```SQL
CREATE OR ALTER PROCEDURE dbo.stpTeste
AS
BEGIN

	INSERT INTO dbo.Teste
	VALUES(GETDATE())

END
```

```SQL
EXEC sp_procoption 
	@ProcName = 'dbo.stpTeste', 
	@OptionName = 'startup', 
	@OptionValue = 'on'
```

```SQL
-- verificando as procedures que são inicializadas no sql server
SELECT * FROM sys.procedures WHERE is_auto_executed = 1
```

```SQL
-- desabilita a configuração scan for startup procs
USE [master]
GO
EXEC sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO
EXEC sp_configure 'scan for startup procs', 0
GO
RECONFIGURE
GO
```