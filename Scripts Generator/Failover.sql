SELECT 'ALTER DATABASE ['+ db.name +'] SET RECOVERY FAILOVER
GO' 
FROM sys.databases db
inner join sys.database_mirroring dm
on db.database_id = dm.database_id
WHERE dm.mirroring_state IS NOT NULL;


SELECT 'ALTER DATABASE ['+ db.name +'] SET PARTNER FAILOVER
GO' 
FROM sys.databases db
inner join sys.database_mirroring dm
on db.database_id = dm.database_id
WHERE dm.mirroring_state IS NOT NULL;