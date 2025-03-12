## Definição do procedimento armazenado `bkp_full_step_02` para verificar backups completos de bancos de dados.

```sql
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[bkp_full_step_02]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[bkp_full_step_02]
GO

CREATE PROCEDURE dbo.bkp_full_step_02 (
    @backupdirectory nvarchar(200),
    @ONLY_DB VARCHAR(200) = NULL,
    @NOTIN_LIST VARCHAR(200) = NULL
)
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @data VARCHAR(20);
    DECLARE @backupfile VARCHAR(255);
    DECLARE @backupfile2 VARCHAR(255);
    DECLARE @backupfile3 VARCHAR(255);
    DECLARE @db VARCHAR(200);
    DECLARE @description VARCHAR(255);
    DECLARE @name VARCHAR(30);
    DECLARE @medianame VARCHAR(30);
    DECLARE @log_name VARCHAR(255);
    DECLARE @backupsetid INT;
    DECLARE @msg VARCHAR(200);
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

    SET @description = 'Backup Full ' + CONVERT(VARCHAR, GETDATE(), 113);

    DECLARE database_cursor CURSOR FAST_FORWARD FOR
    SELECT NAME
    FROM sys.databases
    WHERE name NOT IN ('tempdb')
      AND name NOT IN (SELECT dbname FROM #notTempList)
      AND STATE = 0
    ORDER BY NAME;

    OPEN database_cursor;

    IF @@ERROR <> 0
    BEGIN
        RAISERROR('ERRO NA ABERTURA DO CURSOR', 16, 1);
        RETURN;
    END

    FETCH NEXT FROM database_cursor INTO @db;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF (@ONLY_DB IS NOT NULL AND @db <> @ONLY_DB)
        BEGIN
            FETCH NEXT FROM database_cursor INTO @db;
            CONTINUE;
        END

        SET @data = CONVERT(VARCHAR, GETDATE(), 112);
        SET @backupfile = @backupdirectory + @db + '_' + CONVERT(VARCHAR(30), @data, 112) + '_FULL-1.BAK';
        SET @backupfile2 = @backupdirectory + @db + '_' + CONVERT(VARCHAR(30), @data, 112) + '_FULL-2.BAK';
        SET @backupfile3 = @backupdirectory + @db + '_' + CONVERT(VARCHAR(30), @data, 112) + '_FULL-3.BAK';
        SET @name = @db + '(Daily BACKUP) ' + CONVERT(VARCHAR, @data, 113);

        SELECT @backupsetid = position
        FROM msdb..backupset
        WHERE database_name = @db
          AND backup_set_id = (SELECT MAX(backup_set_id)
                               FROM msdb..backupset
                               WHERE database_name = @db);

        IF @backupsetid IS NULL
        BEGIN
            SET @msg = 'Verificação falhou. Informações para a base de dados ' + @db + ' não foi encontrada.';
            RAISERROR(@msg, 16, 1);
        END

        PRINT 'Verificando ' + @db + ' as ' + CAST(GETDATE() AS CHAR);

        RESTORE VERIFYONLY
        FROM DISK = @backupfile, DISK = @backupfile2, DISK = @backupfile3
        WITH FILE = @backupsetid, NOUNLOAD, NOREWIND;

        FETCH NEXT FROM database_cursor INTO @db;
    END

    CLOSE database_cursor;
    DEALLOCATE database_cursor;
END
GO
