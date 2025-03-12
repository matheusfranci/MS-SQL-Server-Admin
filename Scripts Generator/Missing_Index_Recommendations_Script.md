# Geração de Scripts de Criação de Índices Ausentes

Este script SQL consulta as Dynamic Management Views (DMVs) do SQL Server para identificar índices ausentes e gera scripts `CREATE INDEX` para criá-los. Ele fornece informações sobre o impacto estimado, a última busca do usuário, o nome da tabela e os scripts de criação de índice recomendados.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Consulta DMVs `sys.dm_db_missing_index_groups`, `sys.dm_db_missing_index_group_stats` e `sys.dm_db_missing_index_details`:** Consulta as DMVs para obter informações sobre índices ausentes, estatísticas de grupos de índices e detalhes de índices ausentes.
2.  **Junção das DMVs:** Junta as DMVs com base nos identificadores de grupos e índices.
3.  **Cálculo do Impacto Estimado:** Calcula o impacto estimado dos índices ausentes multiplicando o impacto médio do usuário pelo número de buscas e verificações do usuário.
4.  **Construção do Nome do Índice:** Constrói um nome de índice baseado no nome da tabela e nas colunas de igualdade e desigualdade.
5.  **Geração de Scripts `CREATE INDEX`:** Gera scripts `CREATE INDEX` com base nas colunas de igualdade, desigualdade e incluídas.
6.  **Filtragem por Banco de Dados Atual:** Filtra os resultados para incluir apenas índices ausentes no banco de dados atual (`DB_ID()`).
7.  **Ordenação por Impacto Estimado:** Ordena os resultados por impacto estimado decrescente.
8.  **Exibição dos Resultados:** Exibe os 25 principais índices ausentes com maior impacto estimado, juntamente com informações sobre o impacto, a última busca do usuário, o nome da tabela e os scripts de criação de índice.

## Detalhes do Script

```sql
SELECT TOP 25
dm_mid.database_id AS DatabaseID,
dm_migs.avg_user_impact*(dm_migs.user_seeks+dm_migs.user_scans) Avg_Estimated_Impact,
dm_migs.last_user_seek AS Last_User_Seek,
OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) AS [TableName],
'CREATE INDEX [IX_' + OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) + '_'
+ REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.equality_columns,''),', ','_'),'[',''),']','')
+ CASE
WHEN dm_mid.equality_columns IS NOT NULL
AND dm_mid.inequality_columns IS NOT NULL THEN '_'
ELSE ''
END
+ REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.inequality_columns,''),', ','_'),'[',''),']','')
+ ']'
+ ' ON ' + dm_mid.statement
+ ' (' + ISNULL (dm_mid.equality_columns,'')
+ CASE WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns
IS NOT NULL THEN ',' ELSE
'' END
+ ISNULL (dm_mid.inequality_columns, '')
+ ')'
+ ISNULL (' INCLUDE (' + dm_mid.included_columns + ')', '') AS Create_Statement
FROM sys.dm_db_missing_index_groups dm_mig
INNER JOIN sys.dm_db_missing_index_group_stats dm_migs
ON dm_migs.group_handle = dm_mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details dm_mid
ON dm_mig.index_handle = dm_mid.index_handle
WHERE dm_mid.database_ID = DB_ID()
ORDER BY Avg_Estimated_Impact DESC
GO
