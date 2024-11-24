### Descrição
Esta consulta retorna métricas relacionadas ao uso de memória do SQL Server, incluindo a memória utilizada pelo SQL Server, páginas bloqueadas, espaço total de endereço virtual (VAS) e indicadores de memória baixa do processo.

### Consulta para Uso de Memória do SQL Server
A consulta extrai informações da visão dinâmica `sys.dm_os_process_memory` sobre a memória usada, páginas bloqueadas e o total de espaço de endereço virtual disponível para o processo SQL Server.

```sql
SELECT  
    (physical_memory_in_use_kb / 1024) AS Memory_used_by_Sqlserver_MB,  
    (locked_page_allocations_kb / 1024) AS Locked_pages_used_by_Sqlserver_MB,  
    (total_virtual_address_space_kb / 1024) AS Total_VAS_in_MB,
    process_physical_memory_low,  
    process_virtual_memory_low  
FROM sys.dm_os_process_memory;
```