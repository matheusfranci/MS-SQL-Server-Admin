
CREATE OR ALTER PROCEDURE dbo.stpRenova_Acessos
AS
BEGIN
	
	SELECT USER_NAME()

	GRANT SELECT, INSERT, UPDATE, DELETE TO [teste]

END










-- Validações do Checklist
IF (OBJECT_ID('tempdb.dbo.#Palavras_Grant') IS NOT NULL) DROP TABLE #Palavras_Grant
CREATE TABLE #Palavras_Grant (
	Palavra VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AI
)

INSERT INTO #Palavras_Grant
VALUES('%GRANT%'), ('%ALTER ROLE%'), ('%ALTER SERVER ROLE%'), ('%sp_addrolemember %'), ('%sp_addsrvrolemember %'), ('%sp_droprolemember %'), ('%sp_grantdbaccess %'), ('%sp_dbfixedrolepermission %') 



-------------------------------------
-- UMA BASE
-------------------------------------

SELECT TOP(100)
    B.[name],
    B.[type_desc]
FROM
    sys.sql_modules A WITH(NOLOCK)
    JOIN sys.objects B WITH(NOLOCK) ON B.[object_id] = A.[object_id]
	JOIN #Palavras_Grant C WITH(NOLOCK) ON A.[definition] COLLATE SQL_Latin1_General_CP1_CI_AI LIKE C.Palavra
WHERE
    B.is_ms_shipped = 0
    AND DB_NAME() NOT IN ('master', 'ReportServer')
    AND B.[name] NOT IN ('dt_addtosourcecontrol', 'dt_addtosourcecontrol_u', 'dt_adduserobject', 'dt_adduserobject_vcs', 'dt_checkinobject', 'dt_checkinobject_u', 'dt_checkoutobject', 'dt_checkoutobject_u', 'dt_displayoaerror', 'dt_displayoaerror_u', 'dt_droppropertiesbyid', 'dt_dropuserobjectbyid', 'dt_generateansiname', 'dt_getobjwithprop', 'dt_getobjwithprop_u', 'dt_getpropertiesbyid', 'dt_getpropertiesbyid_u', 'dt_getpropertiesbyid_vcs', 'dt_getpropertiesbyid_vcs_u', 'dt_isundersourcecontrol', 'dt_isundersourcecontrol_u', 'dt_removefromsourcecontrol', 'dt_setpropertybyid', 'dt_setpropertybyid_u', 'dt_validateloginparams', 'dt_validateloginparams_u', 'dt_vcsenabled', 'dt_verstamp006', 'dt_verstamp007', 'dt_whocheckedout', 'dt_whocheckedout_u', 'stpChecklist_Seguranca', 'stpSecurity_Checklist')
            



-------------------------------------
-- TODAS AS BASES
-------------------------------------

DECLARE @Objetos_Com_Grant TABLE ( [Ds_Database] nvarchar(256), [Ds_Objeto] nvarchar(256), [Ds_Tipo] nvarchar(128) )

INSERT INTO @Objetos_Com_Grant
EXEC sys.sp_MSforeachdb '
IF (''?'' <> ''tempdb'')
BEGIN

    SELECT TOP(100)
        ''?'' AS Ds_Database,
        B.[name],
        B.[type_desc]
    FROM
        [?].sys.sql_modules A WITH(NOLOCK)
        JOIN [?].sys.objects B WITH(NOLOCK) ON B.[object_id] = A.[object_id]
		JOIN #Palavras_Grant C WITH(NOLOCK) ON A.[definition] COLLATE SQL_Latin1_General_CP1_CI_AI LIKE C.Palavra
    WHERE
        B.is_ms_shipped = 0
        AND ''?'' NOT IN (''master'', ''ReportServer'')
        AND B.[name] NOT IN (''dt_addtosourcecontrol'', ''dt_addtosourcecontrol_u'', ''dt_adduserobject'', ''dt_adduserobject_vcs'', ''dt_checkinobject'', ''dt_checkinobject_u'', ''dt_checkoutobject'', ''dt_checkoutobject_u'', ''dt_displayoaerror'', ''dt_displayoaerror_u'', ''dt_droppropertiesbyid'', ''dt_dropuserobjectbyid'', ''dt_generateansiname'', ''dt_getobjwithprop'', ''dt_getobjwithprop_u'', ''dt_getpropertiesbyid'', ''dt_getpropertiesbyid_u'', ''dt_getpropertiesbyid_vcs'', ''dt_getpropertiesbyid_vcs_u'', ''dt_isundersourcecontrol'', ''dt_isundersourcecontrol_u'', ''dt_removefromsourcecontrol'', ''dt_setpropertybyid'', ''dt_setpropertybyid_u'', ''dt_validateloginparams'', ''dt_validateloginparams_u'', ''dt_vcsenabled'', ''dt_verstamp006'', ''dt_verstamp007'', ''dt_whocheckedout'', ''dt_whocheckedout_u'', ''stpChecklist_Seguranca'', ''stpSecurity_Checklist'')
            
END'


SELECT * FROM @Objetos_Com_Grant

