SELECT name, state_desc 
FROM   sys.databases;

SELECT name,
state_desc,
recovery_model_desc,
collation_name,
compatibility_level,
CASE 
WHEN compatibility_level = 150 THEN 'SQL Server 2019 (15.x)'
WHEN compatibility_level = 140 THEN 'SQL Server 2017 (14.x)'
WHEN compatibility_level = 130 THEN 'SQL Server 2016 (13.x)'
WHEN compatibility_level = 120 THEN 'SQL Server 2014 (12.x)'
WHEN compatibility_level = 110 THEN 'SQL Server 2012 (11.x)'
WHEN compatibility_level = 100 THEN 'SQL Server 2008 R2 (10.50.x)'
WHEN compatibility_level = 90 THEN 'SQL Server 2005 (9.x)'
WHEN compatibility_level = 80 THEN 'SQL Server 2000 (8.x)'
ELSE 'Verificar no link: https://learn.microsoft.com/pt-br/sql/t-sql/statements/alter-database-transact-sql-compatibility-level?view=sql-server-ver16'
END AS 'VERSION'
FROM   sys.databases;
