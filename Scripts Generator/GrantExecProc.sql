SELECT DISTINCT
'GRANT EXECUTE ON OBJECT [' + s.Name + '].[' + o.name + ']
TO suporte_dados
GO'
FROM sys.objects o
INNER JOIN sys.procedures p ON p.object_id = o.object_id
INNER JOIN sys.schemas s ON s.schema_id = o.schema_id
WHERE s.schema_id IN (1, 8);
