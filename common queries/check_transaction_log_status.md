### Descrição
O comando **`DBCC LOGINFO`** exibe informações sobre os registros de log de transações no SQL Server. Ele fornece detalhes sobre o status dos arquivos de log e como as transações estão sendo gravadas.

### Detalhes
1. **`DBCC LOGINFO`:** Exibe as informações de status do log de transações, incluindo a quantidade de registros de log e o status de cada um.
2. **Exemplo de Informações Retornadas:** O comando retorna dados sobre os arquivos de log, como o número de registros de log, a quantidade de registros ativos e a quantidade de espaço utilizado.
   
### Exemplo de Uso
```sql
DBCC LOGINFO;
```