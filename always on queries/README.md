# Always On Queries - Scripts SQL para Monitoramento e Gerenciamento de Always On Availability Groups no SQL Server

Este repositório contém uma coleção de scripts SQL focados no monitoramento, gerenciamento e resolução de problemas relacionados a **Always On Availability Groups** no SQL Server. Esses scripts ajudam a verificar o status de réplicas, permitir conexões de leitura no nó secundário, lidar com erros relacionados ao papel das réplicas, entre outras funções essenciais para a administração de grupos de disponibilidade.

## Scripts Disponíveis

- **check_local_replica_role_in_availability_group.md**: Verifica o papel da réplica local em um grupo de disponibilidade Always On.
- **allow_read_connections_secondary_node_sqlserver.md**: Permite conexões de leitura no nó secundário de uma réplica de disponibilidade.
- **check_replica_role_and_handle_error.md**: Verifica o papel da réplica e lida com erros relacionados ao status de disponibilidade.

## Como Usar

1. **Verificar o papel da réplica local**: O script `check_local_replica_role_in_availability_group.md` permite verificar o papel da réplica local em um grupo de disponibilidade. Ele pode ser utilizado para confirmar se o nó primário ou secundário está ativo e funcionando corretamente.
   
2. **Permitir conexões de leitura no nó secundário**: Utilize o script `allow_read_connections_secondary_node_sqlserver.md` para configurar o SQL Server de modo que o nó secundário permita conexões de leitura, melhorando a performance e a utilização dos recursos do sistema.

3. **Verificar o papel da réplica e tratar erros**: O script `check_replica_role_and_handle_error.md` pode ser utilizado para verificar o papel de uma réplica e também trata erros caso a réplica esteja em um estado de falha ou transição.

## Contribuições

Contribuições são bem-vindas! Se você tiver sugestões, melhorias ou novos scripts para adicionar, sinta-se à vontade para abrir um **pull request**.

## Licença

Este repositório está licenciado sob a **MIT License**.
