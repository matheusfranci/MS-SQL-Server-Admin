USE [dirceuresende]
GO

IF (OBJECT_ID('dbo.stpVerifica_Falha_Conexao') IS NULL) EXEC('CREATE PROCEDURE dbo.stpVerifica_Falha_Conexao AS SELECT 1')
GO

ALTER PROCEDURE dbo.stpVerifica_Falha_Conexao (
    @Fl_Envia_Email BIT = 1,
    @Qt_Tentativas_Para_Alertar INT = 2,
    @Fl_Gera_Arquivo_Firewall BIT = 1,
    @Qt_Tentativas_para_Bloquear INT = 2
)
AS
BEGIN


    SET NOCOUNT ON


    -- DECLARE @Qt_Tentativas_Para_Alertar INT = 100, @Fl_Envia_Email BIT = 1, @Fl_Gera_Arquivo_Firewall BIT = 1, @Qt_Tentativas_para_Bloquear INT = 5

    --------------------------------------------------------------
    -- Cria as tabelas temporárias
    --------------------------------------------------------------

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

    IF (OBJECT_ID('tempdb..#Bloquear_IP') IS NOT NULL) DROP TABLE #Bloquear_IP
    CREATE TABLE #Bloquear_IP (
        Contador INT IDENTITY(1,1) NOT NULL, 
        [IP] NVARCHAR(256),
        Qt_Tentativas INT
    )


    --------------------------------------------------------------
    -- Lista com IP's permitidos que não podem ser bloqueados
    --------------------------------------------------------------

    IF (OBJECT_ID('dbo.Excecoes') IS NULL)
    BEGIN

        -- DROP TABLE dbo.Excecoes
        CREATE TABLE dbo.Excecoes (
            [IP] VARCHAR(15) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL UNIQUE
        ) WITH(DATA_COMPRESSION=PAGE)


        INSERT INTO dbo.Excecoes
        VALUES
            ('192.168.31.108'),
            ('127.0.0.1')


    END


    --------------------------------------------------------------
    -- Histórico das tentativas de conexão
    --------------------------------------------------------------

    IF (OBJECT_ID('dbo.Tentativas_Conexao') IS NULL)
    BEGIN

        -- TRUNCATE TABLE dbo.Tentativas_Conexao
        CREATE TABLE dbo.Tentativas_Conexao (
            [LogDate] DATETIME, 
            [ProcessInfo] NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AI,
            [Username] NVARCHAR(256) COLLATE SQL_Latin1_General_CP1_CI_AI,
            [IP] NVARCHAR(16) COLLATE SQL_Latin1_General_CP1_CI_AI
        ) WITH(DATA_COMPRESSION=PAGE)

        CREATE CLUSTERED INDEX SK01_Tentativas_Conexao ON dbo.Tentativas_Conexao(LogDate) WITH(DATA_COMPRESSION=PAGE, FILLFACTOR=100)

    END



	IF (OBJECT_ID('dbo.Bloqueios_Conexao') IS NULL)
    BEGIN

        -- TRUNCATE TABLE dbo.Bloqueios_Conexao
        CREATE TABLE dbo.Bloqueios_Conexao (
            [LogDate] DATETIME,
            [IP] NVARCHAR(16) COLLATE SQL_Latin1_General_CP1_CI_AI
        ) WITH(DATA_COMPRESSION=PAGE)

        CREATE CLUSTERED INDEX SK01_Bloqueios_Conexao ON dbo.Bloqueios_Conexao(LogDate) WITH(DATA_COMPRESSION=PAGE, FILLFACTOR=100)

    END


    --------------------------------------------------------------
    -- Importa os arquivos do ERRORLOG
    --------------------------------------------------------------

    INSERT INTO #Arquivos_Log
    EXEC sys.sp_enumerrorlogs


    --------------------------------------------------------------
    -- Loop para procurar por falhas de login nos arquivos
    --------------------------------------------------------------

    DECLARE
        @Contador INT = 0,
        @Total INT = (SELECT COUNT(*) FROM #Arquivos_Log),
        @Ultima_Coleta VARCHAR(19) = CONVERT(VARCHAR(19), ISNULL(DATEADD(SECOND, 1, (SELECT MAX(LogDate) FROM dbo.Tentativas_Conexao)), '1900-01-01'), 121),
        @Agora VARCHAR(19) = CONVERT(VARCHAR(19), GETDATE(), 121),
        @IP VARCHAR(20),
        @Query VARCHAR(4000)
    

    WHILE(@Contador < @Total)
    BEGIN
    
        -- Pesquisa por senha incorreta
        INSERT INTO #Login_Failed (LogDate, ProcessInfo, [Text]) 
        EXEC master.dbo.xp_readerrorlog @Contador, 1, N'Password did not match that for the login provided', NULL, @Ultima_Coleta, @Agora

        -- Pesquisa por tentar conectar com usuário que não existe
        INSERT INTO #Login_Failed (LogDate, ProcessInfo, [Text]) 
        EXEC master.dbo.xp_readerrorlog @Contador, 1, N'Could not find a login matching the name provided.', NULL, @Ultima_Coleta, @Agora

        -- Atualiza o número do arquivo de log
        UPDATE #Login_Failed
        SET LogNumber = @Contador
        WHERE LogNumber IS NULL

        SET @Contador += 1
    
    END



    --------------------------------------------------------------
    -- Salva as tentativas realizadas, já excluindo a lista de exceções
    --------------------------------------------------------------

    INSERT INTO ##Tentativas_Conexao
    SELECT
        A.*
    FROM 
        #Login_Failed A
        LEFT JOIN dbo.Excecoes B ON B.[IP] = A.[IP] COLLATE SQL_Latin1_General_CP1_CI_AI
    WHERE
        (B.[IP] IS NULL AND A.[IP] NOT LIKE '%local machine%')
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


    INSERT INTO #Bloquear_IP
    SELECT
        A.[IP],
        COUNT(*) AS Quantidade
    FROM
        ##Tentativas_Conexao A
        LEFT JOIN dbo.Bloqueios_Conexao B ON B.[IP] = A.[IP] COLLATE SQL_Latin1_General_CP1_CI_AI
    WHERE
        B.[IP] IS NULL
    GROUP BY
        A.[IP]
    HAVING
        COUNT(*) >= @Qt_Tentativas_para_Bloquear
    ORDER BY
        2 DESC


    INSERT INTO ##Lista_IPs_Bloquear
    SELECT
        STUFF((
            SELECT 
                ',' + [IP]
            FROM 
                #Bloquear_IP
            ORDER BY 
                [IP]
            FOR XML PATH('')
        ), 1, 1, '') AS listaIps
    


	INSERT INTO dbo.Bloqueios_Conexao(LogDate, [IP])
	SELECT GETDATE(), [IP]
	FROM #Bloquear_IP
		

    --------------------------------------------------------------
    -- Armazena o histórico
    --------------------------------------------------------------

    INSERT INTO dbo.Tentativas_Conexao
    (
        LogDate,
        ProcessInfo,
        Username,
        [IP]
    )
    SELECT 
        LogDate,
        (CASE 
            WHEN [Text] LIKE '%password%' THEN 'Password failed'
            WHEN [Text] LIKE '%Could not find a login matching the name provided%' THEN 'Login does not exists'
        END) AS ProcessInfo,
        Username,
        [IP]
    FROM
        ##Tentativas_Conexao


    
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


        --------------------------------------------------------------
        -- Bloqueia os IP's no Firewall do Windows
        -- https://www.dirceuresende.com/blog/como-instalar-e-configurar-o-microsoft-sql-server-2016-no-windows-server-2016/
        --------------------------------------------------------------

        IF (@Fl_Gera_Arquivo_Firewall = 1)
        BEGIN

            DECLARE @Fl_Xp_CmdShell_Ativado BIT = (SELECT (CASE WHEN CAST([value] AS VARCHAR(MAX)) = '1' THEN 1 ELSE 0 END) FROM sys.configurations WHERE [name] = 'xp_cmdshell')
 
            IF (@Fl_Xp_CmdShell_Ativado = 0)
            BEGIN
 
                EXEC sp_configure 'show advanced options', 1;
                RECONFIGURE WITH OVERRIDE;
    
                EXEC sp_configure 'xp_cmdshell', 1;
                RECONFIGURE WITH OVERRIDE;
    
            END



            SET @Contador = 1
            SET @Total = (SELECT COUNT(*) FROM #Bloquear_IP)
    
            -- Apaga o arquivo
            EXEC master.dbo.xp_cmdshell 'type nul > "C:\Temporario\Firewall.bat"'

            WHILE(@Contador <= @Total)
            BEGIN
        
                SELECT TOP(1) @IP = [IP]
                FROM #Bloquear_IP
                WHERE Contador = @Contador

                SET @Query = 'ECHO netsh advfirewall firewall add rule name="SQL Server - IP Block - ' + @IP + '" dir=in interface=any action=block remoteip=' + @IP + '/32 >> "C:\Temporario\Firewall.bat'
                EXEC master.dbo.xp_cmdshell @Query
                --PRINT @Query

                SET @Contador += 1

            END



            IF (@Fl_Xp_CmdShell_Ativado = 0)
            BEGIN
 
                EXEC sp_configure 'xp_cmdshell', 0;
                RECONFIGURE WITH OVERRIDE;
 
                EXECUTE sp_configure 'show advanced options', 0;
                RECONFIGURE WITH OVERRIDE;
 
            END


        END


    END


END