# Repositório de Scripts SQL Server

Este repositório contém uma coleção de scripts SQL Server projetados para automatizar e simplificar tarefas de administração de banco de dados, desenvolvimento e manutenção.

## Conteúdo

O repositório está organizado em arquivos Markdown (`.md`), cada um descrevendo um script SQL específico. Abaixo está uma lista dos scripts disponíveis, agrupados por categoria para facilitar a navegação:

### Índices e Estatísticas

* **Advanced_Missing_Index_Generator_V3.md:** Gera recomendações avançadas de índices ausentes com base em estatísticas de uso e análises detalhadas.
* **Comprehensive_Missing_Index_Generator.md:** Gera recomendações abrangentes de índices ausentes com análise detalhada.
* **Drop_Unused_Nonclustered_Indexes.md:** Identifica e gera scripts para remover índices não clusterizados não utilizados.
* **Dynamic_Index_Creation_Script_Generator.md:** Gera scripts dinâmicos para criar índices com base na estrutura atual das tabelas.
* **Dynamic_Index_Script_Generation.md:** Gera scripts dinâmicos para criação de indices.
* **Generate_Index_Defragmentation_Scripts.md:** Gera scripts para desfragmentar índices (reconstruir ou reorganizar) com base no nível de fragmentação.
* **Index_Maintenance_Report_And_Rebuild_Generator.md:** Gera um relatório de manutenção de índices e scripts para reconstruir índices com alta fragmentação.
* **Index_Maintenance_Report_And_Reorganize_Generator.md:** Gera um relatório de manutenção de índices e scripts para reorganizar índices com fragmentação moderada.
* **Index_Maintenance_Script_Generator.md:** Gera scripts para desfragmentar índices.
* **Missing_Index_Recommendations_Script.md:** Gera recomendações de índices ausentes.
* **Optimized_Missing_Index_Generator.md:** Gera recomendações otimizadas de índices ausentes com análise detalhada e informações sobre o número de linhas das tabelas.
* **Optimized_Missing_Index_Generator_V2.md:** Gera recomendações otimizadas de índices ausentes com análise detalhada e percentual de melhoria estimado.
* **Update_Statistics_Scripts.md:** Gera scripts para atualizar as estatísticas de todos os bancos de dados de usuário.

### Restrições e Chaves

* **Create_Foreign_Key_Constraints_Script.md:** Gera scripts para criar restrições de chave estrangeira.
* **Create_PK_Unique_Constraints_Script_Generator.md:** Gera scripts para criar restrições de chave primária e restrições únicas.
* **Drop_Foreign_Key_Constraints_Script_Generator.md:** Gera scripts para remover restrições de chave estrangeira.
* **Drop_PK_Unique_Constraints_Script_Generator.md:** Gera scripts para remover restrições de chave primária e restrições únicas.
* **PK_Unique_Constraint_Script_Generator.md:** Gera scripts para criar chaves primárias e restrições únicas.

### Segurança e Logins

* **Create_Linked_Server_Login_Scripts.md:** Gera scripts para criar logins para servidores vinculados.
* **Disable_User_Logins_Scripts.md:** Gera scripts para desabilitar logins de usuário.
* **Enable_User_Logins_Scripts.md:** Gera scripts para habilitar logins de usuário.
* **Generate_Login_Creation_Scripts.md:** Gera scripts para criar logins.
* **Grant_Execute_Permissions_Script_Generator.md:** Gera scripts para conceder permissões de execução a procedimentos armazenados.
* **Modify_Database_Owner_Scripts.md:** Gera scripts para modificar o proprietário de bancos de dados.
* **Orphaned_Users.md:** Identifica usuários órfãos em bancos de dados.
* **Remove_Sysadmin_Members_Scripts.md:** Gera scripts para remover membros da função de servidor `sysadmin`.
* **Update_SQL_Agent_Job_Owner_Scripts.md:** Gera scripts para atualizar o proprietário de trabalhos do SQL Agent.
* **User_Role_Creation_Scripts.md:** Gera scripts para criar usuários com funções específicas.

### Bancos de Dados e Arquivos

* **Change_Recovery_Model_To_Full.md:** Gera scripts para alterar o modelo de recuperação para `FULL`.
* **Create_Snapshot_Tables_Top_1000.md:** Gera scripts para criar tabelas de snapshot com as 1000 primeiras linhas de cada tabela.
* **Database_Mirroring_Failover_Scripts.md:** Gera scripts para realizar failover em espelhamento de banco de dados.
* **Database_Mirroring_Set_Safety_Full.md:** Gera scripts para configurar o espelhamento de banco de dados em modo síncrono.
* **Database_Mirroring_Set_Safety_Off.md:** Gera scripts para configurar o espelhamento de banco de dados em modo assíncrono.
* **Dynamic_Table_Deletion_Scripts.md:** Gera scripts para deletar tabelas dinamicamente.
* **Insert_Data_From_Backup_Tables.md:** Gera scripts para inserir dados de tabelas de backup.
* **Modify_Log_Files_Unlimited_Growth.md:** Gera scripts para configurar o crescimento ilimitado de arquivos de log.
* **Set_Databases_Offline_Scripts.md:** Gera scripts para colocar bancos de dados offline.
* **Set_Databases_Online_Scripts.md:** Gera scripts para colocar bancos de dados online.
* **Set_Recovery_Simple_Scripts.md:** Gera scripts para alterar o modelo de recuperação para `SIMPLE`.
* **Shrink_Database_DBCC_Scripts.md:** Gera scripts para reduzir o tamanho dos bancos de dados usando `DBCC SHRINKDATABASE`.
* **Shrink_Database_Files_Scripts.md:** Gera scripts para reduzir o tamanho dos arquivos de dados dos bancos de dados.
* **Shrink_Log_Files_Scripts.md:** Gera scripts para reduzir o tamanho dos arquivos de log dos bancos de dados.
* **Turn_Off_Synchronized_Mirroring.md:** Gera scripts para desativar o espelhamento síncrono.

### SQL Agent e Outros

* **Disable_All_SQL_Agent_Jobs.md:** Gera scripts para desabilitar todos os trabalhos do SQL Agent.
* **Enable_All_SQL_Agent_Jobs.md:** Gera scripts para habilitar todos os trabalhos do SQL Agent.
* **Dynamic_Bulk_Insert_Script_Generator.md:** Gera scripts dinâmicos para realizar inserções em massa.
* **Dynamic_Bulk_Insert_Script_Generator_With_Timing.md:** Gera scripts dinâmicos para realizar inserções em massa com medição de tempo.
* **Recommended_Server_Settings_Query.md:** Exibe configurações recomendadas para o servidor SQL Server.

## Uso

Cada arquivo Markdown contém uma descrição detalhada do script, incluindo:

* Visão geral do script
* Detalhes do script
* Explicação
* Uso
* Considerações

Para usar os scripts:

1.  Navegue até o arquivo Markdown desejado.
2.  Leia a descrição e as instruções de uso.
3.  Copie o script SQL do arquivo.
4.  Execute o script no SQL Server Management Studio (SSMS) ou outra ferramenta de gerenciamento de banco de dados.

## Contribuição

Contribuições são bem-vindas! Se você tiver scripts úteis para compartilhar ou melhorias para sugerir, sinta-se à vontade para abrir um pull request.

## Licença

Este repositório é licenciado sob a [Licença MIT](LICENSE).
