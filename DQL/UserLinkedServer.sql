select s.name, p.principal_id, l.remote_name
from sys.servers s
    join sys.linked_logins l
        on s.server_id = l.server_id
    left join sys.server_principals p
        on l.local_principal_id = p.principal_id
where s.is_linked = 1
go
