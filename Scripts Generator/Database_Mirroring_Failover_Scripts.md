# Geração de Scripts para Failover de Espelhamento de Banco de Dados (Database Mirroring)

Este documento descreve dois scripts SQL que geram dinamicamente scripts para executar failover de espelhamento de banco de dados (database mirroring) no SQL Server.

## Visão Geral

Os scripts consultam a tabela `sys.databases` e `sys.database_mirroring` para identificar bancos de dados com espelhamento configurado e geram scripts `ALTER DATABASE` para executar o failover.

## Script 1: Failover de Recuperação (RECOVERY FAILOVER)

Este script gera scripts `ALTER DATABASE ... SET RECOVERY FAILOVER` para realizar um failover de recuperação, que geralmente é usado quando o servidor principal está indisponível.

```sql
SELECT 'ALTER DATABASE ['+ db.name +'] SET RECOVERY FAILOVER
GO'
FROM sys.databases db
inner join sys.database_mirroring dm
on db.database_id = dm.database_id
WHERE dm.mirroring_state IS NOT NULL;
```

## Script 2: Failover de Parceiro (PARTNER FAILOVER)
  
Este script gera scripts ALTER DATABASE ... SET PARTNER FAILOVER para realizar um failover de parceiro, que geralmente é um failover planejado.
  
```sql
SELECT 'ALTER DATABASE ['+ db.name +'] SET PARTNER FAILOVER
GO' 
FROM sys.databases db
inner join sys.database_mirroring dm
on db.database_id = dm.database_id
WHERE dm.mirroring_state IS NOT NULL;
```
