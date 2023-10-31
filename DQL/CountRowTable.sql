-- Criando uma tabela temporária para armazena o schema + table para que não seja necessário especificar todos dentro do WHERE NAME IN
CREATE TABLE #StoredTableName (
"Schema" VARCHAR(MAX),
Tabela VARCHAR(MAX),
Contatenada VARCHAR(MAX));

-- Inserindo todas as tabelas presentes no banco
INSERT INTO #StoredTableName
SELECT DISTINCT SCH.NAME AS 'Schema',
O.NAME AS 'Tabela',
CONCAT(SCH.NAME, '.', o.NAME) AS 'Concatenada'
FROM SYS.OBJECTS O
INNER JOIN SYS.SCHEMAS SCH ON SCH.schema_id = O.schema_id
WHERE O.TYPE = 'U'; -- Tipo de objeto é user table

-- Apenas com o nome da tabela
SELECT DISTINCT 
O.NAME as Tabelas, 
S.ROW_COUNT as Tuplas 
FROM  sys.dm_db_partition_stats S
INNER JOIN SYS.OBJECTS O ON O.OBJECT_ID = S.OBJECT_ID 
INNER JOIN SYS.SCHEMAS SC ON SC.SCHEMA_ID = O.SCHEMA_ID
WHERE CONCAT(sc.name, '.', o.name) IN (SELECT Contatenada COLLATE Latin1_General_CI_AS  FROM #StoredTableName) -- Pode haver erro de collation então altere de acordo com a necessidade.
-- No banco S2 O COLLATION era diferente do da tabela temporária, caso isso ocorra o sql server apontará o erro.
