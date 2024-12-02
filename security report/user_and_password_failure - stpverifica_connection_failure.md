# Descrição do Procedimento Armazenado `dbo.stpVerifica_Falha_Conexao`

Este script cria ou altera um procedimento armazenado chamado `dbo.stpVerifica_Falha_Conexao` que realiza o monitoramento de falhas de login no SQL Server. Ele executa as seguintes ações:

1. **Criação de tabelas temporárias**: São criadas tabelas temporárias para armazenar logs de falhas de login, tentativas de conexão e IPs a serem bloqueados, além de tabelas auxiliares para organizar os dados de tentativas de conexão.

2. **Criação da tabela `dbo.Excecoes`**: Tabela contendo IPs que não devem ser bloqueados, como o IP de loopback (`127.0.0.1`) e outros que o usuário definir.

3. **Criação da tabela `dbo.Tentativas_Conexao`**: Armazena o histórico das tentativas de conexão no banco de dados, com dados como data da tentativa, processo, usuário e IP. Um índice clustered é criado para melhorar o desempenho das consultas.

4. **Leitura de arquivos de erro do SQL Server**: A partir da execução do comando `sp_enumerrorlogs`, o script importa os arquivos de log do SQL Server e verifica falhas de login.

5. **Processamento dos logs de erro**: O script busca por falhas de login e erros comuns (como senha incorreta ou login inexistente) e insere essas informações em tabelas temporárias.

6. **Armazenamento de tentativas de conexão**: Insere dados filtrados de falhas de login, ignorando exceções, em tabelas para registrar as tentativas realizadas, as tentativas por IP e por usuário.

7. **Bloqueio de IPs**: Determina quais IPs devem ser bloqueados após um número configurável de tentativas de login falhas, armazenando esses IPs em uma tabela para bloquear no firewall.

8. **Envio de alertas por e-mail**: Se o número de tentativas de conexão falhas atingir um limite pré-estabelecido, um e-mail é enviado com um resumo das tentativas de conexão, agrupadas por IP, por usuário e uma lista dos IPs que precisam ser bloqueados.

9. **Bloqueio de IPs no firewall**: Caso o parâmetro `@Fl_Gera_Arquivo_Firewall` seja ativado, o script gera um arquivo de comandos `batch` para bloquear os IPs no firewall do Windows, utilizando o comando `netsh`.

10. **Configuração do comando `xp_cmdshell`**: Antes de bloquear IPs no firewall, o script verifica se a opção `xp_cmdshell` está ativada e a ativa temporariamente, se necessário. Após a execução, desativa a opção para garantir a segurança do servidor.

O procedimento é configurável por parâmetros como o envio de e-mail, a quantidade de tentativas para alertar e a quantidade de tentativas para bloquear, oferecendo flexibilidade para diferentes cenários de segurança.

```sql
USE [db]
GO

IF (OBJECT_ID('dbo.stpVerifica_Falha_Conexao') IS NULL) EXEC('CREATE PROCEDURE dbo.stpVerifica_Falha_Conexao AS SELECT 1')
GO

ALTER PROCEDURE dbo.stpVerifica_Falha_Conexao (
    @Fl_Envia_Email BIT = 1,
    @Qt_Tentativas_Para_Alertar INT = 100,
    @Fl_Gera_Arquivo_Firewall BIT = 1,
    @Qt_Tentativas_para_Bloquear INT = 5
)
AS
BEGIN


    SET NOCOUNT ON


    -- DECLARE @Qt_Tentativas_Para_Alertar INT = 100, @Fl_Envia_Email BIT = 1, @Fl_Gera_Arquivo_Firewall BIT = 1, @Qt_Tentativas_para_Bloquear INT = 5
```
```sql
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
        [Username] AS LTRIM(RTRIM(REPLACE(REPLACE(SUBSTRING(REPLACE([Text], 'Login failed for user ''', ''), 1, CHARINDEX('. Reason', REPLACE([Text], 'Login failed for user ''', '')) - 2), CHAR(10), ''), CHAR(13), ''))),
        [IP] AS LTRIM(RTRIM(REPLACE(REPLACE(REPLACE((SUBSTRING([Text], CHARINDEX('[CLIENT ', [Text]) + 9, LEN([Text]))), ']', ''), CHAR(10), ''), CHAR(13), '')))
    )

    IF (OBJECT_ID('tempdb..##Tentativas_Conexao') IS NOT NULL) DROP TABLE ##Tentativas_Conexao
    CREATE TABLE ##Tentativas_Conexao ( 
        [LogNumber] TINYINT, 
        [LogDate] DATETIME, 
        [ProcessInfo] NVARCHAR(50), 
        [Text] NVARCHAR(MAX),
        [Username] NVARCHAR(256),
        [IP] NVARCHAR(50)
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
```
```sql
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

```
```sql
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
            [IP] NVARCHAR(50) COLLATE SQL_Latin1_General_CP1_CI_AI
        ) WITH(DATA_COMPRESSION=PAGE)

        CREATE CLUSTERED INDEX SK01_Tentativas_Conexao ON dbo.Tentativas_Conexao(LogDate) WITH(DATA_COMPRESSION=PAGE, FILLFACTOR=100)

    END

```
```sql
    --------------------------------------------------------------
    -- Importa os arquivos do ERRORLOG
    --------------------------------------------------------------

    INSERT INTO #Arquivos_Log
    EXEC sys.sp_enumerrorlogs

``````
```sql
    --------------------------------------------------------------
    -- Loop para procurar por falhas de login nos arquivos
    --------------------------------------------------------------

    DECLARE
        @Contador INT = 0,
        @Total INT = (SELECT COUNT() FROM #Arquivos_Log),
        @Ultima_Coleta VARCHAR(19) = CONVERT(VARCHAR(19), ISNULL(DATEADD(SECOND, 1, (SELECT MAX(LogDate) FROM dbo.Tentativas_Conexao)), '1900-01-01'), 121),
        @Agora VARCHAR(19) = CONVERT(VARCHAR(19), GETDATE(), 121),
        @IP VARCHAR(20),
        @Query VARCHAR(4000)
    

    WHILE(@Contador  @Total)
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

```
```sql
    --------------------------------------------------------------
    -- Salva as tentativas realizadas, já excluindo a lista de exceções
    --------------------------------------------------------------

    INSERT INTO ##Tentativas_Conexao
    SELECT
        A.
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
        COUNT() AS Quantidade
    FROM
        ##Tentativas_Conexao
    GROUP BY
        [IP]
    ORDER BY
        2 DESC


    INSERT INTO ##Tentativas_Conexao_Por_Usuario
    SELECT
        [Username],
        COUNT() AS Quantidade
    FROM
        ##Tentativas_Conexao
    GROUP BY
        [Username]
    ORDER BY
        2 DESC


    INSERT INTO #Bloquear_IP
    SELECT
        A.[IP],
        COUNT() AS Quantidade
    FROM
        ##Tentativas_Conexao A
        LEFT JOIN dbo.Tentativas_Conexao B ON B.[IP] = A.[IP] COLLATE SQL_Latin1_General_CP1_CI_AI
    WHERE
        B.[IP] IS NULL
    GROUP BY
        A.[IP]
    HAVING
        COUNT() = @Qt_Tentativas_para_Bloquear
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
    
```

```sql 
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


    
    IF ((SELECT COUNT() FROM ##Tentativas_Conexao)  0)
    BEGIN
    

        IF (@Fl_Envia_Email = 1 AND (SELECT COUNT() FROM ##Tentativas_Conexao)  @Qt_Tentativas_Para_Alertar)
        BEGIN

        
            DECLARE
                @Assunto VARCHAR(200) = '[' + @@SERVERNAME + '] - Tentativas de conexão sem sucesso',
                @Mensagem VARCHAR(MAX) = 'Olá,<br/>Seguem logs de tentativas de conexão sem sucesso na instância ' + @@SERVERNAME + '',
                @HTML VARCHAR(MAX)

            --------------------------------------------------------------
            -- Gera o código HTML para enviar por e-mail
            -- httpswww.db.comblogcomo-exportar-dados-de-uma-tabela-do-sql-server-para-html
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
```

```sql
    
            EXEC msdb.dbo.sp_send_dbmail
                @profile_name = 'ProfileEnvioEmail',
                @recipients = 'email@gmail.com',
                @subject = @Assunto,
                @body = @Mensagem,
                @body_format = 'html'


        END
```

```sql
        --------------------------------------------------------------
        -- Bloqueia os IP's no Firewall do Windows
        -- https://www.db.com/blog/como-instalar-e-configurar-o-microsoft-sql-server-2016-no-windows-server-2016
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
            SET @Total = (SELECT COUNT() FROM #Bloquear_IP)
    
            -- Apaga o arquivo
            EXEC master.dbo.xp_cmdshell 'type nul > C:\Temporario\Firewall.bat'

            WHILE(@Contador = @Total)
            BEGIN
        
                SELECT TOP(1) @IP = [IP]
                FROM #Bloquear_IP
                WHERE Contador = @Contador

                SET @Query = 'ECHO netsh advfirewall firewall add rule name=SQL Server - IP Block - ' + @IP + ' dir=in interface=any action=block remoteip=' + @IP + '32  C:\Temporario\Firewall.bat'
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
```