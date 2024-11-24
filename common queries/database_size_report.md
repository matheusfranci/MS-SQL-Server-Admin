### Descrição da Query

Esta consulta é utilizada para obter o tamanho em megabytes (MB) de cada banco de dados no SQL Server.

1. **Seleciona o Nome do Banco**:
   - `sys.databases.name AS [Banco]`: Retorna o nome de cada banco de dados presente no servidor.

2. **Calcula o Tamanho dos Bancos de Dados**:
   - `CONVERT(VARCHAR,SUM(size)*8/1024) AS [Tamanho em MB]`: A consulta utiliza a tabela `sys.master_files` para calcular o tamanho dos arquivos de dados dos bancos de dados.
     - A coluna `size` na tabela `sys.master_files` representa o tamanho do arquivo em 8 KB. 
     - Multiplicando o valor por 8 e dividindo por 1024, converte-se o tamanho para MB.

3. **Realiza o `JOIN` entre as Tabelas**:
   - A consulta realiza um `JOIN` entre as tabelas `sys.databases` e `sys.master_files` utilizando a chave `database_id`. Isso permite associar o tamanho de cada arquivo com seu respectivo banco de dados.

4. **Agrupamento por Banco de Dados**:
   - `GROUP BY sys.databases.name`: Agrupa os resultados pelo nome do banco de dados, permitindo calcular o tamanho total para cada banco.

5. **Ordenação pelos Nomes dos Bancos**:
   - `ORDER BY sys.databases.name`: Ordena os resultados pelo nome dos bancos de dados de forma crescente.
   
```SQL
SELECT      sys.databases.name AS [Banco], 
        CONVERT(VARCHAR,SUM(size)*8/1024) AS [Tamanho em MB]  
     FROM        sys.databases   
     JOIN        sys.master_files  
     ON          sys.databases.database_id=sys.master_files.database_id  
     GROUP BY    sys.databases.name  
     ORDER BY    sys.databases.name;
```