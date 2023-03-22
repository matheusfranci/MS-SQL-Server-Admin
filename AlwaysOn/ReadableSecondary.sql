-- Permiti usuários do nó 1 abrir sessões no nó 2 

USE [master]
GO
ALTER AVAILABILITY GROUP [SQLGROUP]
MODIFY REPLICA ON N'P-SRV150' WITH (SECONDARY_ROLE(ALLOW_CONNECTIONS = ALL))
GO

-- Consulta do parâmetro de leitura no nó secundário

SELECT ag.name,
       replica_server_name,
       secondary_role_allow_connections_desc as readable_secondary
FROM sys.availability_replicas ar
    JOIN sys.availability_groups ag
        ON ag.group_id = ar.group_id;
