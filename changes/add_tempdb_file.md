#Este procedimento adiciona um novo arquivo de dados à base de dados `tempdb` no SQL Server.

## Adicionando um arquivo ao tempdb

```sql
USE [master]
GO
ALTER DATABASE [tempdb] 
ADD FILE ( NAME = N'temp3', 
FILENAME = N'D:\tempDb\DATA\temp3.ndf' , 
SIZE = 8192KB, 
FILEGROWTH = 65536KB )
GO
```