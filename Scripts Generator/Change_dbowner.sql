	SELECT
'USE MASTER
GO
ALTER AUTHORIZATION ON DATABASE::['+name+'] TO [marcos.vinicius]
GO'
	FROM sys.databases
	where SUSER_SNAME(owner_sid) != 'marcos.vinicius'
	and name NOT IN ('master', 'msdb', 'tempdb', 'model')
