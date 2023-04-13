SELECT
'ALTER SERVER ROLE [sysadmin] DROP MEMBER ['+ loginname +']
GO'
FROM syslogins
WHERE    IS_SRVROLEMEMBER ('sysadmin',name) = 1
ORDER BY name
