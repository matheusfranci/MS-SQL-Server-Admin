# Verificação de Conexões TCP de Processos SQL

## Descrição do Script

Este script em PowerShell identifica todas as conexões de rede TCP associadas aos processos relacionados ao SQL Server que estão em execução no sistema. Ele utiliza os cmdlets **Get-Process** e **Get-NetTCPConnection** para capturar as informações de processos e conexões.

### Detalhes:
1. **Get-Process**: Lista os processos em execução e filtra apenas aqueles cujo nome contém "SQL".
2. Para cada processo filtrado, o script:
   - Obtém as conexões TCP ativas do processo.
   - Exibe informações detalhadas, como:
     - Nome do processo SQL.
     - Endereço e porta local.
     - Endereço e porta remota.
     - Estado da conexão (por exemplo, *Established* ou *Listening*).

3. As informações são exibidas em formato tabular para facilitar a leitura.

### Campos Retornados:
- **Process_Name**: Nome do processo SQL relacionado.
- **Local_Address**: Endereço IP e porta local usada pela conexão.
- **Remote_Address**: Endereço IP e porta remota da conexão.
- **State**: Estado da conexão TCP.# Verificação de Conexões TCP de Processos SQL

## Descrição do Script

Este script em PowerShell identifica todas as conexões de rede TCP associadas aos processos relacionados ao SQL Server que estão em execução no sistema. Ele utiliza os cmdlets **Get-Process** e **Get-NetTCPConnection** para capturar as informações de processos e conexões.

### Detalhes:
1. **Get-Process**: Lista os processos em execução e filtra apenas aqueles cujo nome contém "SQL".
2. Para cada processo filtrado, o script:
   - Obtém as conexões TCP ativas do processo.
   - Exibe informações detalhadas, como:
     - Nome do processo SQL.
     - Endereço e porta local.
     - Endereço e porta remota.
     - Estado da conexão (por exemplo, *Established* ou *Listening*).

3. As informações são exibidas em formato tabular para facilitar a leitura.

### Campos Retornados:
- **Process_Name**: Nome do processo SQL relacionado.
- **Local_Address**: Endereço IP e porta local usada pela conexão.
- **Remote_Address**: Endereço IP e porta remota da conexão.
- **State**: Estado da conexão TCP.

```PS1
ForEach ($SQL_Proc in Get-Process | Select-Object -Property ProcessName, Id | Where-Object {$_.ProcessName -like "*SQL*"})
{
    Get-NetTCPConnection | `
     Where-Object {$_.OwningProcess -eq $SQL_Proc.id} | `
      Select-Object -Property `
                                @{Label ="Process_Name";e={$SQL_Proc.ProcessName}}, `
                                @{Label ="Local_Address";e={$_.LocalAddress + ":" + $_.LocalPort }},  `
                                @{Label ="Remote_Address";e={$_.RemoteAddress + ":" + $_.RemotePort}}, State | `
      Format-Table
} 
```