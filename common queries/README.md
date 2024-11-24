# Scripts de Monitoramento e Diagnóstico SQL Server

Este repositório contém uma coleção de scripts úteis para monitoramento, análise e administração do SQL Server. Os scripts são divididos em várias categorias, abordando desde análise de desempenho até o gerenciamento de backups e serviços. 

## Estrutura dos Scripts

Abaixo estão listados os scripts disponíveis e uma breve descrição do que cada um faz:

### 1. **Verificações e Monitoramento**
- **Check_tcp.md**: Verifica a conectividade de rede via TCP/IP.
- **installed_features.md**: Lista as funcionalidades instaladas no SQL Server.
- **disk_space_monitoring_sqlserver_with_powershell.md**: Monitoramento de espaço em disco para SQL Server utilizando PowerShell.
- **deadlock_history.md**: Exibe o histórico de deadlocks.
- **database_size_report.md**: Gera um relatório do tamanho dos bancos de dados.
- **check_and_restart_database_mail.md**: Verifica e reinicia o serviço de Database Mail.
- **count_rows_specific_tables.md**: Conta as linhas de tabelas específicas.
- **connections_per_database.md**: Exibe o número de conexões por banco de dados.
- **search_table_object_all_db.md**: Pesquisa por objetos de tabela em todos os bancos de dados.
- **user_role_membership_multiple.md**: Verifica a associação de usuários a múltiplos papéis.
- **database_mirroring_status.md**: Exibe o status de espelhamento de banco de dados.

### 2. **Análises de Desempenho**
- **sql_server_log_space_usage.md**: Monitora o uso de espaço no log de transações.
- **sql_server_io_performance_metrics.md**: Exibe métricas de desempenho de I/O do SQL Server.
- **buffer_manager_performance.md**: Análise de desempenho do buffer manager.
- **cached_adhoc_query_percentage.md**: Exibe a porcentagem de consultas ad-hoc armazenadas em cache.
- **sql_process_tcp_connections.md**: Monitora conexões TCP dos processos SQL.
- **cpu_info_and_count.md**: Exibe informações de CPU e contagem.
- **os_memory_usage.md**: Exibe o uso de memória do sistema operacional.
- **memory_usage_sqlserver.md**: Exibe o uso de memória do SQL Server.
- **plan_cache_summary.md**: Exibe um resumo do cache de planos de execução.

### 3. **Gerenciamento de Backups e Restauração**
- **monitor_backup_restore_progress.md**: Monitora o progresso de backup e restauração.
- **single_database_backup_stats_yearly.md**: Exibe estatísticas de backup anual para um banco de dados específico.
- **backup_statistics_last_12_months.md**: Exibe as estatísticas de backup dos últimos 12 meses.
- **last_restore_for_db.md**: Exibe a última restauração realizada para um banco de dados.
- **last_log_backup_info.md**: Exibe informações sobre o último backup de log.
- **last_backup_info.md**: Exibe informações sobre o último backup realizado.
- **alter_index_progress.md**: Monitora o progresso de alteração de índices.

### 4. **Índices e Fragmentação**
- **check_index_fragmentation.md**: Verifica a fragmentação de índices.
- **index_fragmentation_stats.md**: Exibe estatísticas de fragmentação de índices.
- **index_details_with_count.md**: Exibe detalhes de índices com contagem de registros.
- **index_details_with_count.md**: Detalhes sobre os índices e suas contagens.

### 5. **Serviços e Dependências**
- **sql_server_services_status.md**: Exibe o status dos serviços do SQL Server.
- **check_power_mode.md**: Verifica o modo de energia do servidor.
- **search_in_columns.md**: Pesquisa dados dentro das colunas das tabelas.
- **find_dependencies_of_view.md**: Encontra dependências de uma view.
- **check_object_dependencies.md**: Verifica as dependências de objetos no banco de dados.
- **find_objects_using_linked_servers.md**: Encontra objetos que utilizam servidores vinculados.

### 6. **Outros Scripts**
- **user_permissions_db_owner.md**: Exibe permissões de usuários com funções de DB Owner.
- **database_owners_info.md**: Exibe informações sobre os donos dos bancos de dados.
- **job_monitoring_execution.md**: Monitora a execução de jobs.
- **job_execution_status.md**: Exibe o status de execução de jobs.
- **schedule_job_details.md**: Exibe detalhes de agendamentos de jobs.
- **check_transaction_log_status.md**: Verifica o status do log de transações.

## Como Usar

Para utilizar qualquer um dos scripts, basta copiá-lo para o seu ambiente de SQL Server e executá-lo no SQL Server Management Studio (SSMS) ou em outro cliente de SQL de sua preferência. Alguns scripts podem exigir permissões de administrador ou configuração específica, como o acesso ao registro do Windows ou serviços do SQL Server.

## Contribuições

Se você tiver sugestões de melhorias ou novos scripts, sinta-se à vontade para abrir uma issue ou enviar um pull request!

## Licença

Este repositório está sob a licença MIT. Sinta-se livre para usar, modificar e distribuir os scripts, conforme necessário.
