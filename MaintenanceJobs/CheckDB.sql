EXEC master.sys.sp_MSforeachdb
'USE [?]
DBCC CHECKDB WITH DATA_PURITY'
