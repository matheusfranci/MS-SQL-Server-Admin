### Descrição da Query

Esta query cria uma tabela temporária `#UsingLS` para armazenar informações sobre objetos no banco de dados que utilizam servidores vinculados (`Linked Server`). Ela executa o comando `sp_MSforeachdb` para iterar sobre todos os bancos de dados, verificando objetos que fazem referência a servidores vinculados em suas definições.

A query realiza o seguinte:
- Cria uma tabela temporária para armazenar o nome do servidor vinculado, fonte de dados do servidor vinculado, nome do objeto (procedimento armazenado, view, trigger ou função), tipo do objeto e o nome do banco de dados.
- Para cada banco de dados, executa consultas que buscam em procedimentos armazenados, views, triggers e funções por referências a servidores vinculados (`sys.servers`).
- São usadas consultas `LIKE` para verificar se o nome do servidor ou a fonte de dados estão presentes na definição do objeto.
- No final, os resultados são exibidos e a tabela temporária é descartada.

```SQL
CREATE TABLE #UsingLS(
LinkedServerName VARCHAR(MAX),
LinkedServerDataSource VARCHAR(MAX),
ObjectName VARCHAR(MAX),
Object_Type VARCHAR(MAX),
Database_Name VARCHAR(MAX))
INSERT INTO #UsingLS
EXEC sp_MSforeachdb
'Use [?]
SELECT SRV.[name] AS LinkedServerName
	, SRV.[data_source] AS LinkedServerDataSource
	, PRO.[name] AS ObjectName
	, "Stored Procedure" AS ObjectType
	,DB_NAME() AS Database_Name
FROM sys.servers SRV
	INNER JOIN sys.procedures PRO
		ON (OBJECT_DEFINITION(PRO.[object_id]) LIKE ("%" + SRV.[name] + "%")
			OR OBJECT_DEFINITION(PRO.[object_id]) LIKE ("%" + SRV.[data_source] + "%"))
UNION
SELECT SRV.[name] AS LinkedServerName
	, SRV.[data_source] AS LinkedServerDataSource
	, PRO.[name] AS ObjectName
	, "View" AS ObjectType
	,DB_NAME() AS Database_Name
FROM sys.servers SRV
	INNER JOIN sys.views PRO
		ON (OBJECT_DEFINITION(PRO.[object_id]) LIKE ("%" + SRV.[name] + "%")
			OR OBJECT_DEFINITION(PRO.[object_id]) LIKE ("%" + SRV.[data_source] + "%"))
UNION
SELECT SRV.[name] AS LinkedServerName
	, SRV.[data_source] AS LinkedServerDataSource
	, PRO.[name] AS ObjectName
	, "Trigger" AS ObjectType
	,DB_NAME() AS Database_Name
FROM sys.servers SRV
	INNER JOIN sys.triggers PRO
		ON (OBJECT_DEFINITION(PRO.[object_id]) LIKE ("%" + SRV.[name] + "%")
			OR OBJECT_DEFINITION(PRO.[object_id]) LIKE ("%" + SRV.[data_source] + "%"))
UNION
SELECT SRV.[name] AS LinkedServerName
	, SRV.[data_source] AS LinkedServerDataSource
	, PRO.[name] AS ObjectName
	, "Function" AS ObjectType
	,DB_NAME() AS Database_Name
FROM sys.servers SRV
	INNER JOIN sys.objects PRO
		ON (OBJECT_DEFINITION(PRO.[object_id]) LIKE ("%" + SRV.[name] + "%")
			OR OBJECT_DEFINITION(PRO.[object_id]) LIKE ("%" + SRV.[data_source] + "%"))
WHERE PRO.[type] in ("FN", "IF", "FN", "AF", "FS", "FT");'
SELECT * FROM #UsingLS
DROP TABLE #UsingLS
```