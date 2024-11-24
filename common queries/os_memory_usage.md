### Descrição
Esta consulta retorna informações sobre a memória física total e disponível do sistema operacional, extraídas da visão dinâmica `sys.dm_os_sys_memory`, que fornece detalhes sobre a memória do sistema no nível do SQL Server.

### Consulta para Memória Física do Sistema Operacional
A consulta exibe a memória física total e a memória disponível para o SQL Server, em megabytes, utilizando a visão `sys.dm_os_sys_memory`.

```sql
SELECT
    (total_physical_memory_kb / 1024) AS Total_OS_Memory_MB,
    (available_physical_memory_kb / 1024) AS Available_OS_Memory_MB
FROM sys.dm_os_sys_memory;
```