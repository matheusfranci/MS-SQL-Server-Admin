### Descrição da Query

Esta query retorna informações sobre a performance de leitura e escrita nos arquivos de banco de dados no SQL Server. Ela utiliza as visualizações dinâmicas `sys.dm_io_virtual_file_stats` e `sys.master_files` para calcular várias métricas de latência e tamanho de leitura/gravação para cada banco de dados, como:

- **Data**: data e hora atuais.
- **DBName**: nome do banco de dados.
- **Drive**: a unidade física do arquivo.
- **ReadLatency**: latência de leitura média, calculada como o tempo de espera de leitura dividido pelo número de leituras.
- **WriteLatency**: latência de escrita média, calculada como o tempo de espera de escrita dividido pelo número de gravações.
- **Latency**: latência geral, calculada com base nas leituras e gravações.
- **AvgBPerRead**: tamanho médio em bytes por leitura.
- **AvgBPerWrite**: tamanho médio em bytes por gravação.
- **AvgBPerTransfer**: tamanho médio em bytes por transferência (leitura + gravação).

A consulta também exclui bancos de dados com nomes específicos ('o', 'm', 'n').

```SQL
SELECT
GETDATE() as [Data],
DB_NAME ([vfs].[database_id]) AS [DBName],

[mf].[physical_name],LEFT ([mf].[physical_name], 2) AS [Drive],

[ReadLatency] =

CASE WHEN [num_of_reads] = 0

THEN 0 ELSE ([io_stall_read_ms] / [num_of_reads]) END,

[WriteLatency] =

CASE WHEN [num_of_writes] = 0

THEN 0 ELSE ([io_stall_write_ms] / [num_of_writes]) END,

[Latency] =

CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0)

THEN 0 ELSE ([io_stall] / ([num_of_reads] + [num_of_writes])) END,

[AvgBPerRead] =

CASE WHEN [num_of_reads] = 0

THEN 0 ELSE ([num_of_bytes_read] / [num_of_reads]) END,

[AvgBPerWrite] =

CASE WHEN [num_of_writes] = 0

THEN 0 ELSE ([num_of_bytes_written] / [num_of_writes]) END,

[AvgBPerTransfer] =

CASE WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0)

THEN 0 ELSE

(([num_of_bytes_read] + [num_of_bytes_written]) /

([num_of_reads] + [num_of_writes])) END

FROM

sys.dm_io_virtual_file_stats (NULL,NULL) AS [vfs]

JOIN sys.master_files AS [mf]

ON [vfs].[database_id] = [mf].[database_id]

AND [vfs].[file_id] = [mf].[file_id]

WHERE DB_NAME ([vfs].[database_id])

not in ('o','m','n')

ORDER BY DB_NAME ([vfs].[database_id]);
```