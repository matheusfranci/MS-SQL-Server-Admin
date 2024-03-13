
SELECT TOP 100
    B.[name],
    B.[type_desc]
FROM
    sys.sql_modules A WITH(NOLOCK)
    JOIN sys.objects B WITH(NOLOCK) ON B.[object_id] = A.[object_id]
WHERE
    B.is_ms_shipped = 0
    AND B.[name] NOT IN ('stpChecklist_Seguranca', 'stpSecurity_Checklist', 'sp_WhoIsActive', 'sp_showindex', 'sp_AllNightLog', 'sp_AllNightLog_Setup', 'sp_Blitz', 'sp_BlitzBackups', 'sp_BlitzCache', 'sp_BlitzFirst', 'sp_BlitzIndex', 'sp_BlitzLock', 'sp_BlitzQueryStore', 'sp_BlitzWho', 'sp_DatabaseRestore')
    AND A.[definition] LIKE '%xp_cmdmshell%'



DECLARE @Objetos_xp_cmdshell TABLE ( [Ds_Database] nvarchar(256), [Ds_Objeto] nvarchar(256), [Ds_Tipo] nvarchar(128) )

INSERT INTO @Objetos_xp_cmdshell
EXEC sys.sp_MSforeachdb '
IF (''?'' <> ''tempdb'')
BEGIN

    SELECT TOP 100
        ''?'' AS Ds_Database,
        B.[name],
        B.[type_desc]
    FROM
        [?].sys.sql_modules A WITH(NOLOCK)
        JOIN [?].sys.objects B WITH(NOLOCK) ON B.[object_id] = A.[object_id]
    WHERE
        B.is_ms_shipped = 0
        AND ''?'' <> ''ReportServer''
        AND B.[name] NOT IN (''stpChecklist_Seguranca'', ''stpSecurity_Checklist'', ''sp_WhoIsActive'', ''sp_showindex'', ''sp_AllNightLog'', ''sp_AllNightLog_Setup'', ''sp_Blitz'', ''sp_BlitzBackups'', ''sp_BlitzCache'', ''sp_BlitzFirst'', ''sp_BlitzIndex'', ''sp_BlitzLock'', ''sp_BlitzQueryStore'', ''sp_BlitzWho'', ''sp_DatabaseRestore'')
        AND A.definition LIKE ''%xp_cmdmshell%''
    
END