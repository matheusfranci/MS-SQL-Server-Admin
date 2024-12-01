## Objetivo
Este script realiza as seguintes ações:
1. Verifica todos os parâmetros de configuração do SQL Server e seu status (habilitado/desabilitado).
2. Habilita e desabilita o parâmetro **`xp_cmdshell`** de forma controlada, devido a suas implicações de segurança.
3. Cria e executa uma procedure armazenada para listar arquivos em uma pasta específica no servidor, utilizando um script PowerShell.

## Entrada esperada
- Nome do parâmetro a ser verificado, como **`xp_cmdshell`**.
- Caminho da pasta para listar os arquivos ao executar a procedure armazenada.

## Saída esperada
- Status dos parâmetros configuráveis do SQL Server.
- Listagem de arquivos no diretório especificado ao executar a procedure.

## Observações adicionais
- **Atenção**: O parâmetro **`xp_cmdshell`** é considerado um risco de segurança e deve ser desabilitado imediatamente após seu uso.
- Certifique-se de que o script PowerShell **`ListFiles.ps1`** esteja localizado no diretório configurado no script.
- A procedure armazenada **`dbo.ListFilesInFolder`** depende da habilitação temporária de **`xp_cmdshell`** para executar comandos PowerShell.

## Localização do script
- Certifique-se de ajustar os caminhos e permissões necessários para o funcionamento correto do script.
- Habilite o parâmetro **`xp_cmdshell`** somente quando necessário, seguindo boas práticas de segurança.

```SQL
-- Verificar todos os parâmetros do SQL SERVER
SELECT 
NAME AS "Parâmetro",
Description AS "Descrição",
CASE
WHEN value_in_use = 1 THEN 'Habilitado'
WHEN value_in_use = 0 THEN 'Desabilitado'
ELSE NULL
END AS 'Status'
FROM sys.configurations
```

```SQL
-- Verificar parâmetros especifico, nesse caso o xp_cmdshell
SELECT 
NAME AS "Parâmetro",
Description AS "Descrição",
CASE
WHEN value_in_use = 1 THEN 'Habilitado'
WHEN value_in_use = 0 THEN 'Desabilitado'
ELSE NULL
END AS 'Status'
FROM sys.configurations
WHERE NAME = 'xp_cmdshell'
```

```SQL
-- Ativar o parâmetro
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;
```

```SQL
-- Desativar pois é um parâmetro relacionado a segurança
EXEC sp_configure 'xp_cmdshell', 0;
RECONFIGURE;
```

```SQL
-- Criando o ListFiles.ps1 no servidor
param (
    [string]$FolderPath
)

# Lista os arquivos na pasta
Get-ChildItem $FolderPath | Select-Object Name
```

```SQL
-- Criando a procedure
CREATE PROCEDURE dbo.ListFilesInFolder
    @FolderPath NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @cmd NVARCHAR(1000);
    SET @cmd = 'powershell.exe -File "C:\dba\ListFiles.ps1" -FolderPath "' + @FolderPath + '"';

    -- Tabela temporária para armazenar os resultados
    CREATE TABLE #TempResults (OutputLine NVARCHAR(4000));

    -- Inserção dos resultados do comando PowerShell na tabela temporária
    INSERT INTO #TempResults
    EXEC xp_cmdshell @cmd;

    -- Seleção dos resultados sem valores nulos
    SELECT OutputLine 
    FROM #TempResults 
    WHERE OutputLine IS NOT NULL 
	AND OutputLine NOT IN ('Name', '----')
    AND OutputLine <> '';

    -- Limpeza da tabela temporária
    DROP TABLE #TempResults;
END;
```

```SQL
-- Executando a procedure
EXEC dbo.ListFilesInFolder @FolderPath = 'C:\dba';
----------- Não se esqueça------------
-- Desativar pois é um parâmetro relacionado a segurança
EXEC sp_configure 'xp_cmdshell', 0;
RECONFIGURE;
```