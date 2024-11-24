### Descrição
Este script consulta a view `sys.databases` para obter informações sobre os bancos de dados no SQL Server, incluindo seu nome, estado, modelo de recuperação, compatibilidade e versão associada. A coluna `compatibility_level` é usada para determinar a versão do SQL Server com a qual cada banco de dados é compatível.

### Explicação do Script
1. **Campos Selecionados:**
   - `name`: Nome do banco de dados.
   - `state_desc`: Descrição do estado do banco de dados (exemplo: ONLINE, OFFLINE).
   - `recovery_model_desc`: Descrição do modelo de recuperação do banco de dados (exemplo: SIMPLE, FULL, BULK_LOGGED).
   - `collation_name`: Nome da collation do banco de dados.
   - `compatibility_level`: Nível de compatibilidade do banco de dados, que indica com qual versão do SQL Server o banco de dados é compatível.
   - `VERSION`: Baseado no `compatibility_level`, o script converte esse valor em uma descrição mais legível da versão do SQL Server associada ao banco de dados. Se o nível de compatibilidade não corresponder aos valores conhecidos, o script fornece um link para mais informações.

2. **Uso do `CASE`:**
   - O `CASE` é utilizado para mapear o valor de `compatibility_level` para a versão do SQL Server correspondente.
   - Para valores não mapeados, o script retorna um link para a documentação oficial do SQL Server sobre compatibilidade.

```SQL
SELECT name,
state_desc,
recovery_model_desc,
collation_name,
compatibility_level,
CASE 
WHEN compatibility_level = 150 THEN 'SQL Server 2019 (15.x)'
WHEN compatibility_level = 140 THEN 'SQL Server 2017 (14.x)'
WHEN compatibility_level = 130 THEN 'SQL Server 2016 (13.x)'
WHEN compatibility_level = 120 THEN 'SQL Server 2014 (12.x)'
WHEN compatibility_level = 110 THEN 'SQL Server 2012 (11.x)'
WHEN compatibility_level = 100 THEN 'SQL Server 2008 R2 (10.50.x)'
WHEN compatibility_level = 90 THEN 'SQL Server 2005 (9.x)'
WHEN compatibility_level = 80 THEN 'SQL Server 2000 (8.x)'
ELSE 'Verificar no link: https://learn.microsoft.com/pt-br/sql/t-sql/statements/alter-database-transact-sql-compatibility-level?view=sql-server-ver16'
END AS 'VERSION'
FROM   sys.databases;
```