### Descrição da Query

Esta consulta tem como objetivo buscar, em todas as bases de dados de um servidor SQL, a tabela chamada **ent_auto_terc** e retornar o nome do banco e o nome da tabela para cada instância onde a tabela existe. O processo ocorre da seguinte forma:

1. **Criação da Tabela Temporária (`#TABLERESULT`)**:
   - A tabela temporária é criada para armazenar os resultados, com duas colunas:
     - `DatabaseName`: Nome do banco de dados.
     - `TableName`: Nome da tabela (que será fixo, "ent_auto_terc").
   
2. **Execução da Procedure `sp_MSforeachdb`**:
   - A `sp_MSforeachdb` é usada para iterar sobre cada banco de dados presente no servidor.
   - Para cada banco de dados, a consulta executa o comando `USE [?]`, que seleciona o banco de dados atual.
   - Em seguida, a consulta executa uma busca na visão `INFORMATION_SCHEMA.TABLES` para encontrar a tabela **ent_auto_terc** (do tipo `BASE TABLE`).
   - O resultado de cada execução é inserido na tabela temporária `#TABLERESULT`, contendo o nome do banco e o nome da tabela encontrada.

3. **Exibição dos Resultados**:
   - Após a execução da procedure, a consulta seleciona os dados da tabela temporária para exibir quais bancos de dados contêm a tabela **ent_auto_terc**.
   
```SQL
CREATE TABLE #TABLERESULT (
DatabaseName VARCHAR(MAX),
TableName VARCHAR(MAX)
)
INSERT INTO #TABLERESULT
EXEC master.sys.sp_MSforeachdb 
'USE [?]
SELECT 
DB_NAME() AS DatabaseName,
table_name as TableName
FROM INFORMATION_SCHEMA.TABLES
WHERE table_type = "BASE TABLE"
AND TABLE_NAME = "ent_auto_terc"'
GO
SELECT * FROM #TABLERESULT
GO
DROP TABLE #TABLERESULT
```