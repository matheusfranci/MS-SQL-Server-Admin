# Procedimento Armazenado: `stpExporta_Tabela_HTML_Output`

Este procedimento armazenado é utilizado para exportar os dados de uma tabela SQL Server no formato HTML. Ele permite a personalização do estilo padrão do HTML e gera o código como uma string de saída. Abaixo está a descrição detalhada das funcionalidades:

## Parâmetros
- **`@Ds_Tabela`** *(varchar(max))*: Nome completo da tabela (com prefixo do banco, se necessário). Tabelas temporárias devem começar com `#`.
- **`@Fl_Aplica_Estilo_Padrao`** *(bit, padrão = 1)*: Define se o estilo HTML padrão será aplicado ao output.
- **`@Ds_Saida`** *(varchar(max), OUTPUT)*: Variável de saída que contém o código HTML gerado.

## Funcionalidades
1. **Identificação da Tabela**:
   - Verifica se a tabela é temporária (`#`) ou uma tabela normal e ajusta o nome do banco e tabela adequadamente.

2. **Recuperação da Estrutura da Tabela**:
   - Usa a visão `INFORMATION_SCHEMA.COLUMNS` para obter informações sobre as colunas da tabela, como nome, tipo de dados e características adicionais.

3. **Geração de Cabeçalho HTML**:
   - Cria a estrutura básica de uma página HTML com suporte opcional a estilos CSS, incluindo definição de tabela e células.

4. **Criação do Cabeçalho da Tabela**:
   - Adiciona as colunas como cabeçalhos (`<th>`) no HTML, garantindo alinhamento com a estrutura da tabela no banco de dados.

5. **Geração do Conteúdo da Tabela**:
   - Preenche as linhas da tabela (`<tr>`) com os valores das colunas em formato HTML (`<td>`), utilizando `FOR XML RAW` para estruturar os dados no formato desejado.

6. **Saída Formatada**:
   - Realiza a indentação do HTML gerado para melhorar a legibilidade.
   - Concatena todos os elementos em uma string única que é atribuída ao parâmetro de saída.

## Observações
- Este procedimento é útil para exportações rápidas de tabelas para visualização ou compartilhamento no formato HTML.
- O estilo padrão pode ser desativado definindo o parâmetro `@Fl_Aplica_Estilo_Padrao` como `0`.

## Exemplo de Uso
```sql
DECLARE @htmlOutput VARCHAR(MAX)
EXEC [dbo].[stpExporta_Tabela_HTML_Output] 
    @Ds_Tabela = 'dbo.MinhaTabela', 
    @Fl_Aplica_Estilo_Padrao = 1, 
    @Ds_Saida = @htmlOutput OUTPUT

PRINT @htmlOutput
```

```SQL
-- DDL da procedure
CREATE PROCEDURE [dbo].[stpExporta_Tabela_HTML_Output]
    @Ds_Tabela [varchar](max),
    @Fl_Aplica_Estilo_Padrao BIT = 1,
    @Ds_Saida VARCHAR(MAX) OUTPUT
AS
BEGIN
    
    
    SET NOCOUNT ON
    
    
    DECLARE
        @query NVARCHAR(MAX),
        @Database sysname,
        @Nome_Tabela sysname

    
    
    IF (LEFT(@Ds_Tabela, 1) = '#')
    BEGIN
        SET @Database = 'tempdb.'
        SET @Nome_Tabela = @Ds_Tabela
    END
    ELSE BEGIN
        SET @Database = LEFT(@Ds_Tabela, CHARINDEX('.', @Ds_Tabela))
        SET @Nome_Tabela = SUBSTRING(@Ds_Tabela, LEN(@Ds_Tabela) - CHARINDEX('.', REVERSE(@Ds_Tabela)) + 2, LEN(@Ds_Tabela))
    END

    
    SET @query = '
    SELECT ORDINAL_POSITION, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_SCALE
    FROM ' + @Database + 'INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = ''' + @Nome_Tabela + '''
    ORDER BY ORDINAL_POSITION'
    
    
    IF (OBJECT_ID('tempdb..#Colunas') IS NOT NULL) DROP TABLE #Colunas
    CREATE TABLE #Colunas (
        ORDINAL_POSITION int, 
        COLUMN_NAME sysname, 
        DATA_TYPE nvarchar(128), 
        CHARACTER_MAXIMUM_LENGTH int,
        NUMERIC_PRECISION tinyint, 
        NUMERIC_SCALE int
    )

    INSERT INTO #Colunas
    EXEC(@query)

    
    
    IF (@Fl_Aplica_Estilo_Padrao = 1)
    BEGIN
    
    SET @Ds_Saida = '<html>
<head>
    <title>Titulo</title>
    <style type="text/css">
        table { padding:0; border-spacing: 0; border-collapse: collapse; }
        thead { background: #00B050; border: 1px solid #ddd; }
        th { padding: 10px; font-weight: bold; border: 1px solid #000; color: #fff; }
        tr { padding: 0; }
        td { padding: 5px; border: 1px solid #cacaca; margin:0; }
    </style>
</head>'
    
    END
    
    
    
    SET @Ds_Saida = ISNULL(@Ds_Saida, '') + '
<table>
    <thead>
        <tr>'


    -- Cabeçalho da tabela
    DECLARE 
        @contadorColuna INT = 1, 
        @totalColunas INT = (SELECT COUNT(*) FROM #Colunas), 
        @nomeColuna sysname,
        @tipoColuna sysname
    

    WHILE(@contadorColuna <= @totalColunas)
    BEGIN

        SELECT @nomeColuna = COLUMN_NAME
        FROM #Colunas
        WHERE ORDINAL_POSITION = @contadorColuna


        SET @Ds_Saida = ISNULL(@Ds_Saida, '') + '
            <th>' + @nomeColuna + '</th>'


        SET @contadorColuna = @contadorColuna + 1

    END



    SET @Ds_Saida = ISNULL(@Ds_Saida, '') + '
        </tr>
    </thead>
    <tbody>'


    
    -- Conteúdo da tabela

    DECLARE @saida VARCHAR(MAX)

    SET @query = '
SELECT @saida = (
    SELECT '


    SET @contadorColuna = 1

    WHILE(@contadorColuna <= @totalColunas)
    BEGIN

        SELECT 
            @nomeColuna = COLUMN_NAME,
            @tipoColuna = DATA_TYPE
        FROM 
            #Colunas
        WHERE 
            ORDINAL_POSITION = @contadorColuna



        IF (@tipoColuna IN ('int', 'bigint', 'float', 'numeric', 'decimal', 'bit', 'tinyint', 'smallint', 'integer'))
        BEGIN
        
            SET @query = @query + '
    ISNULL(CAST([' + @nomeColuna + '] AS VARCHAR(MAX)), '''') AS [td]'
    
        END
        ELSE BEGIN
        
            SET @query = @query + '
    ISNULL([' + @nomeColuna + '], '''') AS [td]'
    
        END
    
        
        IF (@contadorColuna < @totalColunas)
            SET @query = @query + ','

        
        SET @contadorColuna = @contadorColuna + 1

    END



    SET @query = @query + '
FROM ' + @Ds_Tabela + '
FOR XML RAW(''tr''), Elements
)'
    
    
    EXEC tempdb.sys.sp_executesql
        @query,
        N'@saida NVARCHAR(MAX) OUTPUT',
        @saida OUTPUT


    -- Identação
    SET @saida = REPLACE(@saida, '<tr>', '
        <tr>')

    SET @saida = REPLACE(@saida, '<td>', '
            <td>')

    SET @saida = REPLACE(@saida, '</tr>', '
        </tr>')


    SET @Ds_Saida = ISNULL(@Ds_Saida, '') + @saida


    
    SET @Ds_Saida = ISNULL(@Ds_Saida, '') + '
    </tbody>
</table>'
    
            
END
```