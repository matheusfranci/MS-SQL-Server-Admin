## Descri��o do Script

Este script realiza a marca��o de uma stored procedure para ser executada automaticamente ao iniciar o SQL Server, al�m de configurar e desabilitar algumas op��es relacionadas a esse comportamento.

### 1. **Cria��o de Tabela de Teste**
   - O script come�a criando uma tabela chamada `dbo.Teste` no banco de dados `master`, com duas colunas: `Id` (um identificador �nico e auto-incremental) e `Dt_Evento` (data e hora do evento).

### 2. **Cria��o e Altera��o da Stored Procedure**
   - Uma stored procedure chamada `dbo.stpTeste` � criada (ou alterada, caso j� exista). Esta procedure insere a data e hora atual na tabela `dbo.Teste` sempre que for executada.

### 3. **Marca��o da Stored Procedure para Execu��o ao Iniciar o SQL Server**
   - A stored procedure `dbo.stpTeste` � configurada para ser executada automaticamente sempre que o SQL Server for iniciado. Isso � feito utilizando o comando `sp_procoption` com a op��o `startup` configurada como `on`.

### 4. **Verifica��o das Procedures que S�o Inicializadas no SQL Server**
   - O script consulta a tabela `sys.procedures` para listar todas as stored procedures que est�o configuradas para serem executadas automaticamente durante o in�cio do SQL Server.

### 5. **Desabilita��o da Configura��o `scan for startup procs`**
   - O script desabilita a configura��o de "scan for startup procs" utilizando o procedimento `sp_configure`. Esta configura��o, quando ativada, faz com que o SQL Server busque por stored procedures marcadas como `startup` para execu��o autom�tica. O script desabilita essa configura��o para impedir futuras verifica��es autom�ticas.

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
-- verificando as procedures que s�o inicializadas no sql server
SELECT * FROM sys.procedures WHERE is_auto_executed = 1
```

```SQL
-- desabilita a configura��o scan for startup procs
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