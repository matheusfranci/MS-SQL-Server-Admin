SELECT r.name role_principal_name, m.name AS member_principal_name
FROM sys.database_role_members rm 
JOIN sys.database_principals r 
    ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m 
    ON rm.member_principal_id = m.principal_id
where m.name = 'S2\roberthamendes' 
order by m.name


SELECT r.name as 'Role', m.name AS 'Usuário'
FROM sys.database_role_members rm 
JOIN sys.database_principals r 
    ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m 
    ON rm.member_principal_id = m.principal_id
where m.name IN ('S2\LEONARDOCARDOSO', 'S2\HUGOCERQUEIRA', 'ALEXANDRELOPES');
