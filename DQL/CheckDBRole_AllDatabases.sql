CREATE TABLE #tmpresult
(
role_principal_name VARCHAR(MAX),
member_principal_name VARCHAR(MAX),
Banco VARCHAR(MAX)
)
INSERT INTO #tmpresult
EXEC master.sys.sp_MSforeachdb 
'USE [?]
SELECT r.name role_principal_name, m.name AS member_principal_name, DB_NAME() AS Banco
FROM sys.database_role_members rm 
JOIN sys.database_principals r 
    ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m 
    ON rm.member_principal_id = m.principal_id
where m.name IN ("POLIEDRO\JNMOURA.MARCUS.SOUZA")
order by m.name;'
SELECT * FROM #tmpresult
DROP TABLE #tmpresult
