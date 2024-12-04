# Descrição do Script

Este script cria e configura uma sessão de evento no SQL Server para monitorar o início das instruções `TRUNCATE` em tabelas. O script é dividido em duas partes principais: a criação da sessão de evento e a consulta dos dados gerados.

## 1. Criação da Sessão de Evento

O script começa criando uma **sessão de evento** chamada `[truncate]` no servidor SQL. Esta sessão de evento irá capturar eventos relacionados ao início de instruções SQL, especificamente aquelas que são `TRUNCATE TABLE`.

### Ações definidas para o evento:

- **sqlserver.sql_text**: Captura o texto da consulta SQL executada.
- **sqlserver.client_app_name**: Captura o nome do aplicativo cliente que executou a consulta.
- **sqlserver.client_hostname**: Captura o nome do host cliente que executou a consulta.
- **sqlserver.database_id**: Captura o ID do banco de dados onde a consulta foi executada.
- **sqlserver.database_name**: Captura o nome do banco de dados onde a consulta foi executada.
- **sqlserver.session_id**: Captura o ID da sessão que executou a consulta.
- **sqlserver.username**: Captura o nome do usuário que executou a consulta.

### Filtro de Evento:

A sessão captura apenas os eventos onde a instrução SQL contém a string `TRUNCATE TABLE`, utilizando a função `sqlserver.like_i_sql_unicode_string`.

### Alvo de Armazenamento:

- **Target**: O evento será armazenado no `ring_buffer` do SQL Server.
- **Configuração de Memória**: A memória máxima do buffer é configurada para 4096 KB, mas esse valor pode ser ajustado conforme necessário.

### Estado de Inicialização:

A sessão é configurada para iniciar automaticamente quando o SQL Server for reiniciado, por meio da opção `STARTUP_STATE = ON`.

### Inicia a Sessão de Evento:

Depois de configurar a sessão de evento, o script altera o estado da sessão para `START`, fazendo com que ela comece a capturar eventos.

## 2. Consulta aos Dados do Ring Buffer

Após a criação da sessão de evento e a captura de dados no `ring_buffer`, o script consulta esses dados armazenados.

- **XML**: O conteúdo armazenado no `ring_buffer` é recuperado e tratado como XML.
- **Extração de Dados**: A consulta extrai informações como:
  - **EventTime**: Data e hora em que o evento foi registrado.
  - **Statement**: Texto da instrução SQL executada.
  - **Username**: Nome do usuário que executou a consulta.
  - **ClientAppName**: Nome do aplicativo cliente que executou a consulta.
  - **ClientHostname**: Nome do host cliente que executou a consulta.
  - **SessionID**: ID da sessão que executou a consulta.
  - **DatabaseName**: Nome do banco de dados onde a consulta foi executada.

A consulta usa a função `CROSS APPLY` para aplicar o método `nodes()` ao XML e extrair os dados relevantes para cada evento registrado no `ring_buffer`.

## Objetivo

O objetivo deste script é monitorar e registrar a execução de instruções `TRUNCATE TABLE`, coletando detalhes como a consulta executada, informações do usuário, do aplicativo cliente, do host e do banco de dados, além de capturar eventos no momento da execução. Esse tipo de monitoramento pode ser útil para auditoria e controle de alterações no banco de dados.
 ```sql
CREATE EVENT SESSION [truncate] ON SERVER
ADD EVENT sqlserver.sql_statement_starting
(
    ACTION 
    (
        sqlserver.sql_text,
        sqlserver.client_app_name, 
        sqlserver.client_hostname, 
        sqlserver.database_id, 
        sqlserver.database_name,
        sqlserver.session_id, 
        sqlserver.username -- Captura o nome do usuário
    )
    WHERE (sqlserver.like_i_sql_unicode_string([statement], N'truncate table%'))
)
ADD TARGET package0.ring_buffer
(
    SET max_memory = 4096 -- Ajuste o valor conforme necessário
)
WITH (STARTUP_STATE = ON);  -- Inicia automaticamente quando o SQL Server é reiniciado

-- Iniciar a Event Session
ALTER EVENT SESSION [truncate] ON SERVER STATE = START;
```

```sql
WITH RingBufferXML AS 
(
    SELECT 
        CAST(target_data AS XML) AS TargetData
    FROM sys.dm_xe_sessions AS s
    JOIN sys.dm_xe_session_targets AS t
        ON s.address = t.event_session_address
    WHERE s.name = 'truncate' AND t.target_name = 'ring_buffer'
)
SELECT 
    r.value('(@timestamp)[1]', 'DATETIMEOFFSET') AS EventTime,
    r.value('(data[@name="statement"]/value)[1]', 'NVARCHAR(MAX)') AS Statement,
    r.value('(action[@name="username"]/value)[1]', 'NVARCHAR(MAX)') AS Username,
    r.value('(action[@name="client_app_name"]/value)[1]', 'NVARCHAR(MAX)') AS ClientAppName,
    r.value('(action[@name="client_hostname"]/value)[1]', 'NVARCHAR(MAX)') AS ClientHostname,
    r.value('(action[@name="session_id"]/value)[1]', 'INT') AS SessionID,
    r.value('(action[@name="database_name"]/value)[1]', 'NVARCHAR(MAX)') AS DatabaseName
FROM RingBufferXML
CROSS APPLY TargetData.nodes('RingBufferTarget/event') AS XEvent(r);
```
