select 
 db.name as "Nome do banco",
 db.state_desc as "Status do banco" ,
 dm.mirroring_role_desc as "Posição do espelho",
 dm.mirroring_state_desc as "Sincronia",
 dm.mirroring_partner_name as "TCP", 
 dm.mirroring_partner_instance "Instância secundária",
 CASE
WHEN dm.mirroring_safety_level_desc = 'OFF' THEN 'High performance (asynchronous)'
ELSE 'High safety without automatic failover (synchronous)'
END AS 'Grau de sincronismo'
from sys.databases db
inner join sys.database_mirroring dm
on db.database_id = dm.database_id
where dm.mirroring_role_desc is not null
order by db.name;
