DECLARE @StartTime DATETIME = GETDATE();
PRINT '---------------------------------------------------------'
PRINT 'Segue caminho do arquivo processado: '
SELECT CNPJ_BASICO INTO empresas_bkp_07 FROM empresas;
DECLARE @Dur INT = DATEDIFF(MINUTE, @StartTime, GETDATE());
PRINT 'Arquivo processado em' + CAST(@Dur AS VARCHAR) + ' minutos';
PRINT '---------------------------------------------------------'
