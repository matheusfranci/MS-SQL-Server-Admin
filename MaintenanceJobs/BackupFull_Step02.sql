IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[bkp_full_step_02]') AND type in (N'P', N'PC'))
   DROP PROCEDURE [dbo].[bkp_full_step_02]
GO
create procedure dbo.bkp_full_step_02 ( @backupdirectory nvarchar(200),@ONLY_DB VARCHAR(200) = null, @NOTIN_LIST VARCHAR(200) = null )
WITH ENCRYPTION AS
declare @data	         varchar(20)
declare @backupfile      varchar(255)
declare @backupfile2      varchar(255)
declare @backupfile3      varchar(255)
declare @db              varchar(200)
declare @description     varchar(255)
declare @name            varchar(30)
declare @medianame       varchar(30)
--declare @backupdirectory nvarchar(200)
declare @log_name        varchar(255)
declare @backupsetid	 int
declare @msg			 varchar(200)

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

--set @backupdirectory = 'F:\orion\BKP\DEFAULT\DATA\'
set @description     = 'Backup Full' + convert(varchar,getdate(),113)

declare database_cursor cursor fast_forward for 
SELECT NAME 
  FROM sys.databases
 WHERE name NOT IN ('tempdb')
   and name not in (select dbname from #notTempList)
   AND STATE = 0
--   AND DATABASEPROPERTY(NAME,'ISOFFLINE')       = 0
--   AND DATABASEPROPERTY(NAME,'IsInRecovery')    = 0
--   AND DATABASEPROPERTY(NAME,'IsInStandBy')     = 0
--   AND DATABASEPROPERTY(NAME,'IsDetached')      = 0
--   AND DATABASEPROPERTY(NAME,'ISSUSPECT')       = 0
--   AND DATABASEPROPERTY(NAME,'IsEmergencyMode') = 0
--   AND DATABASEPROPERTY(NAME,'IsInLoad')        = 0
--   AND DATABASEPROPERTY(NAME,'IsShutDown')      = 0
ORDER BY NAME

open database_cursor

if @@error <> 0
begin
	raiserror('ERRO NA ABERTURA DO CURSOR',16,1)
	return
end 

fetch next from database_cursor into @db

while @@fetch_status = 0
begin

IF(@ONLY_DB is not null and @DB <> @ONLY_DB)
	BEGIN
		FETCH NEXT FROM DATABASE_CURSOR INTO @DB
		CONTINUE
	END
	
set @data = convert(varchar,getdate(),112)

	set @backupfile  = @backupdirectory + @db +'_'+convert(varchar(30), @data, 112) + '_FULL-1.BAK' 
 	set @backupfile2 = @backupdirectory + @db +'_'+convert(varchar(30), @data, 112) + '_FULL-2.BAK'
	set @backupfile3 = @backupdirectory + @db +'_'+convert(varchar(30), @data, 112) + '_FULL-3.BAK'
	set @name        = @db + '(Daily BACKUP) ' + convert(varchar,@data,113)
--
select		@backupsetid = position 
	   from msdb..backupset 
      where database_name=@db and 
			backup_set_id=(select max(backup_set_id) 
							 from msdb..backupset 
							where database_name=@db )

if @backupsetid is null 
begin 
	set @msg='Verificação falhou. Informações para a base de dados '+ @db+ ' não foi encontrada.'
	raiserror(@msg, 16, 1) 
end
print 'Verificando '+@db+' as '+cast ( getdate() as char)
restore verifyonly from  disk = @backupfile,disk = @backupfile2 ,disk=@backupfile3
with  file = @backupsetid,  nounload,  norewind
 
 
 fetch next from database_cursor into @db
end
close database_cursor
deallocate database_cursor
go
