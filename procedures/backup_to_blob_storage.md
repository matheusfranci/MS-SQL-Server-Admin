#Este procedimento cria uma credencial para acessar o Azure Blob Storage e faz o backup do banco de dados `master` para várias URLs no Azure.

## Comando

```sql
CREATE CREDENTIAL bkpcloud
WITH IDENTITY = 'dp300pratica',
SECRET = 'MNO56Y84qm+9HRG5pNrNH6Z1b5a/9BjrCjLxUPi8srhmnsT7YqlgmfwCg/Xb44gYliQGlmHf/z4E+AStFkFuWA=='
```

```sql
BACKUP DATABASE master to URL = 'https://hmgsql.blob.core.windows.net/hmg/AdventureWorks2019_O1.BAK',
URL = 'https://hmgsql.blob.core.windows.net/hmg/AdventureWorks2019_02.BAK',
URL = 'https://hmgsql.blob.core.windows.net/hmg/AdventureWorks2019_03.BAK'
WITH CHECKSUM, COMPRESSION, FORMAT, MAXTRANSFERSIZE = 4194304, CREDENTIAL = 'bkphmg', STATS =10;
```