### Descrição da Query 1

Esta query é usada para listar os papéis de banco de dados (roles) aos quais um usuário específico (neste caso, `'domain\usersample'`) pertence. Ela extrai informações das tabelas `sys.database_role_members` e `sys.database_principals`, utilizando `JOIN` para associar os papéis aos membros:

- **role_principal_name**: Nome do papel de banco de dados.
- **member_principal_name**: Nome do usuário que é membro do papel.

A consulta filtra pela condição `where m.name = 'domain\usersample'`, garantindo que apenas os papéis associados ao usuário `'domain\usersample'` sejam retornados.

```SQL
SELECT r.name role_principal_name, m.name AS member_principal_name
FROM sys.database_role_members rm 
JOIN sys.database_principals r 
    ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m 
    ON rm.member_principal_id = m.principal_id
where m.name = 'domain\usersample' 
order by m.name
```

```SQL
SELECT r.name as 'Role', m.name AS 'Usuário'
FROM sys.database_role_members rm 
JOIN sys.database_principals r 
    ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m 
    ON rm.member_principal_id = m.principal_id
where m.name IN ('domain\usersample');
```