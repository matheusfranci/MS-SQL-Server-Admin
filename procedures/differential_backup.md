#Este procedimento realiza um backup diferencial do banco de dados `testDB`, salvando-o em um arquivo específico no disco.

## Comando

```sql
BACKUP DATABASE testDB
TO DISK = 'D:\backups\testDB.bak'
WITH DIFFERENTIAL;
```