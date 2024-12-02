# Identificação e Configuração de Tentativas de Login no SQL Server

## Descrição
Este script realiza uma análise detalhada e configurável das tentativas de login no SQL Server, permitindo monitorar falhas de autenticação e ajustar os níveis de auditoria. Ele se divide em várias etapas:

1. **Leitura de Logs de Erro:**
   - Utiliza a `xp_readerrorlog` para identificar tentativas de login com falha no banco de dados.
   - Armazena as informações extraídas em tabelas temporárias, facilitando a análise.

2. **Configuração de Auditoria:**
   - Modifica o nível de auditoria de login no SQL Server por meio da `xp_instance_regwrite`. Os níveis disponíveis incluem:
     - 0: Nenhum.
     - 1: Apenas sucesso.
     - 2: Apenas falha.
     - 3: Sucesso e falha.

3. **Extração Detalhada de Informações:**
   - Analisa os logs de erro para identificar:
     - Logins com senha incorreta.
     - Logins inexistentes.
   - Agrupa e formata os dados para obter informações como nome de usuário e endereço IP.

4. **Agrupamento de Dados:**
   - Realiza agrupamentos por endereço IP e nome de usuário para identificar padrões de falhas.

## Observações
- O script utiliza tabelas temporárias para organizar os dados extraídos dos logs.
- É uma ferramenta eficaz para auditoria de segurança, permitindo rastrear tentativas maliciosas de login e ajustar políticas de autenticação.
- Certifique-se de possuir as permissões apropriadas antes de alterar configurações no registro ou acessar logs.
- Recomendado para ambientes controlados ou testes, evitando alterações diretas em produção sem validação prévia.

```SQL
--------------------------------------------------------------------
-- IDENTIFICAR AS TENTATIVAS DE FALHA DE LOGIN
--------------------------------------------------------------------

EXEC master.dbo.xp_readerrorlog 0, 1, N'Login failed'
```

```SQL
--------------------------------------------------------------------
-- ALTERANDO A CONFIGURAÇÃO DE LOGAR TENTATIVAS DE LOGIN
--------------------------------------------------------------------

EXEC sys.xp_instance_regwrite
    @rootkey = 'HKEY_LOCAL_MACHINE',
    @key = 'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer',
    @value_name = 'AuditLevel',
    @type = 'REG_DWORD',
    @value = 2 -- 0 = Nenhum / 1 = Apenas sucesso / 2 = Apenas falha / 3 = Sucesso e Falha
```

```SQL
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
```




```SQL
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
```

```SQL
-- Importa os arquivos do ERRORLOG
INSERT INTO #Arquivos_Log
EXEC sys.sp_enumerrorlogs
```

```SQL
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
```

```SQL
SELECT * FROM #Login_Failed
```

```SQL
--------------------------------------------------------------------
-- AGRUPANDO OS DADOS
--------------------------------------------------------------------

SELECT [IP], COUNT(*) AS Quantidade
FROM #Login_Failed
GROUP BY [IP]
ORDER BY 2 DESC

select * from 
SELECT [Username], COUNT(*) AS Quantidade
FROM #Login_Failed
GROUP BY [Username]
ORDER BY 2 DESC
```