Select Destination_database_name, 
       restore_date,
       database_name as Banco,
       Physical_device_name as Arquivo,
       bs.user_name as Usuário,
       bs.machine_name
from msdb.dbo.restorehistory rh 
  inner join msdb.dbo.backupset bs 
    on rh.backup_set_id=bs.backup_set_id
  inner join msdb.dbo.backupmediafamily bmf 
    on bs.media_set_id =bmf.media_set_id
ORDER BY [rh].[restore_date] DESC


Select 
      FORMAT (restore_date,'dd/MM/yyyy') AS Ultima_Restauração ,
       database_name as Banco,
       bs.user_name as Usuário,
       bs.machine_name
from msdb.dbo.restorehistory rh 
  inner join msdb.dbo.backupset bs 
    on rh.backup_set_id=bs.backup_set_id
  inner join msdb.dbo.backupmediafamily bmf 
    on bs.media_set_id =bmf.media_set_id
	where database_name in ('TSSESC', 'TOTVSTSS', 'DADOSADV')
ORDER BY [rh].[restore_date] DESC
