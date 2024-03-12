CREATE PROCEDURE ##ListFilesInFolder
    @FolderPath NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @cmd NVARCHAR(1000);
    SET @cmd = 'powershell.exe -File "C:\ListFiles.ps1" -FolderPath "' + @FolderPath + '"';

    -- Tabela temporária para armazenar os resultados
    CREATE TABLE #TempResults (OutputLine NVARCHAR(4000));

    -- Inserção dos resultados do comando PowerShell na tabela temporária
    INSERT INTO #TempResults
    EXEC xp_cmdshell @cmd;

SELECT '
DECLARE @StartTime DATETIME = GETDATE();
PRINT "---------------------------------------------------------"
PRINT "Segue caminho do arquivo processado: "
BULK INSERT dbo.HISTORICO_TRABALHADOR_NEW
FROM "['+ OutputLine +']"       
WITH
(
FORMAT="CSV",
FIRSTROW=2,
CODEPAGE = "65001",
FIELDTERMINATOR = "|",
ROWTERMINATOR = "0x0A",
--MAXERRORS = 1000,
KEEPNULLS 
)
GO
DECLARE @Dur INT = DATEDIFF(MINUTE, @StartTime, GETDATE());
PRINT "Arquivo processado em" + CAST(@Dur AS VARCHAR) + " minutos";
PRINT "---------------------------------------------------------"
'
FROM #TempResults
WHERE OutputLine NOT IN ('NULL', 'Name', '---- ', 'OLD')

    DROP TABLE #TempResults;
END;
GO
-- Executando a procedure

EXEC ##ListFilesInFolder @FolderPath = 'G:\AWS';

DROP PROCEDURE ##ListFilesInFolder
