CREATE TABLE #UserPermission
(
   ServerName SYSNAME,
   DbName SYSNAME,
   UserName SYSNAME,
   TypeOfLogIn VARCHAR(50),
   PermissionLevel VARCHAR(50),
   TypeOfRole VARCHAR(50)
)

INSERT #UserPermission
EXEC sp_MSforeachdb '

use [?]

IF ''?'' <> ''master'' AND ''?'' <> ''model'' AND ''?'' <> ''msdb'' AND ''?'' <> ''tempdb''
BEGIN

  SELECT ServerName=@@servername, dbname=db_name(db_id()),p.name as UserName, p.type_desc as TypeOfLogin,
  pp.name as PermissionLevel, pp.type_desc as TypeOfRole 
  FROM sys.database_role_members roles
  JOIN sys.database_principals p ON roles.member_principal_id = p.principal_id
  JOIN sys.database_principals pp ON roles.role_principal_id = pp.principal_id
  where pp.name=''db_owner'' and p.name<>''dbo''   

END '

SELECT * FROM  #UserPermission

DROP TABLE #UserPermission



