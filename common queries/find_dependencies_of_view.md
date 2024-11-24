### Descrição da Query

Esta consulta tem como objetivo identificar todas as dependências de objetos relacionadas a uma view (ou outro objeto SQL) específica, retornando as tabelas ou outros objetos que são referenciados pela view ou objeto em questão.

1. **Visão `sys.sql_expression_dependencies`**:
   - A visão `sys.sql_expression_dependencies` contém informações sobre as dependências de objetos no banco de dados. Ela armazena dados sobre objetos SQL que fazem referência a outros objetos, como tabelas, views e funções.
   
2. **Seleção de Dependências**:
   - A consulta seleciona três colunas:
     - `referenced_database_name`: O nome do banco de dados que está sendo referenciado.
     - `referenced_schema_name`: O esquema do objeto referenciado (por exemplo, dbo).
     - `referenced_entity_name`: O nome do objeto referenciado (por exemplo, uma tabela ou uma view).
   
3. **Filtragem pela View Específica**:
   - A cláusula `WHERE referencing_id = OBJECT_ID(N'nomedaview')` filtra as dependências para a view especificada. A função `OBJECT_ID` é usada para obter o ID do objeto associado ao nome da view fornecida, e a consulta retorna as dependências que fazem referência a essa view.
   
```SQL   
SELECT referenced_database_name,referenced_schema_name, referenced_entity_name FROM sys.sql_expression_dependencies
 WHERE referencing_id = OBJECT_ID(N'nomedaview');
```