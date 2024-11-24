### Descrição da Query
Esta consulta tem como objetivo contar o número de tuplas (linhas) de tabelas específicas em um banco de dados, onde as tabelas são armazenadas previamente em uma tabela temporária para evitar a repetição de nomes no `WHERE`.

1. **Criação da Tabela Temporária `#StoredTableName`**:
   - A tabela temporária armazena o schema e o nome das tabelas, além de uma coluna concatenada que junta o schema e o nome da tabela.

2. **Inserção dos Dados na Tabela Temporária**:
   - São inseridas todas as tabelas de usuário (`TYPE = 'U'`) presentes no banco, com o nome do schema, o nome da tabela e a versão concatenada do schema e tabela.
   - A consulta utiliza a visão `SYS.OBJECTS` para obter as tabelas e a visão `SYS.SCHEMAS` para mapear os schemas dessas tabelas.

3. **Contagem das Tuplas (Linhas)**:
   - A segunda parte da consulta realiza a contagem do número de linhas (tuplas) de cada tabela armazenada na tabela temporária.
   - A consulta faz um `JOIN` entre a visão `sys.dm_db_partition_stats` (que contém estatísticas de partições de tabelas) e as visões `SYS.OBJECTS` e `SYS.SCHEMAS` para acessar informações sobre as tabelas e schemas.
   - O filtro `CONCAT(sc.name, '.', o.name) IN (SELECT Contatenada)` permite selecionar apenas as tabelas armazenadas na tabela temporária.
   - A cláusula `COLLATE Latin1_General_CI_AS` foi adicionada para resolver possíveis problemas de collation, caso o banco e a tabela temporária possuam collations diferentes.

```SQL
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
```