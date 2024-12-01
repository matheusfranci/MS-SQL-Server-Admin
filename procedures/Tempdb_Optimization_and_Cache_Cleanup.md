# Descrição do Script

Este script realiza uma série de operações para liberar recursos e otimizar o banco de dados `tempdb` no SQL Server, bem como atualizar as estatísticas do banco de dados:

1. **Liberação de memória do `Tempdb`:**
   - **`DBCC FREEPROCCACHE`**: Libera o cache de planos de execução de consultas, forçando a reexecução de futuras consultas, o que pode ser útil para eliminar planos de execução obsoletos.
   - **`DBCC SHRINKDATABASE`**: Realiza a redução do tamanho do banco de dados `tempdb`, liberando espaço não utilizado.
   - **`DBCC SHRINKFILE` (para os arquivos `tempdev` e `templog`)**: Reduz o tamanho físico dos arquivos `tempdev` e `templog` do `tempdb`, tentando liberar espaço dentro do arquivo sem perder dados. A opção `TRUNCATEONLY` garante que o espaço livre no arquivo seja liberado, mas não reduz o tamanho do arquivo no sistema operacional.

2. **Liberação do Cache em Segundo Plano:**
   - **`DBCC FREEPROCCACHE`**: Executado novamente para liberar o cache de planos de execução de consultas, mantendo a performance otimizada durante operações subsequentes.

3. **Atualização das Estatísticas:**
   - **`sp_updatestats`**: Executa a atualização das estatísticas de todas as tabelas e índices do banco de dados, garantindo que o SQL Server tenha informações atualizadas para a otimização das consultas.

```sql
-- Liberação do Tempdb
USE [tempdb]
GO
DBCC FREEPROCCACHE
GO
DBCC SHRINKDATABASE(N'tempdb' )
GO
USE [tempdb]
GO
DBCC SHRINKFILE (N'tempdev' , 0, TRUNCATEONLY)
GO
USE [tempdb]
GO
DBCC SHRINKFILE (N'templog' , 0, TRUNCATEONLY)
GO
```

```sql
--  Liberação do cache em segundo plano 
 DBCC FREEPROCCACHE

 -- Atualização de estatísticas
 exec sp_updatestats
```