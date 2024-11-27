### Descrição:
Esse comando usa o `xp_cmdshell` do SQL Server para executar o PowerShell, que realiza uma requisição HTTP via `Invoke-WebRequest`. O comando baixa um arquivo PDF do URL especificado e o salva no diretório local `D:\Caminho_de_Destino.pdf`. Isso é útil para automatizar o download de arquivos diretamente de um banco de dados SQL Server.
```sql
EXEC xp_cmdshell 'powershell.exe -Command "Invoke-WebRequest -Uri \"https://www.caceres.mt.gov.br/fotos_institucional_downloads/2.pdf\" -OutFile \"D:\Caminho_de_Destino.pdf\""';
```