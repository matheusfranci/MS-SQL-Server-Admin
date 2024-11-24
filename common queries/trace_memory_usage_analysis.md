### Descrição da Query

Esta query faz o seguinte:

1. Obtém o caminho do arquivo de log padrão do SQL Server Trace (`sys.traces`) e altera seu nome para incluir "log.trc".
2. Utiliza a função `sys.fn_trace_gettable` para ler o conteúdo do arquivo de log trace.
3. Filtra os eventos onde o texto contém "memory (MB)" mas exclui textos que começam com "WITH%p%".
4. Retorna informações detalhadas, incluindo:
   - **`TextData`**: O texto do evento de trace.
   - **`DatabaseID`**: Identificador do banco de dados.
   - **`HostName`**: Nome do host que gerou o evento.
   - **`ApplicationName`**: Nome da aplicação associada ao evento.
   - **`LoginName`**: Nome de login usado.
   - **`SPID`**: ID da sessão.
   - **`StartTime`**: Hora de início do evento.
   - **`DatabaseName`**: Nome do banco de dados.
   - **`SessionLoginName`**: Nome de login da sessão.

```SQL
WITH 
    p AS
(
  SELECT 
      [path] = 
          REVERSE(SUBSTRING(p, CHARINDEX(N'\', p), 260)) + N'log.trc'
  FROM 
  (
       SELECT 
           REVERSE([path]) 
       FROM sys.traces WHERE is_default = 1
  ) s (p)
)
SELECT 
   t.TextData,
   t.DatabaseID,
   t.HostName,
   t.ApplicationName,
   t.LoginName,
   t.SPID,
   t.StartTime,
   t.DatabaseName,
   t.SessionLoginName
FROM p 
CROSS APPLY sys.fn_trace_gettable(p.[path], DEFAULT) AS t
WHERE t.TextData LIKE N'%memory (MB)%'
AND   t.TextData NOT LIKE N'WITH%p%'
ORDER BY t.StartTime DESC;
```