# Geração de Scripts BULK INSERT Dinâmicos a partir de Arquivos em uma Pasta

Este script SQL cria um procedimento armazenado temporário (`##ListFilesInFolder`) que lista arquivos em uma pasta específica ("G:\AWS") usando PowerShell e gera dinamicamente scripts `BULK INSERT` para importar dados desses arquivos para uma tabela no SQL Server (`dbo.HISTORICO_TRABALHADOR_NEW`).

## Visão Geral do Script

O script executa as seguintes etapas:

1.  **Criação do Procedimento Armazenado Temporário `##ListFilesInFolder`:**
    * Desativa `NOCOUNT` para evitar mensagens de contagem de linhas.
    * Cria uma tabela temporária `#TempResults` para armazenar a saída do comando PowerShell.
    * Executa um comando PowerShell usando `xp_cmdshell` para listar os nomes dos arquivos na pasta "G:\AWS".
    * Insere os nomes dos arquivos na tabela temporária `#TempResults`.
    * Gera scripts `BULK INSERT` para cada arquivo, substituindo o nome do arquivo na string do comando.
    * Filtra os resultados para excluir linhas indesejadas (NULL, Name, ----, OLD).
    * Exibe os scripts `BULK INSERT` gerados.
    * Remove a tabela temporária `#TempResults`.
2.  **Execução do Procedimento Armazenado `##ListFilesInFolder`:** Executa o procedimento armazenado para gerar os scripts `BULK INSERT`.
3.  **Remoção do Procedimento Armazenado `##ListFilesInFolder`:** Remove o procedimento armazenado temporário.

## Detalhes do Script

```sql
CREATE PROCEDURE ##ListFilesInFolder
AS
BEGIN
    SET NOCOUNT ON;
    -- Tabela temporária para armazenar os resultados
    CREATE TABLE #TempResults (OutputLine NVARCHAR(4000));

    -- Inserção dos resultados do comando PowerShell na tabela temporária
    INSERT INTO #TempResults
    EXEC xp_cmdshell 'powershell.exe -Command "Get-ChildItem -Path \"G:\AWS\" | Select-Object -ExpandProperty Name"'

    SELECT REPLACE('''
BULK INSERT dbo.HISTORICO_TRABALHADOR_NEW
FROM '''+ OutputLine +'''
WITH
(
FORMAT=''CSV'',
FIRSTROW=2,
CODEPAGE = ''65001'',
FIELDTERMINATOR = ''|'',
ROWTERMINATOR = ''0x0A'',
--MAXERRORS = 1000,
KEEPNULLS
)
'''
    FROM #TempResults
    WHERE OutputLine NOT IN ('NULL', 'Name', '---- ', 'OLD');
    DROP TABLE #TempResults;
END;
GO
-- Executando a procedure

EXEC ##ListFilesInFolder;

DROP PROCEDURE ##ListFilesInFolder
