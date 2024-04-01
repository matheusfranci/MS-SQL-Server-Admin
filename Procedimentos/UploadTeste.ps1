$url = "https://ps.uci.edu/~franklin/doc/file_upload.html"
$file = "C:\app\teste.txt"
Invoke-WebRequest -Uri $url -Method POST -InFile $file
