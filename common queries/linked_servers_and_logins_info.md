### Descrição da Query

Esta query recupera informações sobre servidores vinculados e seus logins associados no SQL Server. Ela realiza junções entre as views do sistema `sys.servers`, `sys.linked_logins` e `sys.server_principals` para exibir detalhes dos servidores vinculados, incluindo o login principal associado ao servidor local para cada servidor vinculado.

A saída inclui:
- **`s.name`**: O nome do servidor vinculado.
- **`p.principal_id`**: O ID do principal do login associado ao servidor local.
- **`l.remote_name`**: O nome de login remoto utilizado para o servidor vinculado.

A query filtra os resultados para incluir apenas servidores vinculados onde `s.is_linked = 1`, significando que o servidor está ativamente vinculado.

```SQL
select s.name, p.principal_id, l.remote_name
from sys.servers s
    join sys.linked_logins l
        on s.server_id = l.server_id
    left join sys.server_principals p
        on l.local_principal_id = p.principal_id
where s.is_linked = 1
go
```