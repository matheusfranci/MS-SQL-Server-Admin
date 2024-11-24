### Descrição
O comando `DBCC SQLPERF(logspace)` no SQL Server é usado para obter informações sobre o espaço de log utilizado em todos os bancos de dados do servidor. Ele exibe a quantidade de espaço total e o espaço usado no log de transações para cada banco de dados, ajudando a monitorar a utilização do log de transações e identificar possíveis problemas relacionados ao espaço de log.

### Exemplo de Uso
```sql
DBCC SQLPERF(logspace);
```