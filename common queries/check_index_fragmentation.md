# Descrição da Consulta para Verificação de Fragmentação de Índices

## Descrição da Consulta

Esta consulta examina a fragmentação de índices em uma instância do SQL Server e retorna informações sobre tabelas e índices que possuem níveis elevados de fragmentação. Ela utiliza a função `sys.dm_db_index_physical_stats` para acessar as estatísticas físicas dos índices, incluindo a fragmentação média, e junta essas informações com a tabela `sys.indexes` para obter o nome do índice.

### Detalhes da Consulta:
- **Objetivo:** Identificar índices com mais de 30% de fragmentação em um banco de dados específico.
- **Parâmetros de Entrada:**
  - `sys.dm_db_index_physical_stats`: Esta função retorna informações sobre a fragmentação dos índices. O parâmetro `Db_id(DB_NAME())` é utilizado para filtrar a consulta para o banco de dados atual.
  - **Filtro de Fragmentação:** O critério de fragmentação é ajustado com a condição `ips.avg_fragmentation_in_percent > 30`, para mostrar apenas os índices que têm mais de 30% de fragmentação.
  - **Exclusão de Índices Clustered:** A consulta exclui índices do tipo `0` (índices clustered) com `SI.index_id <> 0`, já que a fragmentação desses índices não pode ser ajustada separadamente.

### Resultados Esperados:
- **TableName:** Nome da tabela onde o índice fragmentado está localizado.
- **IndexName:** Nome do índice que está fragmentado.
- **avg_fragmentation_in_percent:** Percentual de fragmentação do índice.
- **DatabaseName:** Nome do banco de dados onde o índice está localizado.

Esta consulta é útil para administradores de banco de dados (DBAs) monitorarem a saúde dos índices e identificarem quais precisam ser reorganizados ou reconstruídos para melhorar a performance.

```SQL
SELECT object_name(ips.object_id) AS TableName,
    ips.index_id, name AS IndexName, avg_fragmentation_in_percent,db_name(ips.database_id) AS DatabaseName
FROM sys.dm_db_index_physical_stats
    (Db_id(DB_NAME())
        , NULL
        , NULL
        , NULL
        , NULL) AS ips
INNER JOIN sys.indexes AS SI
    ON ips.object_id = SI.object_id
    AND ips.index_id = SI.index_id
WHERE ips.avg_fragmentation_in_percent > 30 
     AND SI.index_id <> 0
GO
```