### Descrição da Query

Esta query retorna a versão do SQL Server e o nome do servidor atual. 

- **`@@VERSION`**: Retorna a versão do SQL Server em execução no servidor.
- **`@@SERVERNAME`**: Retorna o nome do servidor SQL.

A consulta é útil para identificar rapidamente a versão do SQL Server e o nome do servidor, o que pode ser importante para fins de auditoria ou para garantir compatibilidade de comandos e scripts com a versão do servidor.

```SQL
SELECT @@VERSION AS 'SQL Server Version', @@SERVERNAME AS 'Servidor';
```