### Compressão de Backups S3

* **Enable_S3_Backup_Compression.md:** Script para verificar e habilitar a compressão de backups para o Amazon S3 no AWS RDS.

## Detalhes dos Scripts

### Enable\_S3\_Backup\_Compression.md

Este script utiliza os procedimentos armazenados `rdsadmin.dbo.rds_show_configuration` e `rdsadmin..rds_set_configuration` para verificar e habilitar a compressão de backups para o Amazon S3 no AWS RDS.

**Conteúdo do Script:**

```sql
-- Verifica se o backup é comprimido
EXEC rdsadmin.dbo.rds_show_configuration
@name='S3 backup compression'

-- Caso retorne false, esse comando ativará a propriedade
exec rdsadmin..rds_set_configuration 'S3 backup compression', 'true';
