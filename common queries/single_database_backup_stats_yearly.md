# Estatísticas Mensais de Backups - Base AdventureWorks

## Descrição da Consulta

Esta consulta gera um relatório sobre os backups do tipo *Full* (`type='D'`) da base de dados **AdventureWorks** para o ano atual. 

### Detalhes:
- Extrai o mês e o ano em que cada backup foi finalizado.
- Calcula o tamanho médio dos backups (em MB) por mês.
- Agrupa os resultados por base de dados, mês e ano do backup.
- Ordena os resultados pelo mês de execução do backup em ordem crescente.

### Campos Retornados:
1. **BackupMonth**: Mês em que o backup foi concluído.
2. **BackupSize (MB)**: Tamanho médio dos backups concluídos no mês.
3. **BackupYear**: Ano em que o backup foi concluído.
4. **database_name**: Nome da base de dados (AdventureWorks).

```SQL
SELECT 
 DATEPART(MONTH,backup_finish_date) AS [BackupMonth] ,
 (AVG(msdb.dbo.backupset.backup_size)/1048576) as [BackupSize (MB)] ,
DATEPART(YEAR,backup_finish_date)  AS [BackupYear],
msdb.dbo.backupset.database_name
FROM msdb.dbo.backupmediafamily 
INNER JOIN msdb.dbo.backupset ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id 
WHERE  msdb..backupset.type='D' 
AND database_name='Adventureworks'
and DATEPART(YEAR,backup_finish_date)=DATEPART(YEAR,GETDATE())
GROUP BY msdb.dbo.backupset.database_name 
, DATEPART(MONTH,backup_finish_date) ,
DATEPART(YEAR,backup_finish_date) 
order by  
 DATEPART(MONTH,backup_finish_date)
 Asc
```