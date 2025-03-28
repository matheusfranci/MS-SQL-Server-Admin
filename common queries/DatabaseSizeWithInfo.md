## Monitoramento do Espaço em Disco de Bancos de Dados Específicos no SQL Server

Este script SQL realiza a consulta do espaço em disco de bancos de dados específicos no SQL Server, proporcionando informações sobre o tamanho total do banco de dados, o tamanho dos arquivos de dados e de log, e os nomes dos arquivos de dados e log.

### Passos do Script:

1.  **Consulta de Tamanho e Arquivos:**
    * O script utiliza as tabelas `sys.databases` e `sys.master_files` para obter informações sobre os bancos de dados e seus arquivos.
    * Ele calcula o `Tamanho total do banco`, o `Tamanho dos arquivos de dados`, e o `Tamanho dos arquivos de log` em MB.
    * Ele lista os nomes físicos dos arquivos de dados e log.

### Campos Retornados:

* `Banco`: Nome do banco de dados.
* `Tamanho total do banco`: Tamanho total do banco de dados, em MB.
* `Tamanho dos arquivos de dados`: Tamanho dos arquivos de dados, em MB.
* `Tamanho dos arquivos de log`: Tamanho dos arquivos de log, em MB.
* `ARQUIVOS_DADOS`: Nomes físicos dos arquivos de dados.
* `ARQUIVOS_LOG`: Nomes físicos dos arquivos de log.

### Filtro de Resultados:

* O script filtra os resultados para incluir apenas os bancos de dados especificados na cláusula `WHERE`.

### Script SQL:

```sql
SELECT
    db.name AS Banco,
    CONVERT(VARCHAR, SUM(size) * 8 / 1024) AS [Tamanho total do banco],
    COALESCE(SUM(CASE WHEN mf.type = 0 THEN mf.size * 8 / 1024 END), 0) AS [Tamanho dos arquivos de dados],
    COALESCE(SUM(CASE WHEN mf.type = 1 THEN mf.size * 8 / 1024 END), 0) AS [Tamanho dos arquivos de log],
    UPPER(STUFF((
        SELECT '; ' + mf2.physical_name
        FROM sys.master_files mf2
        WHERE mf2.database_id = db.database_id AND mf2.type = 0
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, ''))
    AS ARQUIVOS_DADOS,
    UPPER(STUFF((
        SELECT '; ' + mf3.physical_name
        FROM sys.master_files mf3
        WHERE mf3.database_id = db.database_id AND mf3.type = 1
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, ''))
    AS ARQUIVOS_LOG
FROM sys.databases db
JOIN sys.master_files mf ON db.database_id = mf.database_id
WHERE db.name IN (
   'db1'
)
GROUP BY db.database_id, db.name
ORDER BY db.name;
```
