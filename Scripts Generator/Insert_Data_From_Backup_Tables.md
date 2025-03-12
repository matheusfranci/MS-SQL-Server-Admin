# Geração de Scripts INSERT para Copiar Dados de Tabelas de Backup

Este script SQL gera dinamicamente scripts `INSERT INTO ... SELECT * FROM` para copiar dados de tabelas de backup (com sufixo '20240719') para tabelas originais. Ele consulta a tabela `sys.tables` para obter os nomes das tabelas e gera os scripts correspondentes.

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Declaração de Variável `@sql`:** Declara uma variável `@sql` do tipo `NVARCHAR(MAX)` para armazenar os scripts gerados.
2.  **Inicialização da Variável `@sql`:** Inicializa a variável `@sql` com uma string vazia.
3.  **Geração de Scripts `INSERT INTO ... SELECT * FROM`:** Consulta a tabela `sys.tables` e concatena scripts `INSERT INTO ... SELECT * FROM` na variável `@sql` para cada tabela encontrada.
4.  **Impressão dos Scripts Gerados:** Imprime o conteúdo da variável `@sql` para exibir os scripts gerados.
5.  **Execução dos Scripts (Opcional):** Descomente a linha `EXEC sp_executesql @sql;` para executar os scripts gerados diretamente.

## Detalhes do Script

```sql
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
