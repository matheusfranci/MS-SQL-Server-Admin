# Habilitação e Monitoramento de CDC no SQL Server

Este script permite habilitar o CDC (Change Data Capture) em um banco de dados SQL Server, monitorar os bancos de dados com CDC habilitado e implementar o CDC em uma tabela específica. A seguir estão os passos executados:

1. **Habilitar CDC no banco de dados**  
   O comando `sp_cdc_enable_db` ativa o CDC para o banco de dados atual.

2. **Verificar bancos habilitados para CDC**  
   A consulta exibe os bancos de dados com CDC habilitado, mostrando o status de cada um.

3. **Habilitar CDC em uma tabela**  
   O procedimento `sp_cdc_enable_table` ativa o CDC em uma tabela específica, permitindo o rastreamento de mudanças de dados.

4. **Validar CDC na tabela**  
   O comando `cdc.change_tables` exibe informações sobre as tabelas que têm o CDC habilitado.

```SQL   
-- Habilitando CDC
EXEC sys.sp_cdc_enable_db;
```

```SQL  
-- Verificando os bancos com o CDB habilitado
SELECT name, is_cdc_enabled,
CASE 
WHEN is_cdc_enabled = 1 THEN 'Habilitado'
ELSE 'Desabilitado'
END AS 'Status CDC'
FROM sys.databases 
WHERE name = 'NomeDoBancoDeDados';
```

```SQL
-- Implementando na tabela:
USE NomeDoBancoDeDados;
EXEC sys.sp_cdc_enable_table
    @source_schema = N'EsquemaDaTabela',
    @source_name = N'NomeDaTabela',
    @role_name = NULL;
```

```SQL
-- Validando
SELECT * FROM cdc.change_tables;
```