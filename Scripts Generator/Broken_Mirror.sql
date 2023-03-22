SELECT 'ALTER DATABASE ['+ db.name +'] SET PARTNER OFF
GO' 
FROM sys.databases db
inner join sys.database_mirroring dm
on db.database_id = dm.database_id
WHERE dm.mirroring_state_desc = 'SYNCHRONIZED';
