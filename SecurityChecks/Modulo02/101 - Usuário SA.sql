
------------------------------------------------
-- COMO DESATIVAR O USUÁRIO "SA"
------------------------------------------------

USE [master]
GO

ALTER LOGIN [sa] DISABLE
GO

ALTER LOGIN [sa] WITH NAME = [sa_DESATIVADO]
GO 



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

