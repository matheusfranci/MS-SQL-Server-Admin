
--------------------------------------------------------------------
-- IDENTIFICAR AS TENTATIVAS DE FALHA DE LOGIN
--------------------------------------------------------------------

EXEC master.dbo.xp_readerrorlog 0, 1, N'Login failed'


--------------------------------------------------------------------
-- ALTERANDO A CONFIGURAÇÃO DE LOGAR TENTATIVAS DE LOGIN
--------------------------------------------------------------------

EXEC sys.xp_instance_regwrite
    @rootkey = 'HKEY_LOCAL_MACHINE',
    @key = 'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer',
    @value_name = 'AuditLevel',
    @type = 'REG_DWORD',
    @value = 2 -- 0 = Nenhum / 1 = Apenas sucesso / 2 = Apenas falha / 3 = Sucesso e Falha


--------------------------------------------------------------------
-- IDENTIFICAR AS TENTATIVAS DE FALHA DE LOGIN
--------------------------------------------------------------------

IF (OBJECT_ID('tempdb..#Login_Failed') IS NOT NULL) DROP TABLE #Login_Failed
CREATE TABLE #Login_Failed ( 
    [LogDate] DATETIME, 
    [ProcessInfo] NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AI, 
    [Text] NVARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CI_AI,
    [Username] AS LTRIM(RTRIM(REPLACE(REPLACE(SUBSTRING(REPLACE([Text], 'Login failed for user ''', ''), 1, CHARINDEX('. Reason:', REPLACE([Text], 'Login failed for user ''', '')) - 2), CHAR(10), ''), CHAR(13), ''))),
    [IP] AS LTRIM(RTRIM(REPLACE(REPLACE(REPLACE((SUBSTRING([Text], CHARINDEX('[CLIENT: ', [Text]) + 9, LEN([Text]))), ']', ''), CHAR(10), ''), CHAR(13), '')))
)

INSERT INTO #Login_Failed (LogDate, ProcessInfo, [Text]) 
EXEC master.dbo.xp_readerrorlog 0, 1, N'Login failed'

SELECT * FROM #Login_Failed





--------------------------------------------------------------------
-- IDENTIFICAR AS TENTATIVAS DE FALHA DE LOGIN COM USUÁRIO E SENHA
--------------------------------------------------------------------

IF (OBJECT_ID('tempdb..#Arquivos_Log') IS NOT NULL) DROP TABLE #Arquivos_Log
CREATE TABLE #Arquivos_Log ( 
    [idLog] INT, 
    [dtLog] NVARCHAR(30) COLLATE SQL_Latin1_General_CP1_CI_AI, 
    [tamanhoLog] INT 
)

IF (OBJECT_ID('tempdb..#Login_Failed') IS NOT NULL) DROP TABLE #Login_Failed
CREATE TABLE #Login_Failed (
    [LogNumber] TINYINT,
    [LogDate] DATETIME, 
    [ProcessInfo] NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AI, 
    [Text] NVARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CI_AI,
    [Username] AS LTRIM(RTRIM(REPLACE(REPLACE(SUBSTRING(REPLACE([Text], 'Login failed for user ''', ''), 1, CHARINDEX('. Reason:', REPLACE([Text], 'Login failed for user ''', '')) - 2), CHAR(10), ''), CHAR(13), ''))),
    [IP] AS LTRIM(RTRIM(REPLACE(REPLACE(REPLACE((SUBSTRING([Text], CHARINDEX('[CLIENT: ', [Text]) + 9, LEN([Text]))), ']', ''), CHAR(10), ''), CHAR(13), '')))
)

-- Importa os arquivos do ERRORLOG
INSERT INTO #Arquivos_Log
EXEC sys.sp_enumerrorlogs


-- Loop para procurar por falhas de login nos arquivos
DECLARE
    @Contador INT = 0,
    @Total INT = (SELECT COUNT(*) FROM #Arquivos_Log)
    

WHILE(@Contador < @Total)
BEGIN
    
    -- Pesquisa por senha incorreta
    INSERT INTO #Login_Failed (LogDate, ProcessInfo, [Text]) 
    EXEC master.dbo.sp_readerrorlog @Contador, 1, N'Password did not match that for the login provided'

    -- Pesquisa por tentar conectar com usuário que não existe
    INSERT INTO #Login_Failed (LogDate, ProcessInfo, [Text]) 
    EXEC master.dbo.sp_readerrorlog @Contador, 1, N'Could not find a login matching the name provided.'

    -- Atualiza o número do arquivo de log
    UPDATE #Login_Failed
    SET LogNumber = @Contador
    WHERE LogNumber IS NULL

    SET @Contador += 1
    
END


SELECT * FROM #Login_Failed


--------------------------------------------------------------------
-- AGRUPANDO OS DADOS
--------------------------------------------------------------------

SELECT [IP], COUNT(*) AS Quantidade
FROM #Login_Failed
GROUP BY [IP]
ORDER BY 2 DESC
 
SELECT [Username], COUNT(*) AS Quantidade
FROM #Login_Failed
GROUP BY [Username]
ORDER BY 2 DESC




--------------------------------------------------------------------
-- MONITORANDO POR E-MAIL
--------------------------------------------------------------------

-- Configurações
DECLARE 
    @Qt_Tentativas_Para_Alertar INT = 10, 
    @Fl_Envia_Email BIT = 1    


-- Cria as tabelas temporárias
IF (OBJECT_ID('tempdb..#Arquivos_Log') IS NOT NULL) DROP TABLE #Arquivos_Log
CREATE TABLE #Arquivos_Log ( 
    [idLog] INT, 
    [dtLog] NVARCHAR(30) COLLATE SQL_Latin1_General_CP1_CI_AI, 
    [tamanhoLog] INT 
)

IF (OBJECT_ID('tempdb..#Login_Failed') IS NOT NULL) DROP TABLE #Login_Failed
CREATE TABLE #Login_Failed (
    [LogNumber] TINYINT,
    [LogDate] DATETIME, 
    [ProcessInfo] NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AI, 
    [Text] NVARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CI_AI,
    [Username] AS LTRIM(RTRIM(REPLACE(REPLACE(SUBSTRING(REPLACE([Text], 'Login failed for user ''', ''), 1, CHARINDEX('. Reason:', REPLACE([Text], 'Login failed for user ''', '')) - 2), CHAR(10), ''), CHAR(13), ''))),
    [IP] AS LTRIM(RTRIM(REPLACE(REPLACE(REPLACE((SUBSTRING([Text], CHARINDEX('[CLIENT: ', [Text]) + 9, LEN([Text]))), ']', ''), CHAR(10), ''), CHAR(13), '')))
)

IF (OBJECT_ID('tempdb..##Tentativas_Conexao') IS NOT NULL) DROP TABLE ##Tentativas_Conexao
CREATE TABLE ##Tentativas_Conexao ( 
    [LogNumber] TINYINT, 
    [LogDate] DATETIME, 
    [ProcessInfo] NVARCHAR(50), 
    [Text] NVARCHAR(MAX),
    [Username] NVARCHAR(256),
    [IP] NVARCHAR(16)
)

IF (OBJECT_ID('tempdb..##Tentativas_Conexao_Por_IP') IS NOT NULL) DROP TABLE ##Tentativas_Conexao_Por_IP
CREATE TABLE ##Tentativas_Conexao_Por_IP ( 
    [IP] NVARCHAR(256),
    Qt_Tentativas INT
)

IF (OBJECT_ID('tempdb..##Tentativas_Conexao_Por_Usuario') IS NOT NULL) DROP TABLE ##Tentativas_Conexao_Por_Usuario
CREATE TABLE ##Tentativas_Conexao_Por_Usuario ( 
    [Username] NVARCHAR(256),
    Qt_Tentativas INT
)

IF (OBJECT_ID('tempdb..##Lista_IPs_Bloquear') IS NOT NULL) DROP TABLE ##Lista_IPs_Bloquear
CREATE TABLE ##Lista_IPs_Bloquear ( 
    [Lista_IPs] VARCHAR(MAX)
)


-- Importa os arquivos do ERRORLOG
INSERT INTO #Arquivos_Log
EXEC sys.sp_enumerrorlogs


-- Loop para procurar por falhas de login nos arquivos
DECLARE
    @Contador INT = 0,
    @Total INT = (SELECT COUNT(*) FROM #Arquivos_Log),
    @Ultima_Hora VARCHAR(19) = FORMAT(DATEADD(HOUR, -1, GETDATE()), 'yyyy-MM-dd HH:mm:00'),
    @Agora VARCHAR(19) = CONVERT(VARCHAR(19), GETDATE(), 121)
    

WHILE(@Contador < @Total)
BEGIN
    
    -- Pesquisa por senha incorreta
    INSERT INTO #Login_Failed (LogDate, ProcessInfo, [Text]) 
    EXEC master.dbo.xp_readerrorlog @Contador, 1, N'Password did not match that for the login provided', NULL, @Ultima_Hora, @Agora

    -- Pesquisa por tentar conectar com usuário que não existe
    INSERT INTO #Login_Failed (LogDate, ProcessInfo, [Text]) 
    EXEC master.dbo.xp_readerrorlog @Contador, 1, N'Could not find a login matching the name provided.', NULL, @Ultima_Hora, @Agora

    -- Atualiza o número do arquivo de log
    UPDATE #Login_Failed
    SET LogNumber = @Contador
    WHERE LogNumber IS NULL

    SET @Contador += 1
    
END


-- Salva as tentativas realizadas, já excluindo a lista de exceções
INSERT INTO ##Tentativas_Conexao
SELECT
    A.*
FROM 
    #Login_Failed A
WHERE
    A.[IP] NOT LIKE '%local machine%'
ORDER BY
    A.LogDate

    
INSERT INTO ##Tentativas_Conexao_Por_IP
SELECT
    [IP],
    COUNT(*) AS Quantidade
FROM
    ##Tentativas_Conexao
GROUP BY
    [IP]
ORDER BY
    2 DESC


INSERT INTO ##Tentativas_Conexao_Por_Usuario
SELECT
    [Username],
    COUNT(*) AS Quantidade
FROM
    ##Tentativas_Conexao
GROUP BY
    [Username]
ORDER BY
    2 DESC


INSERT INTO ##Lista_IPs_Bloquear
SELECT
    STUFF((
        SELECT 
            ',' + [IP]
        FROM 
            ##Tentativas_Conexao_Por_IP
        ORDER BY 
            [IP]
        FOR XML PATH('')
    ), 1, 1, '') AS listaIps
    
    
IF ((SELECT COUNT(*) FROM ##Tentativas_Conexao) > 0)
BEGIN
    

    IF (@Fl_Envia_Email = 1 AND (SELECT COUNT(*) FROM ##Tentativas_Conexao) > @Qt_Tentativas_Para_Alertar)
    BEGIN

        
        DECLARE
            @Assunto VARCHAR(200) = '[' + @@SERVERNAME + '] - Tentativas de conexão sem sucesso',
            @Mensagem VARCHAR(MAX) = 'Olá,<br/>Seguem logs de tentativas de conexão sem sucesso na instância ' + @@SERVERNAME + ':',
            @HTML VARCHAR(MAX)

        --------------------------------------------------------------
        -- Gera o código HTML para enviar por e-mail
        -- https://www.dirceuresende.com/blog/como-exportar-dados-de-uma-tabela-do-sql-server-para-html/
        --------------------------------------------------------------
    
        EXEC dbo.stpExporta_Tabela_HTML_Output
            @Ds_Tabela = '##Tentativas_Conexao', -- varchar(max)
            @Ds_Saida = @HTML OUT -- varchar(max)

        SET @Mensagem += '<br/><br/><h2>Histórico do Log</h2>' + @HTML


        EXEC dbo.stpExporta_Tabela_HTML_Output
            @Ds_Tabela = '##Tentativas_Conexao_Por_IP', -- varchar(max)
            @Ds_Saida = @HTML OUT -- varchar(max)

        SET @Mensagem += '<br/><br/><h2>Acessos por IP</h2>' + @HTML


        EXEC dbo.stpExporta_Tabela_HTML_Output
            @Ds_Tabela = '##Tentativas_Conexao_Por_Usuario', -- varchar(max)
            @Ds_Saida = @HTML OUT -- varchar(max)

        SET @Mensagem += '<br/><br/><h2>Acessos por Usuário</h2>' + @HTML


        EXEC dbo.stpExporta_Tabela_HTML_Output
            @Ds_Tabela = '##Lista_IPs_Bloquear', -- varchar(max)
            @Ds_Saida = @HTML OUT -- varchar(max)

        SET @Mensagem += '<br/><br/><h2>Lista de IPs para Bloquear</h2>' + @HTML


        --------------------------------------------------------------
        -- Envia o e-mail
        -- https://www.dirceuresende.com/blog/como-habilitar-enviar-monitorar-emails-pelo-sql-server-sp_send_dbmail/
        --------------------------------------------------------------
    
        EXEC msdb.dbo.sp_send_dbmail
            @profile_name = 'Profile DirceuResende',
            @recipients = 'email@gmail.com',
            @subject = @Assunto,
            @body = @Mensagem,
            @body_format = 'html'


    END


END