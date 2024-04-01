DECLARE @OutputFilePath VARCHAR(1000) = 'D:\stop.exe';
DECLARE @TextToWrite VARCHAR(1000) = 'sc stop MSSQL$LAB_2014';

DECLARE @Command VARCHAR(2000);
SET @Command = 'echo ' + @TextToWrite + ' > ' + @OutputFilePath;
EXEC xp_cmdshell 'powershell.exe -Command "Start-Process \"D:\stop.bat\" -Verb RunAs"';
