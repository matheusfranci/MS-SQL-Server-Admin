# Descrição da Procedure de Renovação de Acessos e Validação de Permissões

Esta procedure tem como objetivo realizar a concessão de permissões e verificar a presença de determinados comandos relacionados a permissões em objetos no banco de dados, além de realizar validações em todas as bases de dados do servidor.

## Explicação do Script

1. **Criação ou Alteração da Procedure `stpRenova_Acessos`**:
   - A procedure inicia com a concessão das permissões `SELECT`, `INSERT`, `UPDATE` e `DELETE` ao usuário `teste`.
   - Antes disso, a função `USER_NAME()` é executada para retornar o nome do usuário atual.

2. **Validação de Palavras-chave de Permissões**:
   - É criada uma tabela temporária `#Palavras_Grant` que contém palavras-chave relacionadas a comandos de concessão de permissões, como `GRANT`, `ALTER ROLE`, e outras.
   - A tabela é preenchida com os padrões que serão utilizados para buscar esses comandos nas definições de objetos.

3. **Verificação de Objetos na Base Atual**:
   - A consulta busca nos módulos SQL da base de dados atual (excluindo sistemas e algumas funções predefinidas) objetos que contêm as palavras-chave de concessão de permissões em sua definição.
   - Os objetos que atendem a essa condição são listados, juntamente com o nome e tipo.

4. **Verificação de Objetos em Todas as Bases de Dados**:
   - Uma tabela de objetos com permissões é criada para armazenar resultados de todas as bases de dados no servidor.
   - A procedure utiliza `sp_MSforeachdb` para iterar por todas as bases de dados, excluindo as bases de sistema e algumas outras específicas, verificando se os objetos contêm as palavras-chave relacionadas a permissões.

5. **Resultado Esperado**:
   - O script retorna duas listas de objetos:
     1. Os objetos da base de dados atual que contêm palavras-chave relacionadas a permissões.
     2. Os objetos de todas as bases de dados que contêm essas palavras-chave.

## Observações
- **Segurança**: O script se preocupa em evitar a execução de objetos de sistema e objetos críticos de outras bases de dados (como `master` e `ReportServer`).
- **Tabela Temporária**: A tabela `#Palavras_Grant` é criada para armazenar as palavras-chave usadas na busca dos objetos.
- **Usabilidade**: O uso de `sp_MSforeachdb` permite que o script seja executado em todas as bases de dados de forma dinâmica.

```sql
CREATE OR ALTER PROCEDURE dbo.stpRenova_Acessos
AS
BEGIN
	
	SELECT USER_NAME()

	GRANT SELECT, INSERT, UPDATE, DELETE TO [teste]

END
```

```sql
-- Validações do Checklist
IF (OBJECT_ID('tempdb.dbo.#Palavras_Grant') IS NOT NULL) DROP TABLE #Palavras_Grant
CREATE TABLE #Palavras_Grant (
	Palavra VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AI
)

INSERT INTO #Palavras_Grant
VALUES('%GRANT%'), ('%ALTER ROLE%'), ('%ALTER SERVER ROLE%'), ('%sp_addrolemember %'), ('%sp_addsrvrolemember %'), ('%sp_droprolemember %'), ('%sp_grantdbaccess %'), ('%sp_dbfixedrolepermission %') 
```

```sql
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
```

```sql         
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
```

```sql
SELECT * FROM @Objetos_Com_Grant
```