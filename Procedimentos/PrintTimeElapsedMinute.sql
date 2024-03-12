DECLARE @StartTime DATETIME = GETDATE();
PRINT '---------------------------------------------------------'
SELECT CNPJ_BASICO INTO empresas_bkp_07 FROM empresas;
DECLARE @Dur INT = DATEDIFF(MINUTE, @StartTime, GETDATE());
PRINT 'é essa a tabela'
PRINT 'Elapsed: ' + CAST(@Dur AS VARCHAR) + ' minutes';
PRINT '---------------------------------------------------------'
