### Desativação do Usuário "SA"
O script começa com a desativação do login do usuário "sa" utilizando a instrução `ALTER LOGIN` no banco de dados `master`. A primeira parte do script desabilita o login de "sa", e na segunda parte, o nome do login é alterado para "sa_DESATIVADO" para indicar que foi desativado.

### Sessões Utilizando o Usuário "SA"
A consulta segue selecionando as sessões ativas no banco de dados, filtrando pela presença do usuário "sa". A consulta usa a visão dinâmica de gerenciamento `sys.dm_exec_sessions`, e busca informações como `session_id`, `login_time`, `login_name`, `program_name`, `host_name`, entre outras. O filtro `security_id = 0x01` é aplicado para identificar sessões que estão utilizando o login "sa", excluindo sessões com ID menor que 50.

### Bancos de Dados Onde "SA" É o Owner
Em seguida, o script verifica os bancos de dados onde o usuário "sa" é o proprietário. A consulta junta as visões `sys.databases` e `sys.server_principals`, buscando o banco de dados com o `owner_sid` correspondente ao SID do usuário "sa". O script retorna informações como `database_id`, `name`, `owner`, `create_date`, `state_desc`, e outras.

### Jobs Onde o Usuário "SA" É o Owner
O script também consulta os jobs no SQL Server Agent onde o usuário "sa" é o proprietário. Utiliza a tabela `msdb.dbo.sysjobs` e junta com a `msdb.dbo.sysjobhistory` para obter detalhes sobre a execução dos jobs. Para cada job, ele retorna o nome do job, o nome do proprietário, a data e hora de execução e o status do job (sucesso, falha, etc.).

### Linked Servers Onde "SA" É o Owner
Por fim, o script verifica os linked servers no SQL Server onde o usuário "sa" é o proprietário. Ele utiliza a visão `sys.linked_logins` e a tabela `sys.servers` para retornar informações sobre servidores remotos, incluindo o nome do servidor remoto e a fonte de dados, onde o `remote_name` começa com "sa", indicando que o usuário "sa" é o responsável pela configuração do linked server.

Este conjunto de scripts é útil para auditar o uso do usuário "sa", verificar onde ele ainda está em uso no SQL Server e garantir que o acesso com esse usuário seja adequadamente controlado.

```sql
------------------------------------------------
-- COMO DESATIVAR O USUÁRIO "SA"
------------------------------------------------
USE [master]
GO

ALTER LOGIN [sa] DISABLE
GO

ALTER LOGIN [sa] WITH NAME = [sa_DESATIVADO]
GO 
```

```sql
------------------------------------------------
-- SESSÕES UTILIZANDO O "SA"
------------------------------------------------
SELECT
    session_id,
    login_time,
    login_name,
    [program_name],
    [host_name],
    client_interface_name,
    [status],
    nt_domain,
    nt_user_name,
    original_login_name
FROM 
    sys.dm_exec_sessions
WHERE 
    session_id > 50
    AND security_id = 0x01
```

```sql
------------------------------------------------
-- DATABASES ONDE O USUÁRIO "SA" É O OWNER
------------------------------------------------
SELECT 
    A.database_id,
    A.[name],
    B.[name] AS [owner],
    A.create_date,
    A.state_desc,
    A.[compatibility_level],
    A.collation_name
FROM 
    sys.databases A
    JOIN sys.server_principals B ON A.owner_sid = B.[sid]
WHERE
    B.principal_id = 1 -- SA
```

```sql
------------------------------------------------
-- DATABASES ONDE O USUÁRIO "SA" É O OWNER
------------------------------------------------
SELECT 
    A.[name] AS Ds_Job,
    B.[name] AS Ds_Owner,
    msdb.dbo.agent_datetime(C.run_date, C.run_time) AS Dt_Execucao,
    (CASE C.run_status
        WHEN 0 THEN '0 - Falha'
        WHEN 1 THEN '1 - Sucesso'
        WHEN 2 THEN '2 - Retry'
        WHEN 3 THEN '3 - Cancelado'
        WHEN 4 THEN '4 - Executando'
    END) AS Ds_Status,
    C.[message]
FROM
    msdb.dbo.sysjobs A
    JOIN sys.server_principals B ON A.owner_sid = B.[sid]
    JOIN msdb.dbo.sysjobhistory C ON C.job_id = A.job_id
WHERE
    C.step_id = 0 -- Geral
    AND B.principal_id = 1 -- SA
```

```sql
------------------------------------------------
-- LINKED SERVERS ONDE O USUÁRIO "SA" É O OWNER
------------------------------------------------
SELECT
    B.[name],
    B.product,
    B.[provider],
    B.[data_source],
    A.remote_name
FROM
    sys.linked_logins A
    JOIN sys.servers B ON B.server_id = A.server_id
WHERE
    A.server_id > 0
    AND A.local_principal_id = 0
    AND A.uses_self_credential = 0
    AND A.remote_name LIKE 'sa%'
```