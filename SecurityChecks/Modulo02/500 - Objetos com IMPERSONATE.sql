SELECT 
    B.[name],
    B.[type_desc],
    (CASE WHEN A.execute_as_principal_id = -2 THEN 'OWNER' ELSE C.[name] END) AS Ds_Execute_As
FROM
    sys.sql_modules A WITH(NOLOCK)
    JOIN sys.objects B WITH(NOLOCK) ON B.[object_id] = A.[object_id]
    LEFT JOIN sys.database_principals C WITH(NOLOCK) ON A.execute_as_principal_id = C.principal_id
WHERE
    A.execute_as_principal_id IS NOT NULL
    AND C.[name] <> 'dbo'
    AND B.is_ms_shipped = 0

	

EXEC sys.sp_MSforeachdb '
IF (''?'' <> ''tempdb'')
BEGIN

    SELECT 
        ''?'' AS Ds_Database,
        B.[name],
        B.[type_desc],
        (CASE WHEN A.execute_as_principal_id = -2 THEN ''OWNER'' ELSE C.[name] END) AS Ds_Execute_As
    FROM
        [?].sys.sql_modules A WITH(NOLOCK)
        JOIN [?].sys.objects B WITH(NOLOCK) ON B.[object_id] = A.[object_id]
        LEFT JOIN [?].sys.database_principals C WITH(NOLOCK) ON A.execute_as_principal_id = C.principal_id
    WHERE
        A.execute_as_principal_id IS NOT NULL
        AND C.[name] <> ''dbo''
        AND B.is_ms_shipped = 0
            
END'