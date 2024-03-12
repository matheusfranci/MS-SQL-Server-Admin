

-- Verificando a opção de verificação de página dos databases
SELECT [name], page_verify_option, page_verify_option_desc
FROM sys.databases


-- Alterando a verificação de página dos databases para CHECKSUM
SELECT 'ALTER DATABASE ' + QUOTENAME([name]) + ' SET PAGE_VERIFY CHECKSUM WITH NO_WAIT;'
FROM sys.databases
WHERE page_verify_option_desc <> 'CHECKSUM'
GO