# Script: Permitir Conexões no Nó Secundário e Consultar Parâmetro de Leitura

Este script realiza duas operações em um grupo de disponibilidade no SQL Server:

1. **Permitir usuários do nó 1 abrirem sessões no nó 2**:
   - A primeira parte do script usa o comando `ALTER AVAILABILITY GROUP` para modificar o comportamento da réplica secundária no nó `P-SRV150`.
   - O comando permite que o nó secundário (nó 2) aceite conexões para leitura, configurando o parâmetro `ALLOW_CONNECTIONS = ALL` no papel secundário.

2. **Consultar o parâmetro de leitura no nó secundário**:
   - A segunda parte do script consulta a tabela de sistema `sys.availability_replicas` para verificar as configurações de cada réplica no grupo de disponibilidade.
   - A consulta retorna o nome do grupo de disponibilidade (`ag.name`), o nome do servidor da réplica (`replica_server_name`) e a descrição do parâmetro de leitura (`readable_secondary`), que indica se a réplica secundária permite ou não conexões de leitura.

## Descrição do Processo:
- **ALTER AVAILABILITY GROUP**: Modifica a configuração do grupo de disponibilidade, permitindo que a réplica secundária aceite conexões.
- **Consulta**: Recupera informações sobre as réplicas e suas permissões de leitura no grupo de disponibilidade.

```SQL
-- Permiti usuários do nó 1 abrir sessões no nó 2 

USE [master]
GO
ALTER AVAILABILITY GROUP [SQLGROUP]
MODIFY REPLICA ON N'P-SRV150' WITH (SECONDARY_ROLE(ALLOW_CONNECTIONS = ALL))
GO
```

-- Consulta do parâmetro de leitura no nó secundário
```SQL
SELECT ag.name,
       replica_server_name,
       secondary_role_allow_connections_desc as readable_secondary
FROM sys.availability_replicas ar
    JOIN sys.availability_groups ag
        ON ag.group_id = ar.group_id;
```