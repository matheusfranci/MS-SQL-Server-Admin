CREATE TABLE #tmproleresult
(
Comando VARCHAR(MAX)
)
INSERT INTO #tmproleresult
EXEC master.sys.sp_MSforeachdb' 
USE [?]
SELECT "USE ["+ DB_NAME() +"]
GO
ALTER ROLE ["+ DBRole.NAME +"] ADD MEMBER ["+ DBUser.NAME +"]
GO" AS Comando
FROM sys.database_principals DBUser
INNER JOIN sys.database_role_members DBM ON DBM.member_principal_id = DBUser.principal_id
INNER JOIN sys.database_principals DBRole ON DBRole.principal_id = DBM.role_principal_id
WHERE DBUser.name = "S2\phillipepinheiro"
'
SELECT * FROM #tmproleresult
DROP TABLE #tmproleresult



CREATE TABLE #tmpuserresult
(
Comando VARCHAR(MAX)
)
INSERT INTO #tmpuserresult
EXEC master.sys.sp_MSforeachdb' 
USE [?]
SELECT "
USE ["+ DB_NAME() +"]
GO
CREATE USER [" + NAME + "] FOR LOGIN [" + NAME + "]" AS "--Database Users Creation--"
FROM sys.database_principals
WHERE NAME = "S2\phillipepinheiro" '
SELECT * FROM #tmpuserresult
DROP TABLE #tmpuserresult
