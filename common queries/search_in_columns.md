### Descrição
Este script utiliza um cursor para pesquisar por um valor específico em todas as colunas do tipo `varchar` ou `nvarchar` em todas as tabelas do banco de dados. Ele verifica se o valor de pesquisa existe nessas colunas e imprime o nome da tabela e da coluna caso o valor seja encontrado.

### Explicação do Script
1. **Declaração de variáveis:**  
   - `@search`: valor a ser procurado nas colunas.
   - `@table`: armazena o nome completo da tabela (esquema e nome da tabela).
   - `@column`: nome da coluna onde será realizada a busca.

2. **Cursor `curTabCol`:**  
   O cursor seleciona as tabelas e colunas do tipo `varchar` e `nvarchar` no banco de dados, filtrando apenas as tabelas do tipo "BASE TABLE" (para evitar views).

3. **Busca e execução:**  
   Para cada tabela e coluna retornada pelo cursor, o script executa uma consulta dinâmica, verificando se o valor de pesquisa existe na coluna específica. Se o valor for encontrado, imprime o nome da tabela e da coluna.

4. **Finalização do cursor:**  
   Após a execução da consulta para todas as tabelas e colunas, o cursor é fechado e desalocado.

```SQL
DECLARE @search VARCHAR(100), @table SYSNAME, @column SYSNAME

DECLARE curTabCol CURSOR FOR
    SELECT c.TABLE_SCHEMA + '.' + c.TABLE_NAME, c.COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS c
    JOIN INFORMATION_SCHEMA.TABLES t 
      ON t.TABLE_NAME=c.TABLE_NAME AND t.TABLE_TYPE='BASE TABLE' -- avoid views
    WHERE c.DATA_TYPE IN ('varchar','nvarchar') -- searching only in these column types
    --AND c.COLUMN_NAME IN ('NAME','DESCRIPTION') -- searching only in these column names

SET @search='String aqui'

OPEN curTabCol
FETCH NEXT FROM curTabCol INTO @table, @column

WHILE (@@FETCH_STATUS = 0)
BEGIN
    EXECUTE('IF EXISTS 
             (SELECT * FROM ' + @table + ' WHERE ' + @column + ' = ''' + @search + ''') 
             PRINT ''' + @table + '.' + @column + '''')
    FETCH NEXT FROM curTabCol INTO @table, @column
END

CLOSE curTabCol
DEALLOCATE curTabCol
```