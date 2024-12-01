# Descrição do Script

Este script consiste em duas partes principais: uma consulta que encontra detalhes sobre as estatísticas de todo o banco de dados e uma execução que atualiza essas estatísticas.

## 1. **Encontre Detalhes para as Estatísticas de Todo o Banco de Dados**

A primeira parte do script retorna informações detalhadas sobre as estatísticas de todas as tabelas e colunas no banco de dados. Ele coleta os seguintes dados:

- **Nome da Tabela** (`TableName`): O nome da tabela à qual a estatística pertence.
- **Nome da Coluna** (`ColumnName`): O nome da coluna para a qual a estatística foi gerada.
- **Nome da Estatística** (`StatName`): O nome da estatística.
- **Última Atualização** (`LastUpdated`): A data da última atualização da estatística.
- **Dias desde a Última Atualização** (`DaysOld`): O número de dias desde a última atualização da estatística.
- **Contador de Modificação** (`modification_counter`): O número de modificações feitas na tabela desde a última atualização da estatística.
- **Propriedades da Estatística**: Inclui se a estatística foi criada automaticamente ou pelo usuário, se a recomputação é impedida, entre outros dados técnicos.

A consulta usa as tabelas do sistema `sys.stats`, `sys.stats_columns`, `sys.columns`, `sys.partitions`, e `sys.objects`, além da função `sys.dm_db_stats_properties` para coletar essas informações. Ela filtra apenas as tabelas de usuário e as estatísticas que foram criadas automaticamente ou pelo usuário.

## 2. **Atualização das Estatísticas do Banco de Dados**

A segunda parte do script executa a armazenada **`sp_updatestats`**, que atualiza as estatísticas de todas as tabelas e índices no banco de dados. Isso é importante para garantir que o otimizador de consultas tenha informações atualizadas sobre a distribuição dos dados, melhorando a performance de consultas subsequentes.

```sql
-- Script - Find Details for Statistics of Whole Database
-- (c) Pinal Dave
-- Download Script from - https://blog.sqlauthority.com/contact-me/sign-up/
SELECT DISTINCT
OBJECT_NAME(s.[object_id]) AS TableName,
c.name AS ColumnName,
s.name AS StatName,
STATS_DATE(s.[object_id], s.stats_id) AS LastUpdated,
DATEDIFF(d,STATS_DATE(s.[object_id], s.stats_id),getdate()) DaysOld,
dsp.modification_counter,
s.auto_created,
s.user_created,
s.no_recompute,
s.[object_id],
s.stats_id,
sc.stats_column_id,
sc.column_id
FROM sys.stats s
JOIN sys.stats_columns sc
ON sc.[object_id] = s.[object_id] AND sc.stats_id = s.stats_id
JOIN sys.columns c ON c.[object_id] = sc.[object_id] AND c.column_id = sc.column_id
JOIN sys.partitions par ON par.[object_id] = s.[object_id]
JOIN sys.objects obj ON par.[object_id] = obj.[object_id]
CROSS APPLY sys.dm_db_stats_properties(sc.[object_id], s.stats_id) AS dsp
WHERE OBJECTPROPERTY(s.OBJECT_ID,'IsUserTable') = 1
AND (s.auto_created = 1 OR s.user_created = 1)
ORDER BY DaysOld;
``` 

```sql
Script 2: Update Statistics for Database
EXEC sp_updatestats;
GO
```