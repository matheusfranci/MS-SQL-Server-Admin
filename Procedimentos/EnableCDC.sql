-- Habilitando CDC
EXEC sys.sp_cdc_enable_db;

-- Verificando os bancos com o CDB habilitado
SELECT name, is_cdc_enabled,
CASE 
WHEN is_cdc_enabled = 1 THEN 'Habilitado'
ELSE 'Desabilitado'
END AS 'Status CDC'
FROM sys.databases 
WHERE name = 'NomeDoBancoDeDados';

-- Implementando na tabela:
USE NomeDoBancoDeDados;
EXEC sys.sp_cdc_enable_table
    @source_schema = N'EsquemaDaTabela',
    @source_name = N'NomeDaTabela',
    @role_name = NULL;

-- Validando
SELECT * FROM cdc.change_tables;

