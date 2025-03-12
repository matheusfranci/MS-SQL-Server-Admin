## Resumo do Script de Otimização de Índices

Este script executa a stored procedure `dbo.IndexOptimize` para manutenção de índices em bancos de dados SQL Server.

### Funções Principais

* **Otimização de Índices**: Reorganiza ou recria índices com base na fragmentação.
* **Gerenciamento de Fragmentação**:
    * Baixa fragmentação ( `< 5%` ): Nenhuma ação.
    * Média fragmentação ( `5% - 30%` ): Reorganiza ou recria.
    * Alta fragmentação ( `> 30%` ): Recria.
* **Recursos**: Utiliza `tempdb` para ordenação e otimiza o paralelismo.
* **Registro**: Log dos resultados em tabela.

### Parâmetros Chave

* `@Databases`: Lista de bancos a otimizar.
* `@FragmentationLow`, `@FragmentationMedium`, `@FragmentationHigh`: Ações por nível de fragmentação.
* `@FragmentationLevel1`, `@FragmentationLevel2`: Limites de fragmentação.
* `@SortInTempdb`: Usa `tempdb` para ordenação.
* `@MaxDOP`: Grau de paralelismo.
* `@LogToTable`: Habilita log.

### Importante

* Utiliza a solução de manutenção de Ola Hallengren.
* Reconstruções online vs. offline: considerar o tempo de atividade.
* É crucial testar em ambiente de desenvolvimento.

Este script visa otimizar a performance do banco de dados ao gerenciar a fragmentação dos índices de forma automatizada.
 ```sql
EXECUTE dbo.IndexOptimize
@Databases = 'AnalyticsPMais, AprovadosPoliedro, ARBTCEP, ARBTSecurity, BancoQuestoes_DW, Descontos_Academicos, EXTRACAOCRM_TOTVS, LogEducacional, Notificacoes, OLAP,
PortalEdros, Redacoes_DW, ReportServer, ReportServerTempDB, RPA_Financeiro, ServiceBroker, SSISDB',
@FragmentationLow = NULL,
@FragmentationMedium = 'INDEX_REORGANIZE,INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationHigh = 'INDEX_REBUILD_ONLINE,INDEX_REBUILD_OFFLINE',
@FragmentationLevel1 = 5,
@FragmentationLevel2 = 30,
@SortInTempdb = 'Y',
@MaxDOP = 0,
@LogToTable = 'Y'
```
