# Update Database Filepaths

Este procedimento atualiza o caminho físico dos arquivos de log para dois bancos de dados no SQL Server, seguido por uma verificação dos arquivos de dados e logs.

## Etapas do procedimento

### 1. Alteração do caminho dos arquivos de log
Os comandos abaixo modificam o caminho dos arquivos de log (`.ldf`) dos bancos `Database_01` e `Database_02` para um novo diretório.

```sql
ALTER DATABASE Database_01
MODIFY FILE (NAME = 'Database_01_log', FILENAME = 'G:\MSSQL\TESS\LOG\Database_01.ldf');
GO

ALTER DATABASE Database_02
MODIFY FILE (NAME = 'Database_02_log', FILENAME = 'G:\MSSQL\TESS\LOG\Database_02.ldf');
GO
```


### 2. Verificação dos arquivos de dados e logs
Após a alteração, a verificação permite validar as mudanças feitas. São exibidas informações como:

- **`database_id`**: Identificador do banco de dados.
- **`name`**: Nome do banco de dados.
- **`data_file`**: Caminho físico do arquivo de dados (`.mdf`).
- **`log_file`**: Caminho físico do arquivo de log (`.ldf`).
- **`db_size`**: Tamanho do arquivo de dados em MB.
- **`log_size`**: Tamanho do arquivo de log em MB.

```sql
SELECT 
    mdf.database_id, 
    mdf.name, 
    mdf.physical_name as data_file, 
    ldf.physical_name as log_file, 
    db_size = CAST((mdf.size * 8.0)/1024 AS DECIMAL(8,2)), 
    log_size = CAST((ldf.size * 8.0 / 1024) AS DECIMAL(8,2))
FROM (SELECT * FROM sys.master_files WHERE type_desc = 'ROWS' ) mdf
JOIN (SELECT * FROM sys.master_files WHERE type_desc = 'LOG' ) ldf
ON mdf.database_id = ldf.database_id;
```

### 3. Verificação apenas dos arquivos de dados
Esta verificação retorna informações sobre os arquivos de dados (`.mdf`) de todos os bancos, incluindo:

- **`database_id`**: Identificador do banco de dados.
- **`name`**: Nome do banco de dados.
- **`data_file`**: Caminho físico do arquivo de dados.

```sql
SELECT 
mdf.database_id, 
mdf.name, 
mdf.physical_name as data_file
FROM (SELECT * FROM sys.master_files WHERE type_desc = 'ROWS' ) mdf;
```

## Observações
- Certifique-se de que o novo caminho dos arquivos (`FILENAME`) já exista e tenha as permissões necessárias antes de executar o comando.
- Execute os comandos de verificação para garantir que as alterações foram aplicadas corretamente.

