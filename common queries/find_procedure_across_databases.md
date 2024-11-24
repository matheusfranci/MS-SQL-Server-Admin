### Descrição
Essa query executa uma busca em todos os bancos de dados da instância SQL Server para localizar informações sobre procedures específicas que contenham o termo **"ProcedureXPTO"** no nome.

### Detalhes
1. **`CREATE TABLE #tmpprocesult`:** Cria uma tabela temporária para armazenar os resultados da consulta.
2. **`SP_MSFOREACHDB`:** Procedimento interno do SQL Server usado para iterar por todos os bancos de dados da instância.
3. **`sys.procedures`:** Contém informações sobre procedures armazenadas em cada banco de dados.
4. **`WHERE name LIKE '%IT4CarregaDocumentosWMS_Diagonal%'`:** Filtra as procedures cujo nome contém o termo especificado.
5. **`SELECT * FROM #tmpprocesult`:** Retorna os resultados consolidados da busca.
6. **`DROP TABLE #tmpprocesult`:** Remove a tabela temporária após o uso.

### Exemplo de Uso
```sql
CREATE TABLE #tmpprocesult
(
    Banco VARCHAR(MAX),
    name VARCHAR(MAX),
    type_desc VARCHAR(MAX),
    create_date DATE,
    modify_date DATE
);

INSERT INTO #tmpprocesult
EXEC SP_MSFOREACHDB '
USE [?]
SELECT
    DB_NAME() AS Banco,
    name,
    type_desc,
    create_date,
    modify_date
FROM 
    sys.procedures 
WHERE 
    name LIKE "%ProcedureXPTO%";';

SELECT * FROM #tmpprocesult;

DROP TABLE #tmpprocesult;
```