SELECT   name,type_desc,is_disabled
FROM     master.sys.server_principals 
WHERE    IS_SRVROLEMEMBER ('sysadmin',name) = 1
ORDER BY name


SELECT   name,type_desc,
CASE
WHEN is_disabled = 1 then 'Desabilidado'
WHEN is_disabled = 0 then 'Habilitado'
ELSE 'Não classificado'
END AS 'Status'
FROM     master.sys.server_principals WITH(NOLOCK)
WHERE    IS_SRVROLEMEMBER ('sysadmin',name) = 1
ORDER BY name;
