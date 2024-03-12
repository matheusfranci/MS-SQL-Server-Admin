CREATE PROCEDURE ##ListFilesInFolder
AS
BEGIN
    SET NOCOUNT ON;
    -- Tabela temporária para armazenar os resultados
    CREATE TABLE #TempResults (OutputLine NVARCHAR(4000));

    -- Inserção dos resultados do comando PowerShell na tabela temporária
    INSERT INTO #TempResults
    EXEC xp_cmdshell 'powershell.exe -Command "Get-ChildItem -Path \"G:\AWS\" | Select-Object -ExpandProperty Name"'

    SELECT REPLACE('
DECLARE @StartTime DATETIME = GETDATE();
PRINT ''---------------------------------------------------------''
PRINT ''Segue caminho do arquivo processado: G:\AWS\'+ OutputLine +'''
BULK INSERT dbo.HISTORICO_TRABALHADOR_NEW
FROM '''+ OutputLine +'''
WITH
(
FORMAT=''CSV'',
FIRSTROW=2,
CODEPAGE = ''65001'',
FIELDTERMINATOR = ''|'',
ROWTERMINATOR = ''0x0A'',
--MAXERRORS = 1000,
KEEPNULLS 
)
DECLARE @Dur INT = DATEDIFF(MINUTE, @StartTime, GETDATE());
PRINT ''Arquivo processado em'' + CAST(@Dur AS VARCHAR) + '' minutos'';
PRINT ''---------------------------------------------------------''', '"', '''')
    FROM #TempResults
    WHERE OutputLine NOT IN ('NULL', 'Name', '---- ', 'OLD')

    DROP TABLE #TempResults;
END;
GO
-- Executando a procedure

EXEC ##ListFilesInFolder;

DROP PROCEDURE ##ListFilesInFolder
