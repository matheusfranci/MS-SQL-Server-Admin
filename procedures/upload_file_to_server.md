# Descrição do Script

Este script utiliza o PowerShell para enviar um arquivo para um servidor via HTTP POST. Abaixo estão as etapas realizadas:

## 1. **Definindo a URL de Destino**

O script começa definindo a URL para onde o arquivo será enviado:

```powershell
$url = "https://ps.uci.edu/~franklin/doc/file_upload.html"
```

```powershell
$file = "C:\app\teste.txt"
Invoke-WebRequest -Uri $url -Method POST -InFile $file
```
