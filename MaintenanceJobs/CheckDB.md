# Script: Verificação de Integridade de Banco de Dados com sp_MSforeachdb

Este script utiliza o procedimento armazenado não documentado `sp_MSforeachdb` para executar o comando `DBCC CHECKDB WITH DATA_PURITY` em todos os bancos de dados do servidor SQL Server.

```sql
EXEC master.sys.sp_MSforeachdb
'USE [?]
DBCC CHECKDB WITH DATA_PURITY'
