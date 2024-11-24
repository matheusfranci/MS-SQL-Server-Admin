### Descrição da Query

Esta query retorna informações detalhadas sobre sessões no SQL Server que estão aguardando por tipos específicos de `PAGE LATCH` relacionados a páginas de armazenamento interno do banco de dados (PFS, GAM e SGAM). 

- **`session_id`**: Identifica a sessão que está esperando.
- **`wait_type`**: O tipo de espera relacionado ao latch da página.
- **`wait_duration_ms`**: O tempo de espera (em milissegundos).
- **`blocking_session_id`**: ID da sessão que pode estar bloqueando a sessão atual.
- **`resource_description`**: Descrição do recurso aguardado.
- **`ResourceType`**: Classifica o tipo de página sendo aguardada:
  - **`PFS Page`**: Indica páginas de `Page Free Space`.
  - **`GAM Page`**: Indica páginas de `Global Allocation Map`.
  - **`SGAM Page`**: Indica páginas de `Shared Global Allocation Map`.
  - **`Not PFS, GAM, or SGAM page`**: Indica outros tipos de páginas.

A query utiliza a view `sys.dm_os_waiting_tasks` para listar apenas tarefas com esperas relacionadas a `PAGE LATCH` e filtra os resultados para focar em páginas de banco de dados com identificadores específicos.

```SQL
Select session_id,
wait_type,
wait_duration_ms,
blocking_session_id,
resource_description,
      ResourceType = Case
When Cast(Right(resource_description, Len(resource_description) - Charindex(':', resource_description, 3)) As Int) - 1 % 8088 = 0 Then 'Is PFS Page'
            When Cast(Right(resource_description, Len(resource_description) - Charindex(':', resource_description, 3)) As Int) - 2 % 511232 = 0 Then 'Is GAM Page'
            When Cast(Right(resource_description, Len(resource_description) - Charindex(':', resource_description, 3)) As Int) - 3 % 511232 = 0 Then 'Is SGAM Page'
            Else 'Is Not PFS, GAM, or SGAM page'
            End
From sys.dm_os_waiting_tasks
Where wait_type Like 'PAGE%LATCH_%'
And resource_description Like '2:%'
```

-- Link de um artigo explicando contenção em tempdb
https://www.tiagoneves.net/blog/contencao-de-tempdb-como-resolver/
