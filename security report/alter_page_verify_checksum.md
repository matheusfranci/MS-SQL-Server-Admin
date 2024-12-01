## Descrição do Script

Este script realiza a verificação e alteração das configurações de verificação de página nos bancos de dados da instância SQL Server. A verificação de página é uma funcionalidade importante para garantir a integridade dos dados nas páginas de dados do banco, identificando e corrigindo falhas de leitura e escrita.

### 1. **Verificação das Configurações de Verificação de Página**
   - O script consulta a tabela `sys.databases` para listar todos os bancos de dados e suas respectivas configurações de verificação de página.
   - Exibe os campos `name` (nome do banco de dados), `page_verify_option` (opção de verificação de página) e `page_verify_option_desc` (descrição da opção de verificação de página).

### 2. **Alteração das Configurações de Verificação de Página para CHECKSUM**
   - O script gera um comando SQL para alterar a opção de verificação de página de todos os bancos de dados onde a configuração atual não é `CHECKSUM`.
   - A configuração `CHECKSUM` é uma das opções recomendadas para garantir maior integridade dos dados, pois verifica as páginas de dados para detectar falhas de leitura e escrita.
   - Utiliza a função `QUOTENAME` para garantir que os nomes dos bancos de dados com espaços ou caracteres especiais sejam corretamente tratados.

### 3. **Execução da Alteração**
   - O comando gerado pode ser executado para ajustar a configuração de verificação de página nos bancos de dados da instância, garantindo que todos eles utilizem a opção `CHECKSUM` para maior segurança.

```SQL
-- Verificando a opção de verificação de página dos databases
SELECT [name], page_verify_option, page_verify_option_desc
FROM sys.databases
```

```SQL
-- Alterando a verificação de página dos databases para CHECKSUM
SELECT 'ALTER DATABASE ' + QUOTENAME([name]) + ' SET PAGE_VERIFY CHECKSUM WITH NO_WAIT;'
FROM sys.databases
WHERE page_verify_option_desc <> 'CHECKSUM'
GO
```