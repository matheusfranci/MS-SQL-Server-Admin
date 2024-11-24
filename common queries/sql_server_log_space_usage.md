### Descrição da Query

Esta query mede a porcentagem de espaço utilizado nos arquivos de log de transações (arquivos LDF) de um banco de dados SQL Server. O processo é dividido em duas partes:

1. **Criação da tabela temporária** `@result`, que armazena os seguintes dados:
   - **Database_Name**: nome do banco de dados.
   - **Log_Size**: tamanho total do arquivo de log.
   - **Log_Space**: espaço utilizado dentro do arquivo de log.
   - **Status**: status do espaço de log (não utilizado, utilizado, etc.).

2. **Execução do comando `DBCC sqlperf(LOGSPACE)`**, que retorna informações de espaço de log de todos os bancos de dados, e armazena o resultado na tabela temporária.

3. **Consulta**: a query retorna a porcentagem de espaço utilizado no arquivo de log do banco de dados atual, arredondada para duas casas decimais.

```SQL
-- Esta métrica mede a porcentagem de espaço usado para arquivos de log de transações (arquivos LDF).
DECLARE	@result TABLE
	(
	  [Database_Name] VARCHAR(150) ,
	  [Log_Size] FLOAT ,
	  [Log_Space] FLOAT ,
	  [Status] VARCHAR(100)
	) 
 
INSERT	INTO @result
		EXEC ( 'DBCC sqlperf(LOGSPACE) WITH NO_INFOMSGS'
			)
 
-- only return for the DB in context, rounding it 
SELECT	ROUND([Log_Space], 2)
FROM	@result
WHERE	[Database_Name] = DB_NAME()
```