# Análise de Backups no SQL Server - Últimos 12 Meses

## Descrição da Consulta

Esta consulta realiza duas análises detalhadas sobre os backups realizados no SQL Server nos últimos 12 meses:

1. **Crescimento Mensal de Tamanho dos Backups**  
   - Utiliza uma CTE chamada `HIST` para agrupar informações dos backups por mês e base de dados.
   - Calcula o menor, maior e tamanho médio dos backups (em MB) para cada mês e base de dados.
   - Determina o crescimento no tamanho médio dos backups em relação ao mês anterior.

2. **Relatório Pivô de Tamanhos Médios**  
   - Gera um relatório pivotado com as médias mensais de tamanho dos backups para cada base de dados.
   - As colunas representam o número de meses atrás (de 0 a -12 meses).
```SQL
DECLARE @endDate datetime, @months smallint;
SET @endDate = GetDate();  -- Include in the statistic all backups from today
SET @months = 12;           -- back to the last 6 months.

;WITH HIST AS
   (SELECT BS.database_name AS DatabaseName
          ,YEAR(BS.backup_start_date) * 100
           + MONTH(BS.backup_start_date) AS YearMonth
          ,CONVERT(numeric(10, 1), MIN(BF.file_size / 1048576.0)) AS MinSizeMB
          ,CONVERT(numeric(10, 1), MAX(BF.file_size / 1048576.0)) AS MaxSizeMB
          ,CONVERT(numeric(10, 1), AVG(BF.file_size / 1048576.0)) AS AvgSizeMB
    FROM msdb.dbo.backupset as BS
         INNER JOIN
         msdb.dbo.backupfile AS BF
             ON BS.backup_set_id = BF.backup_set_id
    WHERE NOT BS.database_name IN
              ('master', 'msdb', 'model', 'tempdb')
          AND BF.file_type = 'D'
          AND BS.backup_start_date BETWEEN DATEADD(mm, - @months, @endDate) AND @endDate
    GROUP BY BS.database_name
            ,YEAR(BS.backup_start_date)
            ,MONTH(BS.backup_start_date))
SELECT MAIN.DatabaseName
      ,MAIN.YearMonth
      ,MAIN.MinSizeMB
      ,MAIN.MaxSizeMB
      ,MAIN.AvgSizeMB
      ,MAIN.AvgSizeMB 
       - (SELECT TOP 1 SUB.AvgSizeMB
          FROM HIST AS SUB
          WHERE SUB.DatabaseName = MAIN.DatabaseName
                AND SUB.YearMonth < MAIN.YearMonth
          ORDER BY SUB.YearMonth DESC) AS GrowthMB
FROM HIST AS MAIN
ORDER BY MAIN.DatabaseName
        ,MAIN.YearMonth
        
        
        DECLARE @startDate datetime;
SET @startDate = GetDate();

SELECT PVT.DatabaseName
, PVT.[0], PVT.[-1], PVT.[-2], PVT.[-3], PVT.[-4], PVT.[-5], PVT.[-6]
, PVT.[-7], PVT.[-8], PVT.[-9], PVT.[-10], PVT.[-11], PVT.[-12]
FROM
(SELECT BS.database_name AS DatabaseName
,DATEDIFF(mm, @startDate, BS.backup_start_date) AS MonthsAgo
,CONVERT(numeric(10, 1), AVG(BF.file_size / 1048576.0)) AS AvgSizeMB
FROM msdb.dbo.backupset as BS
INNER JOIN
msdb.dbo.backupfile AS BF
ON BS.backup_set_id = BF.backup_set_id
WHERE NOT BS.database_name IN
('master', 'msdb', 'model', 'tempdb')
AND BF.[file_type] = 'D'
AND BS.backup_start_date BETWEEN DATEADD(yy, -1, @startDate) AND @startDate
GROUP BY BS.database_name
,DATEDIFF(mm, @startDate, BS.backup_start_date)
) AS BCKSTAT
PIVOT (SUM(BCKSTAT.AvgSizeMB)
FOR BCKSTAT.MonthsAgo IN ([0], [-1], [-2], [-3], [-4], [-5], [-6], [-7], [-8], [-9], [-10], [-11], [-12])
) AS PVT
ORDER BY PVT.DatabaseName;
```