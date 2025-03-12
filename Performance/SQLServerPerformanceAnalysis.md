# Análise de Desempenho SQL Server - Procedures sp_Blitz

## 1. sp_BlitzCache

```sql
EXEC sp_BlitzCache
    @Top = 20,
    @ExportToExcel = 1,
    @DatabaseName = 'S2';
```

Esta procedure, `sp_BlitzCache`, é usada para analisar o cache de planos de execução do SQL Server. Ela identifica e lista as consultas que estão consumindo mais recursos do servidor, como CPU, I/O e tempo de execução.

## 2. sp_BlitzFirst

```sql
EXEC sp_BlitzFirst
    @OutputDatabaseName = 'ORION',
    @OutputSchemaName = 'dbo',
    @OutputTableName = 'BlitzFirst',
    @OutputTableNameFileStats = 'BlitzFirst_FileStats',
    @OutputTableNamePerfmonStats = 'BlitzFirst_PerfmonStats',
    @OutputTableNameWaitStats = 'BlitzFirst_WaitStats',
    @OutputTableNameBlitzCache = 'BlitzCache',
    @OutputType = 'none';
```

A procedure `sp_BlitzFirst` é utilizada para obter um instantâneo do desempenho do SQL Server em tempo real. Ela coleta informações sobre diversos aspectos do servidor, incluindo estatísticas de espera, uso de CPU, I/O e outros indicadores de desempenho.

## 3. sp_Blitz

```sql
EXEC sp_Blitz
    @CheckUserDatabaseObjects = 0;
```

`sp_Blitz` é uma procedure de diagnóstico abrangente que verifica a saúde geral do SQL Server. Ela identifica problemas de configuração, alertas de desempenho, e outras questões que podem afetar a estabilidade e o desempenho do servidor.

## 4. sp_BlitzIndex

```sql
EXEC sp_BlitzIndex;
```

A procedure `sp_BlitzIndex` analisa os índices do banco de dados para identificar problemas de design e desempenho. Ela verifica índices duplicados, ausentes, fragmentados, e outros problemas que podem afetar a velocidade das consultas.

## 5. sp_BlitzWho

```sql
EXEC sp_BlitzWho;
```
`sp_BlitzWho` lista as sessões ativas no SQL Server, mostrando quem está executando quais consultas em tempo real. Ela fornece informações detalhadas sobre as sessões, incluindo o usuário, o banco de dados, a consulta em execução, e outros detalhes relevantes.

