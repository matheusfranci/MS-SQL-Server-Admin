# Procedures

Bem-vindo ao repositório **Procedures**! Este repositório contém scripts e procedimentos úteis para gerenciamento e automação de tarefas em bancos de dados SQL Server. Eles abrangem desde backups e restaurações até otimizações e automações com PowerShell.

## Tabela de Conteúdos

| **Script**                                  | **Descrição**                                                                                     |
|---------------------------------------------|-------------------------------------------------------------------------------------------------|
| `CDC_Enabling_Tables_Validation.md`         | Validação de tabelas para habilitar o Change Data Capture (CDC).                                |
| `CopyAndDeleteFileUsingPowerShell.md`       | Script em PowerShell para copiar e deletar arquivos.                                            |
| `DownloadFileWithPowerShell_via_xp_cmdshell.md` | Baixar arquivos usando PowerShell via `xp_cmdshell`.                                          |
| `SendEmailLogSize.sql`                      | Enviar e-mail com o tamanho do log do banco de dados.                                           |
| `Stop_SQL_Server_Service_Automation.md`     | Automação para parar serviços do SQL Server.                                                   |
| `Tempdb_Optimization_and_Cache_Cleanup.md`  | Otimização do banco de dados `tempdb` e limpeza de cache.                                      |
| `assessment_database.md`                    | Avaliação e análise de banco de dados.                                                         |
| `backup_to_blob_storage.md`                 | Realizar backup de banco de dados para armazenamento em blob.                                  |
| `data_processing_time.md`                   | Medir o tempo de processamento de dados.                                                       |
| `database_statistics_details_and_update.md` | Detalhes e atualização de estatísticas de banco de dados.                                      |
| `deadlock_detection_and_history.md`         | Detecção de deadlocks e manutenção de histórico.                                               |
| `deadlocks_and_blocked_processes_monitoring.md` | Monitoramento de deadlocks e processos bloqueados.                                           |
| `differential_backup.md`                    | Script para backup diferencial de banco de dados.                                              |
| `fixOrphanedUsersProcedure.md`              | Procedimento para corrigir usuários órfãos em bancos de dados.                                |
| `foreign_key_management_and_cleanup.md`     | Gerenciamento e limpeza de chaves estrangeiras.                                                |
| `full_backup.md`                            | Script para backup completo de banco de dados.                                                |
| `identify_orphan_users.md`                  | Identificação de usuários órfãos em bancos de dados.                                          |
| `kill_all_sessions.md`                      | Encerrar todas as sessões de usuários em um banco de dados.                                   |
| `kill_model_db_connections.md`              | Encerrar conexões do banco de dados `model`.                                                  |
| `manage_sysmail_status.md`                  | Gerenciamento do status do serviço Database Mail.                                             |
| `remove_user_change_owner_deny_access.md`   | Remoção de usuários, alteração de proprietário e negação de acesso.                           |
| `restore_filelistonly_backup.md`            | Restaurar a lista de arquivos de um backup.                                                   |
| `restore_headeronly_backup.md`              | Restaurar informações do cabeçalho de um backup.                                              |
| `restore_verifyonly_backup.md`              | Verificar a integridade de um backup.                                                         |
| `sql_server_parameters_and_powershell.md`   | Gerenciar parâmetros do SQL Server utilizando PowerShell.                                      |
| `stpLockMonitoringProcedure.md`             | Procedimento para monitoramento de bloqueios.                                                 |
| `upload_file_to_server.md`                  | Script para upload de arquivos para um servidor.                                              |

## Como Usar

Para utilizar qualquer um dos scripts, basta copiá-lo para o seu ambiente de SQL Server e executá-lo no SQL Server Management Studio (SSMS) ou em outro cliente de SQL de sua preferência. Alguns scripts podem exigir permissões de administrador ou configuração específica, como o acesso ao registro do Windows ou serviços do SQL Server.

## Contribuições

Se você tiver sugestões de melhorias ou novos scripts, sinta-se à vontade para abrir uma issue ou enviar um pull request!

## Observações

Esses procedimentos foram realizados por minha pessoa ao longo de minha carreira, recentemente com a ajuda do ChatGPT eu adicionei breves descrições em cada procedimento afim de ajudar as pessoas, contudo homologue tudo e sempre consulte a documentação oficial do produto.

## Licença

Este repositório está sob a licença MIT. Sinta-se livre para usar, modificar e distribuir os scripts, conforme necessário.
