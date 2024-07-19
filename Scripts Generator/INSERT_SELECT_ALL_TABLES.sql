DECLARE @sql NVARCHAR(MAX);

-- Inicializa a variável que vai armazenar o comando
SET @sql = N'';

-- Gera os comandos para cada tabela
SELECT @sql = @sql + 
    'INSERT INTO [' + name + ']' + CHAR(13) + CHAR(10) +
    'SELECT * FROM [' + name + '20240719]' + CHAR(13) + CHAR(10) + 
    'GO' + CHAR(13) + CHAR(10)
FROM sys.tables;

-- Imprime o comando gerado
PRINT @sql;

-- Caso queira executar diretamente, descomente a linha abaixo
-- EXEC sp_executesql @sql;
