### Descrição
Essa query retorna informações detalhadas sobre os trabalhos (`Jobs`) agendados no SQL Server, incluindo o nome do trabalho, frequência de execução, intervalo, horário de execução, e o próximo horário de execução. Ela fornece uma visualização clara da programação dos trabalhos, seja para tarefas diárias, semanais ou com base em datas específicas.

### Detalhes
1. **`msdb.dbo.sysjobs`:** Contém informações sobre os trabalhos no SQL Server.
2. **`msdb.dbo.sysjobschedules` e `msdb.dbo.sysschedules`:** Contêm detalhes sobre os agendamentos de cada trabalho, incluindo frequência, intervalo e horário.
3. **Conversões de tempo:**
   - **Frequência (`Frequency`):** Exibe a frequência do trabalho, como 'Diário', 'Semanal', 'Mensal', etc.
   - **Intervalo (`Interval`):** Mostra o intervalo entre as execuções, como o número de dias, semanas ou meses, dependendo da configuração.
   - **Hora (`Time`):** Exibe a hora de execução, incluindo formatação de minutos, segundos e horas.
   - **Próximo horário de execução (`NextRunTime`):** Calcula e exibe a data e hora do próximo agendamento.

### Exemplo de Uso
```sql
SELECT 
    S.name AS JobName,                    
    CASE(SS.freq_type)
        WHEN 1  THEN 'Once'
        WHEN 4  THEN 'Daily'
        WHEN 8  THEN (CASE WHEN (SS.freq_recurrence_factor > 1) THEN 'Every ' + CONVERT(VARCHAR(3), SS.freq_recurrence_factor) + ' Weeks' ELSE 'Weekly' END)
        WHEN 16 THEN (CASE WHEN (SS.freq_recurrence_factor > 1) THEN 'Every ' + CONVERT(VARCHAR(3), SS.freq_recurrence_factor) + ' Months' ELSE 'Monthly' END)
        WHEN 32 THEN 'Every ' + CONVERT(VARCHAR(3), SS.freq_recurrence_factor) + ' Months'
        WHEN 64 THEN 'SQL Startup'
        WHEN 128 THEN 'SQL Idle'
        ELSE '??'
    END AS Frequency,  
    CASE
        WHEN (freq_type = 1) THEN 'One time only'
        WHEN (freq_type = 4 AND freq_interval = 1) THEN 'Every Day'
        WHEN (freq_type = 4 AND freq_interval > 1) THEN 'Every ' + CONVERT(VARCHAR(10), freq_interval) + ' Days'
        WHEN (freq_type = 8) THEN (SELECT 'Weekly Schedule' = MIN(D1 + D2 + D3 + D4 + D5 + D6 + D7)
                                    FROM (SELECT SS.schedule_id,
                                                  freq_interval, 
                                                  'D1' = CASE WHEN (freq_interval & 1 <> 0) THEN 'Sun ' ELSE '' END,
                                                  'D2' = CASE WHEN (freq_interval & 2 <> 0) THEN 'Mon ' ELSE '' END,
                                                  'D3' = CASE WHEN (freq_interval & 4 <> 0) THEN 'Tue ' ELSE '' END,
                                                  'D4' = CASE WHEN (freq_interval & 8 <> 0) THEN 'Wed ' ELSE '' END,
                                                  'D5' = CASE WHEN (freq_interval & 16 <> 0) THEN 'Thu ' ELSE '' END,
                                                  'D6' = CASE WHEN (freq_interval & 32 <> 0) THEN 'Fri ' ELSE '' END,
                                                  'D7' = CASE WHEN (freq_interval & 64 <> 0) THEN 'Sat ' ELSE '' END
                                          FROM msdb..sysschedules ss
                                          WHERE freq_type = 8) AS F
                                    WHERE schedule_id = SJ.schedule_id)
        WHEN (freq_type = 16) THEN 'Day ' + CONVERT(VARCHAR(2), freq_interval) 
        WHEN (freq_type = 32) THEN (SELECT freq_rel + WDAY
                                     FROM (SELECT SS.schedule_id,
                                                   'freq_rel' = CASE(freq_relative_interval)
                                                                WHEN 1 THEN 'First'
                                                                WHEN 2 THEN 'Second'
                                                                WHEN 4 THEN 'Third'
                                                                WHEN 8 THEN 'Fourth'
                                                                WHEN 16 THEN 'Last'
                                                                ELSE '??' END,
                                                   'WDAY' = CASE (freq_interval)
                                                                WHEN 1 THEN ' Sun'
                                                                WHEN 2 THEN ' Mon'
                                                                WHEN 3 THEN ' Tue'
                                                                WHEN 4 THEN ' Wed'
                                                                WHEN 5 THEN ' Thu'
                                                                WHEN 6 THEN ' Fri'
                                                                WHEN 7 THEN ' Sat'
                                                                WHEN 8 THEN ' Day'
                                                                WHEN 9 THEN ' Weekday'
                                                                WHEN 10 THEN ' Weekend'
                                                                ELSE '??' END
                                           FROM msdb..sysschedules SS
                                           WHERE SS.freq_type = 32) AS WS 
                                     WHERE WS.schedule_id = SS.schedule_id) 
    END AS Interval,
    CASE (freq_subday_type)
        WHEN 1 THEN LEFT(STUFF((STUFF((REPLICATE('0', 6 - LEN(active_start_time))) + CONVERT(VARCHAR(6), active_start_time), 3, 0, ':')), 6, 0, ':'), 8)
        WHEN 2 THEN 'Every ' + CONVERT(VARCHAR(10), freq_subday_interval) + ' seconds'
        WHEN 4 THEN 'Every ' + CONVERT(VARCHAR(10), freq_subday_interval) + ' minutes'
        WHEN 8 THEN 'Every ' + CONVERT(VARCHAR(10), freq_subday_interval) + ' hours'
        ELSE '??'
    END AS [Time],
    CASE SJ.next_run_date
        WHEN 0 THEN CAST('n/a' AS CHAR(10))
        ELSE CONVERT(CHAR(10), CONVERT(DATETIME, CONVERT(CHAR(8), SJ.next_run_date)), 120) + ' ' + LEFT(STUFF((STUFF((REPLICATE('0', 6 - LEN(next_run_time))) + CONVERT(VARCHAR(6), next_run_time), 3, 0, ':')), 6, 0, ':'), 8)
    END AS NextRunTime
FROM msdb.dbo.sysjobs S
LEFT JOIN msdb.dbo.sysjobschedules SJ ON S.job_id = SJ.job_id  
LEFT JOIN msdb.dbo.sysschedules SS ON SS.schedule_id = SJ.schedule_id
ORDER BY S.name;
