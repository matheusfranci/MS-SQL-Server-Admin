### Descrição
Essa query permite consultar queries com determinado nome de procedimentos armazenados (*stored procedures*) em um banco de dados específico. Ela busca todas as procedures cujo conteúdo contenha o termo **"Nomedaproc"**.

### Detalhes
1. **`USE Database_name`:** Define o banco de dados no qual a consulta será executada.
2. **`sys.procedures`:** Exibe informações sobre todas as procedures armazenadas no banco.
3. **`OBJECT_DEFINITION(object_id)`:** Retorna o texto SQL de cada procedure.
4. **`WHERE ... LIKE '%Nomedaproc%'`:** Filtra as procedures que contêm o termo especificado no texto SQL.

### Exemplo de Uso
```sql
USE Database_name;
SELECT
    name,
    OBJECT_DEFINITION(object_id) AS "SQL Text"
FROM
    sys.procedures
WHERE
    OBJECT_DEFINITION(object_id) LIKE '%Nomedaproc%';
```