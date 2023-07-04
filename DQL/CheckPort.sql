select distinct local_net_address, local_tcp_port from sys.dm_exec_connections where local_net_address is not null
