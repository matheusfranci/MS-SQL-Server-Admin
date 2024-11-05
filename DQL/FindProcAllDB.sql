CREATE TABLE #ProcSearchResults (
    DatabaseName VARCHAR(max),
    ProcedureName VARCHAR(max),
    SQLText VARCHAR(MAX)
);

EXECUTE sp_MSforeachdb '
USE [?];
    INSERT INTO #ProcSearchResults (DatabaseName, ProcedureName, SQLText)
    SELECT DB_NAME() AS DatabaseName,
           name AS ProcedureName,
           OBJECT_DEFINITION(object_id) AS SQLText
    FROM sys.procedures
    WHERE OBJECT_DEFINITION(object_id) LIKE ''%stpCarga_ContadoresSQL%'';
';

select * from #ProcSearchResults
