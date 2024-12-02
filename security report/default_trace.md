# Descrição do Script

Este script tem como objetivo habilitar o trace padrão no SQL Server, listar eventos de trace, e realizar auditorias sobre diferentes tipos de eventos no banco de dados, como eventos DDL (Data Definition Language), DCL (Data Control Language), comandos DBCC (Database Console Commands) e restaurações de backup.

### Passos do Script:

1. **Verificação do Estado do Trace Padrão**:
   - A primeira parte do script consulta a tabela `sys.configurations` para verificar o estado da configuração `default trace enabled`, que indica se o trace padrão está ativado ou desativado.
   - A consulta retorna as configurações atuais para essa opção, como `value`, `value_in_use`, `is_dynamic` e `is_advanced`.

2. **Ativando o Trace Padrão**:
   - Caso o trace padrão esteja desativado, a segunda parte do script o ativa executando a stored procedure `sp_configure` para alterar a configuração `default trace enabled`.
   - A configuração `show advanced options` também é ativada temporariamente para permitir alterações em configurações avançadas.

3. **Listando Todos os Eventos Possíveis**:
   - O script declara uma variável `@id` para obter o ID do trace padrão e usa essa variável para consultar os eventos de trace disponíveis, através da função `fn_trace_geteventinfo`.
   - A consulta retorna o ID do evento e o nome de todos os eventos que podem ser registrados no trace.

4. **Identificando Eventos de DDL e DCL**:
   - O script define o caminho do arquivo de trace padrão e executa uma consulta para identificar eventos de DDL e DCL (como `CREATE`, `ALTER`, `DROP`, `GRANT`, `REVOKE`, etc.), filtra eventos ocorridos nos últimos 7 dias e exclui certas condições, como registros de `NT AUTHORITY\NETWORK SERVICE` ou operações no banco `tempdb`.
   - A consulta também exclui eventos originados por aplicações como 'Red Gate' ou 'Intellisense'.

5. **Identificando Comandos DBCC Executados**:
   - O script consulta o arquivo de trace para identificar quando comandos DBCC (como `DBCC CHECKDB`) foram executados na instância. Ele filtra eventos com a classe de evento `116`, que corresponde a comandos DBCC.

6. **Identificando Restaurantes de Backup**:
   - O script consulta novamente o arquivo de trace para identificar quando backups foram restaurados. Ele filtra eventos da classe `115` com `EventSubClass = 2`, que indicam a restauração de backups.

### Considerações:
- **Verificação do Trace Padrão**: O trace padrão é útil para auditar eventos no SQL Server, e a configuração de `default trace enabled` deve estar ativa para garantir que esses eventos sejam registrados.
- **Eventos de DDL e DCL**: Identificar eventos de DDL e DCL pode ser útil para auditar alterações estruturais e de segurança no banco de dados.
- **Comandos DBCC**: A auditoria de comandos DBCC é importante para monitorar a integridade do banco de dados e verificar se operações de verificação de consistência estão sendo executadas.
- **Restauração de Backups**: Auditar a restauração de backups é uma prática essencial para garantir a integridade dos dados e detectar possíveis restaurações não autorizadas.

Este script fornece uma maneira eficaz de monitorar atividades importantes em um banco de dados SQL Server, permitindo que DBAs ou administradores de segurança auditem alterações, verificações e restaurações de dados.

```sql
SELECT configuration_id, [value], value_in_use, is_dynamic, is_advanced
FROM sys.configurations
WHERE [name] = 'default trace enabled'
```


```sql
-- Ativa o trace padrão (caso esteja desativado)
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
EXEC sp_configure 'default trace enabled', 1;
GO
RECONFIGURE;
GO
EXEC sp_configure 'show advanced options', 0;
GO
RECONFIGURE;
GO
```

```sql
-- Lista todos os eventos possíveis
DECLARE @id INT = ( SELECT id FROM sys.traces WHERE is_default = 1 )
 
SELECT DISTINCT
    eventid,
    [name]
FROM
    fn_trace_geteventinfo(@id) A
    JOIN sys.trace_events B ON A.eventid = B.trace_event_id
```

```sql
-- Identificando eventos de DDL e DCL
DECLARE @Ds_Arquivo_Trace VARCHAR(255) = (SELECT SUBSTRING([path], 0, LEN([path])-CHARINDEX('\', REVERSE([path]))+1) + '\Log.trc' FROM sys.traces WHERE is_default = 1)

SELECT
    A.HostName,
    A.ApplicationName,
    A.NTUserName,
    A.NTDomainName,
    A.LoginName,
    A.SPID,
    A.EventClass,
    B.name,
    A.EventSubClass,
    A.TextData,
    A.StartTime,
    A.ObjectName,
    A.DatabaseName,
    A.TargetLoginName,
    A.TargetUserName
FROM
    [fn_trace_gettable](@Ds_Arquivo_Trace, DEFAULT) A
    JOIN master.sys.trace_events B ON A.EventClass = B.trace_event_id
WHERE
    A.EventClass IN ( 164, 46, 47, 108, 110, 152 ) 
    AND A.StartTime >= GETDATE()-7
    AND A.LoginName NOT IN ( 'NT AUTHORITY\NETWORK SERVICE' )
    AND A.LoginName NOT LIKE '%SQLTELEMETRY$%'
    AND A.DatabaseName != 'tempdb'
    AND NOT (B.name LIKE 'Object:%' AND A.ObjectName IS NULL )
    AND NOT (A.ApplicationName LIKE 'Red Gate%' OR A.ApplicationName LIKE '%Intellisense%' OR A.ApplicationName = 'DacFx Deploy')
ORDER BY
    StartTime DESC
```

```sql
-- Identificando quando comandos DBCC foram executados na instância
DECLARE @path VARCHAR(MAX) = (SELECT [path] FROM sys.traces WHERE is_default = 1)

SELECT
    TextData,
    Duration,
    StartTime,
    EndTime,
    SPID,
    ApplicationName,
    LoginName
FROM
    sys.fn_trace_gettable(@path, DEFAULT)
WHERE
    EventClass IN ( 116 )
ORDER BY
    StartTime DESC
```
    
```sql
-- Identificando quando os backups foram restaurados
DECLARE @path VARCHAR(MAX) = (SELECT [path] FROM sys.traces WHERE is_default = 1)

SELECT
    TextData,
    Duration,
    StartTime,
    EndTime,
    SPID,
    ApplicationName,
    LoginName
FROM
    sys.fn_trace_gettable(@path, DEFAULT)
WHERE
    EventClass IN ( 115 ) 
    AND EventSubClass = 2
ORDER BY
    StartTime DESC
```