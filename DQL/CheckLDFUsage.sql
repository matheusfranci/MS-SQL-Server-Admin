-- Esta métrica mede a porcentagem de espaço usado para arquivos de log de transações (arquivos LDF).
DECLARE	@result TABLE
	(
	  [Database_Name] VARCHAR(150) ,
	  [Log_Size] FLOAT ,
	  [Log_Space] FLOAT ,
	  [Status] VARCHAR(100)
	) 
 
INSERT	INTO @result
		EXEC ( 'DBCC sqlperf(LOGSPACE) WITH NO_INFOMSGS'
			)
 
-- only return for the DB in context, rounding it 
SELECT	ROUND([Log_Space], 2)
FROM	@result
WHERE	[Database_Name] = DB_NAME()
