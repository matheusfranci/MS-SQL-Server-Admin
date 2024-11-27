### Descrição:
Este script cria um arquivo em lote (`stop.bat`) que contém o comando para parar o serviço `MSSQL$LAB_2014` usando `sc stop`. O arquivo em lote é executado com privilégios administrativos através do PowerShell. Essa automação é útil para interromper uma instância específica do SQL Server sem a necessidade de intervenção manual.

### Etapas principais:
1. Define o caminho do arquivo de saída e o texto para parar o serviço.
2. Cria o arquivo em lote com o comando `sc stop`.
3. Executa o arquivo em lote como administrador usando o PowerShell.

```SQL
DECLARE @OutputFilePath VARCHAR(1000) = 'D:\stop.exe';
DECLARE @TextToWrite VARCHAR(1000) = 'sc stop MSSQL$LAB_2014';

DECLARE @Command VARCHAR(2000);
SET @Command = 'echo ' + @TextToWrite + ' > ' + @OutputFilePath;
EXEC xp_cmdshell 'powershell.exe -Command "Start-Process \"D:\stop.bat\" -Verb RunAs"';
```