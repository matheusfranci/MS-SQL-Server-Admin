CREATE TABLE #UsingLS(
LinkedServerName VARCHAR(MAX),
LinkedServerDataSource VARCHAR(MAX),
ObjectName VARCHAR(MAX),
Object_Type VARCHAR(MAX))
INSERT INTO #UsingLS
EXEC sp_MSforeachdb
'Use [?]
SELECT SRV.[name] AS LinkedServerName
	, SRV.[data_source] AS LinkedServerDataSource
	, PRO.[name] AS ObjectName
	, "Stored Procedure" AS ObjectType
FROM sys.servers SRV
	INNER JOIN sys.procedures PRO
		ON (OBJECT_DEFINITION(PRO.[object_id]) LIKE ("%" + SRV.[name] + "%")
			OR OBJECT_DEFINITION(PRO.[object_id]) LIKE ("%" + SRV.[data_source] + "%"))
UNION
SELECT SRV.[name] AS LinkedServerName
	, SRV.[data_source] AS LinkedServerDataSource
	, PRO.[name] AS ObjectName
	, "View" AS ObjectType
FROM sys.servers SRV
	INNER JOIN sys.views PRO
		ON (OBJECT_DEFINITION(PRO.[object_id]) LIKE ("%" + SRV.[name] + "%")
			OR OBJECT_DEFINITION(PRO.[object_id]) LIKE ("%" + SRV.[data_source] + "%"))
UNION
SELECT SRV.[name] AS LinkedServerName
	, SRV.[data_source] AS LinkedServerDataSource
	, PRO.[name] AS ObjectName
	, "Trigger" AS ObjectType
FROM sys.servers SRV
	INNER JOIN sys.triggers PRO
		ON (OBJECT_DEFINITION(PRO.[object_id]) LIKE ("%" + SRV.[name] + "%")
			OR OBJECT_DEFINITION(PRO.[object_id]) LIKE ("%" + SRV.[data_source] + "%"))
UNION
SELECT SRV.[name] AS LinkedServerName
	, SRV.[data_source] AS LinkedServerDataSource
	, PRO.[name] AS ObjectName
	, "Function" AS ObjectType
FROM sys.servers SRV
	INNER JOIN sys.objects PRO
		ON (OBJECT_DEFINITION(PRO.[object_id]) LIKE ("%" + SRV.[name] + "%")
			OR OBJECT_DEFINITION(PRO.[object_id]) LIKE ("%" + SRV.[data_source] + "%"))
WHERE PRO.[type] in ("FN", "IF", "FN", "AF", "FS", "FT");'
SELECT * FROM #UsingLS
DROP TABLE #UsingLS
