### Descrição
Essa query retorna informações sobre o uso de I/O (entrada/saída) de banco de dados no SQL Server, calculando o total de I/O por banco de dados e sua participação percentual no total de I/O do servidor. Ela classifica os bancos de dados por seu uso de I/O e exibe a data da consulta.

### Detalhes
1. **`sys.dm_io_virtual_file_stats`:** Exibe as estatísticas de I/O para arquivos de banco de dados, incluindo bytes lidos e escritos.
2. **`AggregateIOStatistics`:** CTE (Common Table Expression) que calcula o total de I/O para cada banco de dados, somando os bytes lidos e escritos e convertendo para megabytes.
3. **`ROW_NUMBER()`:** Atribui uma classificação (rank) de I/O para cada banco de dados, ordenado pelo total de I/O em ordem decrescente.
4. **`I/O Percent`:** Calcula a porcentagem do uso de I/O de cada banco de dados em relação ao total de I/O no servidor.
5. **`GETDATE()`:** Retorna a data e hora da execução da consulta.

### Exemplo de Uso
```sql
WITH AggregateIOStatistics AS
(
    SELECT DB_NAME(database_id) AS [DB Name],
           CAST(SUM(num_of_bytes_read + num_of_bytes_written)/1048576 AS DECIMAL(12, 2)) AS io_in_mb
    FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS [DM_IO_STATS]
    GROUP BY database_id
)
SELECT ROW_NUMBER() OVER(ORDER BY io_in_mb DESC) AS [I/O Rank],
       [DB Name], 
       io_in_mb AS [Total I/O (MB)],
       CAST(io_in_mb / SUM(io_in_mb) OVER() * 100.0 AS DECIMAL(5, 2)) AS [I/O Percent],
       GETDATE() AS [Data]
FROM AggregateIOStatistics
ORDER BY [I/O Rank];
