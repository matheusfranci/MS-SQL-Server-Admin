```markdown
# Consulta SQL Server: Dependências de Objetos

Esta consulta SQL Server recupera as dependências do objeto `schema_a.objeto_b`. Ela utiliza uma Expressão de Tabela Comum (CTE) para encontrar recursivamente todos os objetos dos quais o objeto especificado depende, juntamente com suas respectivas profundidades.

## Consulta

```sql
WITH Dependencies AS (
    SELECT
        OBJECT_ID('schema_a.objeto_b') AS object_id,
        DB_NAME() AS database_name,
        s.name AS schema_name,
        o.name AS object_name,
        0 AS depth
    FROM sys.objects o
    JOIN sys.schemas s ON o.schema_id = s.schema_id
    WHERE o.object_id = OBJECT_ID('schema_a.objeto_b')

    UNION ALL

    SELECT
        d.referenced_id,
        DB_NAME() AS database_name,
        s.name AS schema_name,
        o.name AS object_name,
        depth + 1
    FROM sys.sql_expression_dependencies d
    INNER JOIN Dependencies dep ON d.referencing_id = dep.object_id
    JOIN sys.objects o ON d.referenced_id = o.object_id
    JOIN sys.schemas s ON o.schema_id = s.schema_id
)
SELECT database_name, schema_name, object_name, depth
FROM Dependencies
WHERE object_id IS NOT NULL
ORDER BY depth;
```

## Explicação

1.  **CTE (Dependencies):**
    * **Caso Base:**
        * Seleciona o objeto inicial (`schema_a.objeto_b`).
        * Recupera o nome do banco de dados, o nome do esquema e o nome do objeto.
        * Define a profundidade inicial como 0.
    * **Caso Recursivo:**
        * Une `sys.sql_expression_dependencies` com a CTE `Dependencies`.
        * Recupera o `referenced_id` (o objeto do qual o objeto atual depende).
        * Recupera o nome do banco de dados, o nome do esquema e o nome do objeto do objeto referenciado.
        * Incrementa a profundidade em 1.
2.  **Instrução SELECT Final:**
    * Seleciona o nome do banco de dados, o nome do esquema, o nome do objeto e a profundidade da CTE `Dependencies`.
    * Filtra as linhas onde `object_id` é `NULL`.
    * Ordena os resultados por profundidade.

## Uso

Esta consulta é útil para entender os relacionamentos entre objetos de banco de dados, particularmente em cenários envolvendo data warehousing e processos ETL. Ela ajuda a identificar todas as tabelas, views ou outros objetos que são usados por um objeto específico, e o nível de dependência.

## Tabelas Usadas

* `sys.objects`
* `sys.schemas`
* `sys.sql_expression_dependencies`

## Saída

A consulta retorna uma tabela com as seguintes colunas:

* `database_name`: O nome do banco de dados.
* `schema_name`: O nome do esquema.
* `object_name`: O nome do objeto.
* `depth`: A profundidade da dependência.
```
