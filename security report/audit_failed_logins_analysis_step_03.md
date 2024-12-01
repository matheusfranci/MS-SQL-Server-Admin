# Descrição do Script

Este script realiza operações para gerenciar a auditoria de falhas de login e analisar logs de erro no SQL Server.

## 1. Alterar o Nível de Auditoria de Login
Altera o nível de auditoria do login no SQL Server. O valor do parâmetro `AuditLevel` pode ser configurado para registrar:
- Nenhuma auditoria.
- Somente falhas.
- Sucesso ou falha.
  
## 2. Identificar Falhas de Login
Identifica falhas de login no SQL Server, pesquisando os logs de erro e filtrando por mensagens contendo "Login failed".

### 2.1 Identificar Falhas de Login por Senha Incorreta
Filtra falhas de login que envolvem senha incorreta, verificando os logs para a string "Login failed" e "password".

## 3. Analisar Logs de Falhas de Login
Cria uma tabela temporária `#Login_Failed` para armazenar informações sobre falhas de login, como data, hora, processo, texto do erro, nome do usuário e endereço IP. Os dados das falhas de login são extraídos dos logs de erro.

## 4. Analisar Todos os Arquivos de Log de Erro
Cria a tabela temporária `#Arquivos_Log` para armazenar informações sobre os arquivos de log, como número do log, data e hora, e tamanho do log. Em seguida, carrega os dados desses logs usando o procedimento `sp_enumerrorlogs`.

## 5. Loop para Buscar Falhas de Login em Todos os Arquivos de Log
Executa um loop para analisar todos os arquivos de log de erro, procurando por falhas de login devido a senha incorreta e tentativas de login com usuários inexistentes. Os resultados são inseridos na tabela `#Login_Failed`.

## 6. Agrupamento de Resultados
Agrupa as falhas de login por IP e por nome de usuário, retornando a quantidade de falhas para cada um, ordenadas por frequência.

```SQL
-- Como alterar o modo de auditoria via T-SQL
EXEC sys.xp_instance_regwrite
    @rootkey = 'HKEY_LOCAL_MACHINE',
    @key = 'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer',
    @value_name = 'AuditLevel',
    @type = 'REG_DWORD',
    @value = 2 -- 0 = Nenhum / 1 = Apenas sucesso / 2 = Apenas falha / 3 = Sucesso e Falha
```

```SQL
-- Como identificar falhas de login
EXEC master.dbo.xp_readerrorlog 0, 1, N'Login failed'
```

```SQL
-- Como identificar falhas de login por senha incorreta
EXEC master.dbo.xp_readerrorlog 0, 1, N'Login failed', N'password'
```

```SQL
-- Identificando usuário e máquina
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
-- Analisando todos os arquivos do errorlog
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

INSERT INTO #Arquivos_Log
EXEC sys.sp_enumerrorlogs
```

```SQL
--------------------------------------------------------------
-- Loop para procurar por falhas de login nos arquivos
--------------------------------------------------------------

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
```

```SQL
-- Agrupando os resultados
SELECT [IP], COUNT(*) AS Quantidade
FROM #Login_Failed
GROUP BY [IP]
ORDER BY 2 DESC
```

```SQL
SELECT [Username], COUNT(*) AS Quantidade
FROM #Login_Failed
GROUP BY [Username]
ORDER BY 2 DESC
```