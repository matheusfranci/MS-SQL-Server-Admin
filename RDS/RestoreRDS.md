### Restauração de Banco de Dados

* **Restore_Database_From_S3.md:** Script para restaurar um banco de dados a partir de um backup armazenado em um bucket S3.

## Detalhes dos Scripts

### Restore\_Database\_From\_S3.md

Este script utiliza o procedimento armazenado `msdb.dbo.rds_restore_database` para restaurar um banco de dados SQL Server a partir de um arquivo de backup (.BAK) armazenado em um bucket S3.

**Conteúdo do Script:**

```sql
USE [master]
GO
exec msdb.dbo.rds_restore_database
@restore_db_name='Basefake',
@s3_arn_to_restore_from='arn:aws:s3:::2024_09_30/Basefake.BAK';
GO
