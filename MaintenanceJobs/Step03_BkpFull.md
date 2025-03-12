## Definição do procedimento armazenado `bkp_full_step_03` para excluir arquivos de backup antigos.

```sql
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[bkp_full_step_03]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[bkp_full_step_03]
GO

CREATE PROCEDURE dbo.bkp_full_step_03 (
    @backupdirectory nvarchar(200),
    @diasretencao int
)
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @backupfile VARCHAR(255);
    DECLARE @db VARCHAR(200);
    DECLARE @description VARCHAR(255);
    DECLARE @name VARCHAR(30);
    DECLARE @medianame VARCHAR(30);
    DECLARE @log_name VARCHAR(255);
    DECLARE @backupsetid INT;
    DECLARE @msg VARCHAR(200);
    DECLARE @comando VARCHAR(2000);
    DECLARE @data VARCHAR(10);
    DECLARE @hora VARCHAR(10);

    SET @data = CONVERT(VARCHAR(10), GETDATE() - @diasretencao, 121);
    SET @hora = CONVERT(VARCHAR(20), GETDATE(), 108);

    SET @comando = 'execute master.dbo.xp_delete_file 0, ''' + @backupdirectory + ''', ''BAK'', ''' + @data + 'T' + @hora + '''';
    EXEC(@comando);
END
GO
