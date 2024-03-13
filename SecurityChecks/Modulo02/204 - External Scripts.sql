
SELECT 
    configuration_id,
    [name],
    [value],
    value_in_use,
    [description],
	is_dynamic
FROM 
    sys.configurations WITH(NOLOCK) 
WHERE 
    [name] = 'external scripts enabled'



EXEC sp_execute_external_script 
  @language = N'R', 
  @script = N'data <- list.files("c:\\") 
            data2 <- data.frame(data)', 
  @output_data_1_name = N'data2'



EXEC sp_execute_external_script 
  @language = N'R', 
  @script = N'data <- list.files("c:\\Logs") 
            data2 <- data.frame(data)', 
  @output_data_1_name = N'data2'


EXECUTE sp_execute_external_script 
	@language = N'Python', 
	@script = N'print(open("C:\\Logs\\service_log.txt", "r").read())'


EXEC sp_execute_external_script
  @language=N'R',
  @script=N'OutputDataSet <- data.frame(system("cmd.exe /c dir",intern=T))'
  WITH RESULT SETS (([cmd_out] text));
GO


EXEC sp_execute_external_script
  @language=N'R',
  @script=N'OutputDataSet <- data.frame(shell("dir",intern=T))'
  WITH RESULT SETS (([cmd_out] text));
GO


EXEC sp_execute_external_script
  @language=N'R',
  @script=N'OutputDataSet <- data.frame(system("cmd.exe /c mkdir C:\\Dirceu",intern=T))'
  WITH RESULT SETS (([cmd_out] text));
GO


EXEC sp_execute_external_script
	@language = N'Python',
	@script=N'
import subprocess

p = subprocess.Popen("cmd.exe /c whoami", stdout=subprocess.PIPE)
OutputDataSet = pandas.DataFrame([str(p.stdout.read(), "utf-8")])'
WITH RESULT SETS (([cmd_out] nvarchar(max)))



-- https://book.hacktricks.xyz/pentesting/pentesting-mssql-microsoft-sql-server
-- Print the user being used (and execute commands)
EXECUTE sp_execute_external_script @language = N'Python', @script = N'print(__import__("getpass").getuser())'
EXECUTE sp_execute_external_script @language = N'Python', @script = N'print(__import__("os").system("whoami"))'
-- Open and read a file
EXECUTE sp_execute_external_script @language = N'Python', @script = N'print(open("C:\\Temporario\\Firewall.bat", "r").read())'


