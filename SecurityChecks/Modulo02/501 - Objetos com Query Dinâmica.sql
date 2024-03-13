IF (OBJECT_ID('tempdb.dbo.#Palavras_Exec') IS NOT NULL) DROP TABLE #Palavras_Exec
CREATE TABLE #Palavras_Exec (
    Palavra VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AI
)

INSERT INTO #Palavras_Exec
VALUES('%EXEC (%'), ('%EXEC(%'), ('%EXECUTE (%'), ('%EXECUTE(%'), ('%sp_executesql%')


----------------------------------------------------
-- BASE ATUAL
----------------------------------------------------

SELECT DISTINCT TOP(100)
    B.[name],
    B.[type_desc]
FROM
    sys.sql_modules A WITH(NOLOCK)
    JOIN sys.objects B WITH(NOLOCK) ON B.[object_id] = A.[object_id]
    JOIN #Palavras_Exec C WITH(NOLOCK) ON A.[definition] COLLATE SQL_Latin1_General_CP1_CI_AI LIKE C.Palavra
WHERE
    B.is_ms_shipped = 0
    AND DB_NAME() <> 'ReportServer'
    AND B.[name] NOT IN ('stpChecklist_Seguranca', 'stpSecurity_Checklist', 'sp_WhoIsActive', 'sp_showindex', 'sp_AllNightLog', 'sp_AllNightLog_Setup', 'sp_Blitz', 'sp_BlitzBackups', 'sp_BlitzCache', 'sp_BlitzFirst', 'sp_BlitzIndex', 'sp_BlitzLock', 'sp_BlitzQueryStore', 'sp_BlitzWho', 'sp_DatabaseRestore')
    AND NOT (B.[name] LIKE 'stp_DTA_%' AND DB_NAME() = 'msdb')
    AND NOT (B.[name] = 'sp_readrequest' AND DB_NAME() = 'master')
    AND EXISTS (
        SELECT NULL
        FROM sys.parameters X1 WITH(NOLOCK)
        JOIN sys.types X2 WITH(NOLOCK) ON X1.system_type_id = X2.user_type_id
        WHERE A.[object_id] = X1.[object_id]
        AND X2.[name] IN ('text', 'ntext', 'varchar', 'nvarchar')
        AND (X1.max_length > 10 OR X1.max_length < 0)
    )


----------------------------------------------------
-- TODAS AS BASES
----------------------------------------------------

DECLARE @Objetos_Query_Dinamica TABLE ( [Ds_Database] nvarchar(256), [Ds_Objeto] nvarchar(256), [Ds_Tipo] nvarchar(128) )

INSERT INTO @Objetos_Query_Dinamica
EXEC sys.sp_MSforeachdb '
IF (''?'' <> ''tempdb'')
BEGIN

    SELECT DISTINCT TOP(100)
        ''?'' AS Ds_Database,
        B.[name],
        B.[type_desc]
    FROM
        [?].sys.sql_modules A WITH(NOLOCK)
        JOIN [?].sys.objects B WITH(NOLOCK) ON B.[object_id] = A.[object_id]
        JOIN #Palavras_Exec C WITH(NOLOCK) ON A.[definition] COLLATE SQL_Latin1_General_CP1_CI_AI LIKE C.Palavra
    WHERE
        B.is_ms_shipped = 0
        AND ''?'' <> ''ReportServer''
        AND B.[name] NOT IN (''stpChecklist_Seguranca'', ''stpSecurity_Checklist'', ''sp_WhoIsActive'', ''sp_showindex'', ''sp_AllNightLog'', ''sp_AllNightLog_Setup'', ''sp_Blitz'', ''sp_BlitzBackups'', ''sp_BlitzCache'', ''sp_BlitzFirst'', ''sp_BlitzIndex'', ''sp_BlitzLock'', ''sp_BlitzQueryStore'', ''sp_BlitzWho'', ''sp_DatabaseRestore'')
        AND NOT (B.[name] LIKE ''stp_DTA_%'' AND ''?'' = ''msdb'')
        AND NOT (B.[name] = ''sp_readrequest'' AND ''?'' = ''master'')
        AND EXISTS (
            SELECT NULL
            FROM [?].sys.parameters X1 WITH(NOLOCK)
            JOIN [?].sys.types X2 WITH(NOLOCK) ON X1.system_type_id = X2.user_type_id
            WHERE A.[object_id] = X1.[object_id]
            AND X2.[name] IN (''text'', ''ntext'', ''varchar'', ''nvarchar'')
            AND (X1.max_length > 10 OR X1.max_length < 0)
        )
            
END'