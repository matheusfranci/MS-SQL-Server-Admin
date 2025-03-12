# Script: Atualização de Estatísticas com sp_MSforeachdb

Este script utiliza o procedimento armazenado não documentado `sp_MSforeachdb` para executar o procedimento `sp_updatestats` em todos os bancos de dados do servidor SQL Server.

```sql
EXEC master.sys.sp_MSforeachdb
'USE [?]
EXEC sp_updatestats'
