# Descrição da Consulta para Ler o Log de Erros do SQL Server

## Descrição da Consulta

Essa consulta utiliza o procedimento armazenado `xp_readerrorlog` para ler entradas no log de erro do SQL Server com base em critérios específicos, como datas, tipos de log e palavras-chave de pesquisa. Ela é executada em dois blocos distintos, cada um com parâmetros diferentes para filtrar e buscar informações de logs. 

### Primeiro Bloco:

- **Objetivo:** Buscar erros relacionados ao termo "Error" e à base de dados "MSDB", entre 7 de novembro de 2019 e 3 de setembro de 2023.
- **Parâmetros de Entrada:**
  - `@logFileType = 1`: Tipo de log (1 para o log de erros padrão).
  - `@logno = 0`: Número do log, onde 0 se refere ao log de erro atual.
  - `@searchString1 = 'Error'`: O termo a ser procurado no log.
  - `@searchString2 = 'MSDB'`: O termo a ser procurado no log (refere-se à base de dados "MSDB").
  - `@start = '2019-11-07 00:00:01.000'`: Data de início da pesquisa.
  - `@end = '2023-09-03 00:00:00.000'`: Data de término da pesquisa.

### Segundo Bloco:

- **Objetivo:** Buscar entradas no log relacionadas ao comando "DBCC CHECKDB" entre 2 e 3 de setembro de 2023.
- **Parâmetros de Entrada:**
  - `@logFileType = 1`: Tipo de log (1 para o log de erros padrão).
  - `@logno = 0`: Número do log, onde 0 se refere ao log de erro atual.
  - `@searchString1 = 'DBCC CHECKDB'`: O comando "DBCC CHECKDB" a ser pesquisado.
  - `@searchString2 = 'DBCC CHECKDB'`: O mesmo comando "DBCC CHECKDB" a ser pesquisado.
  - `@start = '2023-09-02 00:00:00.000'`: Data de início da pesquisa.
  - `@end = '2023-09-03 00:00:00.000'`: Data de término da pesquisa.

Esses blocos de código retornam as entradas do log que atendem aos critérios de pesquisa, permitindo a investigação de problemas ou eventos específicos que ocorreram dentro dos intervalos de tempo e parâmetros definidos.

```SQL
DECLARE @logFileType SMALLINT= 1;
DECLARE @start DATETIME;
DECLARE @end DATETIME;
DECLARE @logno INT= 0;
SET @start = '2019-11-07 00:00:01.000';
SET @end = '2023-09-03 00:00:00.000';
DECLARE @searchString1 NVARCHAR(256)= 'Error';
DECLARE @searchString2 NVARCHAR(256)= 'MSDB';
EXEC master.dbo.xp_readerrorlog 
     @logno, 
     @logFileType, 
     @searchString1, 
     @searchString2, 
     @start, 
     @end;


DECLARE @logFileType SMALLINT= 1;
DECLARE @start DATETIME;
DECLARE @end DATETIME;
DECLARE @logno INT= 0;
SET @start = '2023-09-02 00:00:00.000';
SET @end = '2023-09-03 00:00:00.000';
DECLARE @searchString1 NVARCHAR(256)= 'DBCC CHECKDB';
DECLARE @searchString2 NVARCHAR(256)= 'DBCC CHECKDB';
EXEC master.dbo.xp_readerrorlog 
     @logno, 
     @logFileType, 
     @searchString1, 
     @searchString2, 
     @start, 
     @end;
```