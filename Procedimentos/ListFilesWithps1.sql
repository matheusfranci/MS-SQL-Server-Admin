-- Verificar todos os parâmetros do SQL SERVER
EXEC sp_configure 'xp_cmdshell';

-- Verificar parâmetros especifico, nesse caso o xp_cmdshell
EXEC sp_configure 'xp_cmdshell';

-- Ativar o parâmetro
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;

-- Desativar pois é um parâmetro relacionado a segurança
EXEC sp_configure 'xp_cmdshell', 0;
RECONFIGURE;

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

-- Executando a procedure
EXEC dbo.ListFilesInFolder @FolderPath = 'C:\dba';
----------- Não se esqueça------------
-- Desativar pois é um parâmetro relacionado a segurança
EXEC sp_configure 'xp_cmdshell', 0;
RECONFIGURE;
