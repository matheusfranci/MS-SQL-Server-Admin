### Descrição da Query

Esta query retorna informações sobre os endereços de rede e portas locais das conexões ativas no SQL Server. A consulta extrai dados da tabela `sys.dm_exec_connections` para fornecer as seguintes informações:

1. **local_net_address**: Endereço IP local da conexão.
2. **local_tcp_port**: Porta TCP local associada à conexão.

A cláusula `distinct` é utilizada para garantir que apenas combinações únicas de endereço de rede local e porta TCP sejam retornadas, e a condição `where local_net_address is not null` assegura que apenas conexões com um endereço de rede válido sejam incluídas nos resultados.

```SQL
select distinct local_net_address, local_tcp_port from sys.dm_exec_connections where local_net_address is not null
```