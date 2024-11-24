### Descrição
Essa query retorna informações sobre a fragmentação de índices em um banco de dados específico, listando os schemas, tabelas e índices afetados, juntamente com as estatísticas de fragmentação e o número de páginas dos índices.

### Detalhes
1. **`sys.dm_db_index_physical_stats`:** Função que retorna estatísticas sobre a fragmentação dos índices de uma tabela ou banco de dados.
2. **`sys.tables`:** Contém informações sobre todas as tabelas no banco de dados.
3. **`sys.schemas`:** Contém informações sobre os schemas no banco de dados.
4. **`sys.indexes`:** Contém informações sobre os índices no banco de dados.
5. **`avg_fragmentation_in_percent`:** Exibe o percentual de fragmentação do índice.
6. **`page_count`:** Número de páginas do índice.
7. **`ORDER BY indexstats.avg_fragmentation_in_percent DESC`:** Ordena os resultados pela fragmentação do índice em ordem decrescente.

### Exemplo de Uso
```sql
SELECT dbschemas.[name] AS 'Schema',
       dbtables.[name] AS 'Table',
       dbindexes.[name] AS 'Index',
       indexstats.avg_fragmentation_in_percent,
       indexstats.page_count
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.tables dbtables ON dbtables.[object_id] = indexstats.[object_id]
INNER JOIN sys.schemas dbschemas ON dbtables.[schema_id] = dbschemas.[schema_id]
INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = DB_ID()
ORDER BY indexstats.avg_fragmentation_in_percent DESC;
```