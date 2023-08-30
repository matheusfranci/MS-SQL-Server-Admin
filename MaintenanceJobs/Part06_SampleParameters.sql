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
