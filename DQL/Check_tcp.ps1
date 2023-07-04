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
