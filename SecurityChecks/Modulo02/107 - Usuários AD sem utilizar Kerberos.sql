
/*

Vantagens do Kerberos sobre o NTLM:
- Mais seguro: nenhuma senha armazenada localmente ou enviada pela rede.
- Melhor desempenho: desempenho aprimorado em relação à autenticação NTLM.
- Suporte à delegação: os servidores podem representar clientes e usar o contexto de segurança do cliente para acessar um recurso.
- Gerenciamento de confiança mais simples: evita a necessidade de relacionamentos de confiança p2p em ambientes de múltiplos domínios.
- Suporta MFA (autenticação multifator)

Links de Referência
-- https://answers.microsoft.com/en-us/msoffice/forum/all/ntlm-vs-kerberos/d8b139bf-6b5a-4a53-9a00-bb75d4e219eb
-- http://www.differencebetween.net/technology/difference-between-ntlm-and-kerberos/
-- https://social.technet.microsoft.com/wiki/pt-br/contents/articles/52880.ad-e-sql-server-problema-de-autenticacao-kerberos-e-ntlm-login-failed-for-user-nt-authorityanonymous-logon.aspx
-- https://www.dirceuresende.com/blog/sql-server-autenticacao-ad-kerberos-ntlm-login-failed-for-user-nt-authorityanonymous-logon/

*/



SELECT
    A.session_id,
    B.login_name,
    B.nt_domain,
    B.nt_user_name,
    A.net_transport,
    A.auth_scheme,
    B.[host_name],
    B.[program_name],
    A.connect_time,
    A.encrypt_option
FROM 
    sys.dm_exec_connections A
    JOIN sys.dm_exec_sessions B ON B.session_id = A.session_id
    JOIN sys.server_principals C ON B.original_security_id = C.[sid]
WHERE
    C.[type_desc] = 'WINDOWS_LOGIN'
    AND C.principal_id > 10
    AND B.nt_domain NOT LIKE 'NT Service%'
	AND B.login_name NOT LIKE 'NT AUTHORITY\%'
	AND B.login_name NOT LIKE 'AUTORIDADE NT\%'
    AND A.auth_scheme <> 'Kerberos'
	AND A.net_transport <> 'Shared memory'
ORDER BY
    2


