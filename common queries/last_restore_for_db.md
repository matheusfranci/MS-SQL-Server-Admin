### Descrição
Essas queries recuperam informações sobre as restaurações de bancos de dados no SQL Server. A primeira consulta mostra detalhes sobre o banco de dados de destino, data de restauração, nome do banco de dados, nome do arquivo físico e informações sobre o usuário e a máquina que realizaram a restauração. A segunda consulta retorna dados de restauração formatados, incluindo a data da última restauração e o nome do banco de dados.

### Detalhes
1. **`msdb.dbo.restorehistory`:** Contém informações sobre as restaurações realizadas no SQL Server.
2. **`msdb.dbo.backupset`:** Contém detalhes sobre os conjuntos de backup.
3. **`msdb.dbo.backupmediafamily`:** Contém informações sobre os dispositivos físicos usados para backups e restaurações.
4. **Filtro (segunda query):** A segunda consulta filtra as informações para mostrar as restaurações de um banco de dados específico (exemplo: 'Database_01').

### Exemplo de Uso
```sql
-- Primeira Query: Informações sobre restaurações de bancos de dados
SELECT Destination_database_name, 
       restore_date,
       database_name AS Banco,
       Physical_device_name AS Arquivo,
       bs.user_name AS Usuário,
       bs.machine_name
FROM msdb.dbo.restorehistory rh 
  INNER JOIN msdb.dbo.backupset bs ON rh.backup_set_id = bs.backup_set_id
  INNER JOIN msdb.dbo.backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
ORDER BY [rh].[restore_date] DESC;

-- Segunda Query: Última restauração de banco específico
SELECT 
      FORMAT(restore_date,'dd/MM/yyyy') AS Ultima_Restauração,
      database_name AS Banco,
      bs.user_name AS Usuário,
      bs.machine_name
FROM msdb.dbo.restorehistory rh 
  INNER JOIN msdb.dbo.backupset bs ON rh.backup_set_id = bs.backup_set_id
  INNER JOIN msdb.dbo.backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE database_name IN ('Database_01') 
ORDER BY [rh].[restore_date] DESC;
```