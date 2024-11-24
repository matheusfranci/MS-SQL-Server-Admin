### Descrição
Essa query retorna informações detalhadas sobre os backups de bancos de dados no SQL Server, incluindo o tipo de backup (Full, Log, ou Diferencial), nome do banco de dados, datas de início e término do backup, duração, tamanho do backup, e o nome do dispositivo físico utilizado. Ela considera o último backup de cada tipo (Full, Log, e Diferencial) para cada banco de dados.

### Detalhes
1. **`msdb.dbo.backupset`:** Contém informações sobre os conjuntos de backup no SQL Server.
2. **`msdb.dbo.backupmediafamily`:** Contém informações sobre os dispositivos de mídia (físicos) utilizados para armazenar os backups.
3. **Conversões de dados:**
   - **Tipo de backup (`backup_type`):** Determina se o backup é Full, Log ou Diferencial.
   - **Duração do backup (`duration`):** Calcula a diferença entre o horário de término e início do backup.
   - **Tamanho do backup (`backup_size`):** Exibe o tamanho do backup em megabytes (MB), levando em consideração a compressão.

### Exemplo de Uso
```sql
SELECT
      backup_type =
            CASE f.[type]
                WHEN 'D' THEN 'Full'
                WHEN 'L' THEN 'Log'
                WHEN 'I' THEN 'Diff'
            END
    , f.database_name
    , f.backup_start_date
    , f.backup_finish_date
    , duration = CAST(f.backup_finish_date - f.backup_start_date AS TIME)
    , f.backup_size
    , b.physical_device_name
FROM (
    SELECT
          s.media_set_id
        , s.[type]
        , s.database_name
        , s.backup_start_date
        , s.backup_finish_date
        , backup_size =
            CASE WHEN s.backup_size = s.compressed_backup_size
                THEN s.backup_size
                ELSE s.compressed_backup_size
            END / 1048576.
        , RowNum = ROW_NUMBER() OVER (PARTITION BY s.database_name, s.[type] ORDER BY s.backup_finish_date DESC)
    FROM msdb.dbo.backupset s
    --WHERE s.database_name = DB_NAME()
) f
JOIN msdb.dbo.backupmediafamily b ON f.media_set_id = b.media_set_id
WHERE f.RowNum = 1
ORDER BY f.backup_finish_date DESC;
