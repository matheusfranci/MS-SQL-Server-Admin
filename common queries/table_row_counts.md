
markdown
Copiar código
### Descrição da Query

Esta query tem como objetivo obter uma contagem do número de linhas para cada tabela em um banco de dados e exibir as tabelas com contagem maior que zero, ordenadas por nome da tabela e quantidade de linhas (de forma decrescente). O processo é realizado em duas etapas:

1. **Criação da tabela temporária `#counts`**: Uma tabela temporária é criada para armazenar o nome da tabela e o número de linhas de cada tabela.
2. **Execução do comando `sp_MSForEachTable`**: Utiliza o procedimento armazenado `sp_MSForEachTable` para percorrer todas as tabelas do banco de dados. Para cada tabela, ele insere na tabela temporária `#counts` o nome da tabela e a quantidade de linhas (`COUNT(*)`).
3. **Seleção dos resultados**: A consulta finaliza selecionando as tabelas com contagem maior que zero, ordenadas pela quantidade de linhas de forma decrescente.
4. **Limpeza**: A tabela temporária `#counts` é excluída após a execução.

```SQL
CREATE TABLE #counts
(
    table_name varchar(255),
    row_count int
)

EXEC sp_MSForEachTable @command1='INSERT #counts (table_name, row_count) SELECT ''?'', COUNT(*) FROM ?'
SELECT table_name, row_count FROM #counts WHERE ROW_COUNT > 0 ORDER BY table_name, row_count DESC
DROP TABLE #counts
```