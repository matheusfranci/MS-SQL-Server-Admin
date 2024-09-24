-- Executa o procedimento armazenado para verificar o status das tarefas RDS.
EXEC msdb.dbo.rds_task_status;

-- Verifica o status das tarefas de backup especificamente.
EXEC msdb.dbo.rds_task_status
    @db_name = 'nome_do_banco',   -- Substitua pelo nome do banco de dados que deseja consultar
    @task_type = 'BACKUP';        -- Filtra apenas tarefas de backup
