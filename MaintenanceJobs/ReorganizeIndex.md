## Script de Reorganização de Índices Fragmentados

Este script SQL Server realiza a reorganização de índices com fragmentação entre 5% e 30% em múltiplos bancos de dados.

### Funcionalidades

* **Iteração por Bancos de Dados**: Percorre todos os bancos de dados (exceto os de sistema e o banco 38).
* **Identificação de Índices Fragmentados**: Utiliza `sys.dm_db_index_physical_stats` para identificar índices com fragmentação entre 5% e 30%.
* **Geração de Comandos**: Cria comandos `ALTER INDEX ... REORGANIZE` para cada índice fragmentado.
* **Execução Dinâmica**: Executa os comandos de reorganização dinamicamente usando `EXEC`.
* **Registro de Comandos**: Imprime os comandos executados.

### Passos Principais

1.  **Declaração de Variáveis**: Define variáveis para limites de fragmentação, nomes de bancos de dados, e comandos.
2.  **Cursor de Bancos de Dados**: Cria um cursor para percorrer os bancos de dados.
3.  **Loop Principal**:
    * Limpa a tabela temporária.
    * Executa consulta dinâmica para identificar índices fragmentados.
    * Cria cursor para comandos de reorganização.
    * Executa comandos de reorganização.
    * Fecha e desaloca cursores internos.
4.  **Fechamento de Cursores**: Fecha e desaloca o cursor principal.

### Observações

* Utiliza cursores, que podem ser menos performáticos do que abordagens baseadas em conjuntos.
* A fragmentação é definida por uma variável, permitindo fácil ajuste.
* O banco 38 é explicitamente excluido, necessitando de investigação para entender o motivo dessa exclusão.
* Utiliza exec, o que pode abrir brechas de segurança, caso os nomes de bancos de dados ou objetos sejam provenientes de fontes externas.

```sql
declare @porcentagem_fragmentacao int 
set @porcentagem_fragmentacao = 30
DECLARE @DB_Name VARCHAR(100);
DECLARE @Command NVARCHAR(200);
DECLARE @tbl TABLE(string VARCHAR(MAX));
DECLARE database_cursor CURSOR
FOR SELECT name
    FROM sys.databases
    WHERE database_id not in (1,2,3,4,38) ;
OPEN database_cursor;
FETCH NEXT FROM database_cursor INTO @DB_Name;
WHILE @@FETCH_STATUS = 0
    BEGIN
        DELETE FROM @TBL
        INSERT INTO @tbl
        EXEC ('USE '+@DB_Name+' SELECT ''alter index '' + dbindexes.[name] + '' on ''+ dbschemas.[name] +''.'' + dbtables.[name] + '' reorganize''
 
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = DB_ID()  and avg_fragmentation_in_percent > 5 and avg_fragmentation_in_percent <'+ @porcentagem_fragmentacao +' and dbindexes.[name] is not null
ORDER BY indexstats.avg_fragmentation_in_percent desc');
        DECLARE @comando VARCHAR(MAX);
        DECLARE rebuildindice CURSOR
        FOR SELECT string
            FROM @tbl;
        OPEN rebuildindice;
        FETCH NEXT FROM rebuildindice INTO @comando;
        WHILE @@FETCH_STATUS = 0
            BEGIN
			
                DECLARE @cmd VARCHAR(MAX);
                SET @cmd = 'use ' + @DB_Name + ' ' + @comando;
                exec (@cmd);
				PRINT @cmd;
			
                FETCH NEXT FROM rebuildindice INTO @comando;
            END;
        CLOSE rebuildindice;
        DEALLOCATE rebuildindice;
        FETCH NEXT FROM database_cursor INTO @DB_Name;
    END;
	
CLOSE database_cursor; 
DEALLOCATE database_cursor;
```
