## Definição do procedimento armazenado `bkp_full_step_01` para realizar backups completos de bancos de dados.

```sql
USE Database_Name
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[bkp_full_step_01]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[bkp_full_step_01]
GO

CREATE PROCEDURE dbo.bkp_full_step_01 (
    @backupdirectory nvarchar(200),
    @ONLY_DB VARCHAR(200) = NULL,
    @NOTIN_LIST VARCHAR(200) = NULL
)
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BACKUPFILE VARCHAR(255);
    DECLARE @BACKUPFILE2 VARCHAR(255);
    DECLARE @BACKUPFILE3 VARCHAR(255);
    DECLARE @DB VARCHAR(200);
    DECLARE @DESCRIPTION VARCHAR(255);
    DECLARE @NAME VARCHAR(30);
    DECLARE @data VARCHAR(20);
    DECLARE @patern VARCHAR(30);
    DECLARE @dbname VARCHAR(200);
    DECLARE @Pos INT;

    CREATE TABLE #notTempList (
        dbname VARCHAR(200)
    );

    SET @NOTIN_LIST = LTRIM(RTRIM(@NOTIN_LIST)) + ',';
    SET @Pos = CHARINDEX(',', @NOTIN_LIST, 1);

    IF REPLACE(@NOTIN_LIST, ',', '') <> ''
    BEGIN
        WHILE @Pos > 0
        BEGIN
            SET @dbname = LTRIM(RTRIM(LEFT(@NOTIN_LIST, @Pos - 1)));
            IF @dbname <> ''
            BEGIN
                INSERT INTO #notTempList (dbname) VALUES (CAST(@dbname AS VARCHAR(20)));
            END
            SET @NOTIN_LIST = RIGHT(@NOTIN_LIST, LEN(@NOTIN_LIST) - @Pos);
            SET @Pos = CHARINDEX(',', @NOTIN_LIST, 1);
        END
    END

    SET @patern = '10.50.0000.1';
    SET @data = CONVERT(VARCHAR, GETDATE(), 112);
    SET @DESCRIPTION = 'BACKUP FULL ' + CONVERT(VARCHAR, GETDATE(), 113);

    DECLARE DATABASE_CURSOR CURSOR FAST_FORWARD FOR
    SELECT NAME
    FROM sys.databases
    WHERE name NOT IN ('tempdb')
      AND name NOT IN (SELECT dbname FROM #notTempList)
      AND STATE = 0
    ORDER BY NAME;

    OPEN DATABASE_CURSOR;

    IF @@ERROR <> 0
    BEGIN
        RAISERROR('ERRO NA ABERTURA DO CURSOR', 16, 1);
        RETURN;
    END

    FETCH NEXT FROM DATABASE_CURSOR INTO @DB;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF (@ONLY_DB IS NOT NULL AND @DB <> @ONLY_DB)
        BEGIN
            FETCH NEXT FROM DATABASE_CURSOR INTO @DB;
            CONTINUE;
        END

        SET @BACKUPFILE = @backupdirectory + @DB + '_' + CONVERT(VARCHAR(30), @data, 112) + '_FULL-1.BAK';
        SET @BACKUPFILE2 = @backupdirectory + @DB + '_' + CONVERT(VARCHAR(30), @data, 112) + '_FULL-2.BAK';
        SET @BACKUPFILE3 = @backupdirectory + @DB + '_' + CONVERT(VARCHAR(30), @data, 112) + '_FULL-3.BAK';
        SET @NAME = @DB + '(DAILY BACKUP) ' + CONVERT(VARCHAR, GETDATE(), 113);

        PRINT 'INICIO DO BACKUP DA BASE ' + @DB + ' AS ' + CAST(GETDATE() AS CHAR);

        IF SERVERPROPERTY('productversion') >= @patern OR CHARINDEX('enterprise', CAST(SERVERPROPERTY('edition') AS VARCHAR), 0) <> 0
        BEGIN
            BACKUP DATABASE @DB TO
                DISK = @BACKUPFILE, DISK = @BACKUPFILE2, DISK = @BACKUPFILE3
            WITH INIT, NOFORMAT, NOUNLOAD, COMPRESSION, SKIP, NAME = @NAME, DESCRIPTION = @DESCRIPTION;
        END
        ELSE
        BEGIN
            BACKUP DATABASE @DB TO
                DISK = @BACKUPFILE, DISK = @BACKUPFILE2, DISK = @BACKUPFILE3
            WITH INIT, NOFORMAT, NOUNLOAD, SKIP, NAME = @NAME, DESCRIPTION = @DESCRIPTION;
        END

        PRINT 'FIM DO BACKUP DA BASE ' + @DB + ' AS ' + CAST(GETDATE() AS CHAR);
        FETCH NEXT FROM DATABASE_CURSOR INTO @DB;
    END

    CLOSE DATABASE_CURSOR;
    DEALLOCATE DATABASE_CURSOR;
END
GO
