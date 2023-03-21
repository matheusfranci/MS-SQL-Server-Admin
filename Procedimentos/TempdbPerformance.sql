-- Liberação do Tempdb
USE [tempdb]
GO
DBCC FREEPROCCACHE
GO
DBCC SHRINKDATABASE(N'tempdb' )
GO
USE [tempdb]
GO
DBCC SHRINKFILE (N'tempdev' , 0, TRUNCATEONLY)
GO
USE [tempdb]
GO
DBCC SHRINKFILE (N'templog' , 0, TRUNCATEONLY)
GO

--  Liberação do cache em segundo plano 
 DBCC FREEPROCCACHE
 
 -- Atualização de estatísticas
 exec sp_updatestats
