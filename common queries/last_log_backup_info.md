### Descrição
Essa query recupera informações sobre os backups de log de bancos de dados em recuperação FULL no SQL Server. Ela exibe o nome do banco de dados, o modelo de recuperação, a data do último backup de log realizado, e o tipo de backup (Log Backup).

### Detalhes
1. **`master.sys.databases`:** Contém informações sobre todos os bancos de dados no SQL Server.
2. **`msdb.dbo.backupset`:** Contém detalhes sobre os conjuntos de backup realizados no SQL Server.
3. **Filtro:**
   - **Estado do banco de dados (`state_desc`):** Apenas bancos de dados no estado 'ONLINE' são considerados.
   - **Modelo de recuperação (`recovery_model_desc`):** Apenas bancos de dados com o modelo de recuperação 'FULL' são considerados.
   - **Tipo de backup (`type`):** Apenas backups de tipo 'L' (log backup) são incluídos.

### Exemplo de Uso
```sql
SELECT   d.name,
         d.recovery_model_desc,
         MAX(b.backup_finish_date) AS last_backup_finish_date,
         CASE 
            WHEN b.type = 'L' THEN 'Log Backup'
            ELSE 'Null'
         END AS 'Backup_type'
FROM     master.sys.databases d
         LEFT OUTER JOIN msdb..backupset b
         ON       b.database_name = d.name
         AND      b.type          = 'L'
WHERE d.state_desc = 'ONLINE'
AND d.recovery_model_desc = 'FULL'
GROUP BY d.name, d.recovery_model_desc, b.type
ORDER BY backup_finish_date DESC;
```