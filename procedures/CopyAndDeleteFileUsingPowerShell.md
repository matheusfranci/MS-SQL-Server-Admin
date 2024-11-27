# Script de Cópia e Exclusão de Arquivo com PowerShell via xp_cmdshell

Este script realiza as seguintes operações utilizando o `xp_cmdshell` no SQL Server:

1. **Copia um arquivo**: Usa o comando `copy` do PowerShell para copiar o arquivo `ListFiles.ps1` do diretório `C:\` para o diretório `G:\AWS\`.
2. **Exclui o arquivo**: Após a cópia, utiliza o comando PowerShell `Remove-Item` para remover o arquivo do diretório de destino.

## Exemplo de Execução
- **Copia**: `copy "C:\ListFiles.ps1" "G:\AWS\"`
- **Remove**: `Remove-Item -Path "G:\AWS\ListFiles.ps1"`

```SQL
-- Copiando arquivo de dentro do SQL Server usando powershell
EXEC xp_cmdshell 'copy "C:\ListFiles.ps1" "G:\AWS\"'
```

```SQL
-- Dropa o arquivo
EXEC xp_cmdshell 'powershell.exe -Command "Remove-Item -Path \"G:\AWS\ListFiles.ps1\""'
```