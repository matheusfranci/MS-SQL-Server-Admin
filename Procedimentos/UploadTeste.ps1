$url = "https://ps.uci.edu/~franklin/doc/file_upload.html"
$file = "D:\stop.bat"
Invoke-WebRequest -Uri $url -Method POST -InFile $file
