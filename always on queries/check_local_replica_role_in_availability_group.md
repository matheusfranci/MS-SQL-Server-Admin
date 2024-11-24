### Descrição do Script

Este script consulta o estado da réplica local de um grupo de disponibilidade no SQL Server. Ele usa as visões `sys.dm_hadr_availability_replica_states` e `sys.availability_groups` para obter a descrição do papel da réplica local (primary ou secondary) no grupo de disponibilidade.

### Objetivo

O objetivo do script é retornar o `role_desc` da réplica local, ou seja, o papel (role) da réplica no contexto do grupo de disponibilidade.

```SQL
SELECT ars.role_desc
    FROM sys.dm_hadr_availability_replica_states ars
    INNER JOIN sys.availability_groups ag
    ON ars.group_id = ag.group_id
    AND ars.is_local = 1 
```