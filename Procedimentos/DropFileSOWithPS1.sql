-- Copiando arquivo de dentro do SQL Server usando powershell
EXEC xp_cmdshell 'copy "C:\ListFiles.ps1" "G:\AWS\"'

-- Dropa o arquivo
EXEC xp_cmdshell 'powershell.exe -Command "Remove-Item -Path \"G:\AWS\ListFiles.ps1\""'
