sp_configure 'advanced options', 1
RECONFIGURE

SELECT * FROM sys.configurations WHERE name = 'SMO and DMO XPs'

sp_configure 'SMO and DMO XPs', 0 -- SQL-DMO (SQL Distributed Management Objects) / SMO (SQL Server Management Objects)
GO

RECONFIGURE
GO

