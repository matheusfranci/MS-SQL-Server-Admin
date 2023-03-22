SELECT 'ALTER DATABASE ['+ db.name +'] SET SAFETY FULL
GO' 
FROM sys.databases db
inner join sys.database_mirroring dm
on db.database_id = dm.database_id
WHERE dm.mirroring_safety_level_desc = 'OFF';
