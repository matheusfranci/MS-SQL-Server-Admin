# Geração de Scripts para Remover Índices Não Clusterizados Não Utilizados

Este script SQL identifica os 25 índices não clusterizados menos utilizados em um banco de dados e gera scripts `DROP INDEX` para removê-los.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Consulta `sys.dm_db_index_usage_stats`:** Consulta a DMV `sys.dm_db_index_usage_stats` para obter informações sobre o uso de índices.
2.  **Junções com Tabelas do Sistema:** Junta os resultados com as tabelas `sys.indexes`, `sys.objects`, `sys.schemas` e `sys.partitions` para obter informações adicionais sobre os índices e tabelas.
3.  **Filtragem de Índices Não Clusterizados:** Filtra os resultados para incluir apenas índices não clusterizados (`i.type_desc = 'nonclustered'`) de tabelas de usuário (`OBJECTPROPERTY(dm_ius.OBJECT_ID, 'IsUserTable') = 1`).
4.  **Exclusão de Índices de Chave Primária e Restrições Únicas:** Exclui índices associados a chaves primárias (`i.is_primary_key = 0`) e restrições únicas (`i.is_unique_constraint = 0`).
5.  **Cálculo do Uso Total:** Calcula o uso total do índice somando `user_seeks`, `user_scans` e `user_lookups`.
6.  **Ordenação por Uso:** Ordena os resultados pelo uso total do índice em ordem crescente (`ORDER BY (dm_ius.user_seeks + dm_ius.user_scans + dm_ius.user_lookups) ASC`).
7.  **Seleção dos 25 Índices Menos Utilizados:** Seleciona os 25 índices menos utilizados (`TOP 25`).
8.  **Geração de Scripts `DROP INDEX`:** Gera scripts `DROP INDEX [index_name] ON [schema_name].[table_name]` para cada índice selecionado.
9.  **Exibição dos Resultados:** Exibe os nomes das tabelas, nomes dos índices, IDs dos índices, estatísticas de uso, número de linhas da tabela e os scripts `DROP INDEX` gerados.

## Detalhes do Script

```sql
SELECT TOP 25
o.name AS ObjectName
, i.name AS IndexName
, i.index_id AS IndexID
, dm_ius.user_seeks AS UserSeek
, dm_ius.user_scans AS UserScans
, dm_ius.user_lookups AS UserLookups
, dm_ius.user_updates AS UserUpdates
, p.TableRows
, 'DROP INDEX ' + QUOTENAME(i.name)
+ ' ON ' + QUOTENAME(s.name) + '.'
+ QUOTENAME(OBJECT_NAME(dm_ius.OBJECT_ID)) AS 'drop statement'
FROM sys.dm_db_index_usage_stats dm_ius
INNER JOIN sys.indexes i ON i.index_id = dm_ius.index_id
AND dm_ius.OBJECT_ID = i.OBJECT_ID
INNER JOIN sys.objects o ON dm_ius.OBJECT_ID = o.OBJECT_ID
INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
INNER JOIN (SELECT SUM(p.rows) TableRows, p.index_id, p.OBJECT_ID
FROM sys.partitions p GROUP BY p.index_id, p.OBJECT_ID) p
ON p.index_id = dm_ius.index_id AND dm_ius.OBJECT_ID = p.OBJECT_ID
WHERE OBJECTPROPERTY(dm_ius.OBJECT_ID,'IsUserTable') = 1
AND dm_ius.database_id = DB_ID()
AND i.type_desc = 'nonclustered'
AND i.is_primary_key = 0
AND i.is_unique_constraint = 0
ORDER BY (dm_ius.user_seeks + dm_ius.user_scans + dm_ius.user_lookups) ASC
GO
