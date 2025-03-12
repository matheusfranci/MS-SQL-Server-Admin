* **Show_RDS_Configuration.md:** Script para exibir todas as configurações disponíveis na instância RDS.

## Detalhes dos Scripts

### Show\_RDS\_Configuration.md

Este script utiliza o procedimento armazenado `rdsadmin.dbo.rds_show_configuration` para exibir as configurações atuais da instância AWS RDS.

**Conteúdo do Script:**

```sql
exec rdsadmin.dbo.rds_show_configuration
