IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[orion_bkp_tlog_step_02]') AND type in (N'P', N'PC'))
   DROP PROCEDURE [dbo].orion_bkp_tlog_step_02
GO

create procedure dbo.orion_bkp_tlog_step_02 ( @backupdirectory nvarchar(200), @diasexpurgo int = 3 )
WITH ENCRYPTION AS
declare @BackupFile      varchar(255)
--declare @backupdirectory nvarchar(200)
declare @comando		 varchar(2000)
declare @data			 varchar(30)
declare @hora			 varchar(10)

set @data=convert(varchar(10),getdate() - @diasexpurgo,121)
set @hora=CONVERT(VARCHAR(20),GETDATE(),108)

set @comando='EXECUTE master.dbo.xp_delete_file 0,'''+@backupdirectory +''','+'''trn'','''+@data+'T'+@hora+''''
 
exec(@comando)
go
