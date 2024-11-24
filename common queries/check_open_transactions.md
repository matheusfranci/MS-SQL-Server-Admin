### Descrição da Query

O comando `DBCC OPENTRAN` é utilizado no SQL Server para verificar se existem transações abertas (pendentes) no banco de dados atual. Ele retorna informações sobre a transação mais antiga ainda não confirmada ou revertida, o que é útil para monitorar transações que podem estar afetando o desempenho ou bloqueando outras operações.

A saída inclui:
- **`spid`**: ID da sessão que iniciou a transação.
- **`transaction name`**: Nome da transação, caso tenha sido especificado.
- **`last commit time`**: Hora do último commit da transação.
- **`open transaction count`**: Número de transações abertas no banco de dados.

```SQL
DBCC OPENTRAN
```
