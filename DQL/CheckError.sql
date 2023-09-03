DECLARE @logFileType SMALLINT= 1;
DECLARE @start DATETIME;
DECLARE @end DATETIME;
DECLARE @logno INT= 0;
SET @start = '2019-11-07 00:00:01.000';
SET @end = '2023-09-03 00:00:00.000';
DECLARE @searchString1 NVARCHAR(256)= 'Error';
DECLARE @searchString2 NVARCHAR(256)= 'MSDB';
EXEC master.dbo.xp_readerrorlog 
     @logno, 
     @logFileType, 
     @searchString1, 
     @searchString2, 
     @start, 
     @end;
