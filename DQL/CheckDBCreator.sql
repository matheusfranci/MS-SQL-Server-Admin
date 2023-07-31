SELECT name AS 'Database', suser_sname(owner_sid) AS 'Creator' FROM sys.databases;
