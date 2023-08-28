IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[bkp_full_step_03]') AND type in (N'P', N'PC'))
   DROP PROCEDURE [dbo].[bkp_full_step_03]
GO
create procedure dbo.bkp_full_step_03 ( @backupdirectory nvarchar(200), @diasretencao int )
WITH ENCRYPTION AS
declare @backupfile      varchar(255)
declare @db              varchar(200)
declare @description     varchar(255)
declare @name            varchar(30)
declare @medianame       varchar(30)
declare @log_name        varchar(255)
declare @backupsetid	 int
declare @msg			 varchar(200)
declare @comando		 varchar(2000)
declare @data varchar(10)
declare @hora			 varchar(10)

--set @backupdirectory = 'F:\BKP\DEFAULT\DATA\'
set @data=convert(varchar(10),getdate()- @diasretencao,121)
set @hora=convert(varchar(20),getdate(),108)

set @comando='execute master.dbo.xp_delete_file 0,''' + @backupdirectory + ''',''BAK'',''' + @data + 'T' + @hora + ''''
exec(@comando)
go
