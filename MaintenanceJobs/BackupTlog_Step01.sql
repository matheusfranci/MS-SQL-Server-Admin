IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[bkp_tlog_step_01]') AND type in (N'P', N'PC'))
   DROP PROCEDURE [dbo].bkp_tlog_step_01
GO
create procedure dbo.bkp_tlog_step_01 ( @backupdirectory nvarchar(200),@ONLY_DB VARCHAR(200) = null, @NOTIN_LIST VARCHAR(200) = null )
WITH ENCRYPTION AS
DECLARE @name VARCHAR(50) -- database name  
DECLARE @path nvarchar(200) -- path for backup files  
DECLARE @fileName VARCHAR(256) -- filename for backup  
DECLARE @fileDate VARCHAR(20) -- used for file name 
declare @patern varchar(30)

set @patern = '10.50.0000.1'
SET @path = @backupdirectory

CREATE TABLE #notTempList
	(
		dbname  VARCHAR(200)
	)

	DECLARE @dbname varchar(20), @Pos int

	SET @NOTIN_LIST = LTRIM(RTRIM(@NOTIN_LIST))+ ','
	SET @Pos = CHARINDEX(',', @NOTIN_LIST, 1)

	IF REPLACE(@NOTIN_LIST, ',', '') <> ''
	BEGIN
		WHILE @Pos > 0
		BEGIN
			SET @dbname = LTRIM(RTRIM(LEFT(@NOTIN_LIST, @Pos - 1)))
			IF @dbname <> ''
			BEGIN
				INSERT INTO #notTempList (dbname) VALUES (CAST(@dbname AS varchar(20))) --Use Appropriate conversion
			END
			SET @NOTIN_LIST = RIGHT(@NOTIN_LIST, LEN(@NOTIN_LIST) - @Pos)
			SET @Pos = CHARINDEX(',', @NOTIN_LIST, 1)

		END
	END	


SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 
   + '_' 
   + REPLACE(CONVERT(VARCHAR(20),GETDATE(),108),':','')

DECLARE db_cursor CURSOR FOR  
SELECT name 
FROM sys.databases
WHERE name NOT IN ('master','model','tempdb')
  and name not in (select dbname from #notTempList)
   AND recovery_model_desc IN ('FULL','BULK_LOGGED')
   AND STATE = 0
--   AND DATABASEPROPERTY(NAME,'ISOFFLINE')       = 0
--   AND DATABASEPROPERTY(NAME,'IsInRecovery')    = 0
--   AND DATABASEPROPERTY(NAME,'IsInStandBy')     = 0
--   AND DATABASEPROPERTY(NAME,'IsDetached')      = 0
--   AND DATABASEPROPERTY(NAME,'ISSUSPECT')       = 0
--   AND DATABASEPROPERTY(NAME,'IsEmergencyMode') = 0
--   AND DATABASEPROPERTY(NAME,'IsInLoad')        = 0
--   AND DATABASEPROPERTY(NAME,'IsShutDown')      = 0

OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name   

WHILE @@FETCH_STATUS = 0   
BEGIN   

IF(@ONLY_DB is not null and @name  <> @ONLY_DB)
	BEGIN
		FETCH NEXT FROM db_cursor INTO @name 
		CONTINUE
	END
	
       SET @fileName = @path + @name + '_' + @fileDate + '.TRN'  
       print @fileName
	   
	   if SERVERPROPERTY('productversion') >= @patern or charindex('enterprise',cast(SERVERPROPERTY ('edition') as varchar),0 ) <> 0 
	   begin
			BACKUP LOG @name TO DISK = @fileName  with compression
	   end
	   else
	   begin
			BACKUP LOG @name TO DISK = @fileName  -- with compression
	   end

       FETCH NEXT FROM db_cursor INTO @name   
END   

CLOSE db_cursor   
DEALLOCATE db_cursor
DROP TABLE #notTempList
go
