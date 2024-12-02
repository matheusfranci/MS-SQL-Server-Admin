# Descrição dos Scripts de Monitoramento de Mudanças com CDC no SQL Server

Este conjunto de scripts lida com o **Change Data Capture (CDC)** no SQL Server, que permite capturar e monitorar alterações (inserções, atualizações e exclusões) em tabelas específicas. Cada script abaixo realiza operações relacionadas ao CDC.

## 1. Consultando databases com CDC ativo

O script verifica quais bancos de dados têm o CDC habilitado.

## 2. Consultando tabelas monitoradas com CDC

Este script lista as tabelas que estão sendo monitoradas pelo CDC.

## 3. Habilitando o CDC em um database (Nível 1)

O script habilita o CDC em um banco de dados específico. Ele cria o schema `cdc` e várias tabelas internas para gerenciar o CDC. Também permite consultar as tabelas internas de controle do CDC, como `change_tables`, `captured_columns`, entre outras.

## 4. Habilitando o CDC e monitorando alterações nas tabelas (Nível 2)

O script cria uma tabela exemplo (`Clientes`) e habilita o CDC para monitorar as alterações nela. Também permite monitorar alterações em colunas específicas da tabela.

## 5. Consultando as alterações nas tabelas

Após habilitar o CDC, o script permite consultar as alterações feitas nas tabelas monitoradas. Você pode visualizar as inserções, atualizações e exclusões feitas nas tabelas com CDC habilitado.

## 6. Desativando o CDC em um database (Nível 1)

Este script desativa o CDC a nível de banco de dados, o que também desativa o monitoramento nas tabelas e remove os dados históricos.

## 7. Desativando o CDC em uma tabela (Nível 2)

Para desativar o CDC em uma tabela específica, o script consulta a instância de captura e depois usa o comando para desativar o CDC nessa tabela. Após desativar o CDC, a tabela de monitoramento será excluída automaticamente.

## 8. CDC e operações de Backup/Restore

Este script lida com a preservação do CDC durante operações de backup e restauração. Se o backup for restaurado na mesma instância, o CDC permanecerá ativo. Se restaurado em outra instância ou com outro nome de banco, o CDC será desativado, a menos que o parâmetro `KEEP_CDC` seja utilizado. Após a restauração, o script permite recriar os jobs necessários para o CDC funcionar corretamente.

```sql
----------------------------------------------
-- Quais databases estão com o CDC ativo?
----------------------------------------------

SELECT [name]
FROM sys.databases
WHERE is_cdc_enabled = 1
```

```sql
----------------------------------------------
-- Quais tabelas estão sendo monitoradas com CDC?
----------------------------------------------

SELECT [name]
FROM sys.tables
WHERE is_tracked_by_cdc = 1
```

```sql
----------------------------------------------
-- Como habilitar o CDC em um database (Nível 1)
----------------------------------------------

USE db 
GO

EXEC sys.sp_cdc_enable_db 
GO
```

```sql
-- Novo schema criado
SELECT SCHEMA_ID('cdc')
```

```sql
-- Novas tabelas internas criadas
SELECT *
FROM sys.tables
WHERE [schema_id] = SCHEMA_ID('cdc')
```

```sql
-- Consultando as novas tabelas
SELECT * FROM cdc.change_tables
SELECT * FROM cdc.captured_columns
SELECT * FROM cdc.ddl_history
SELECT * FROM cdc.index_columns
SELECT * FROM cdc.lsn_time_mapping
```

```sql
----------------------------------------------
-- Como ativar o CDC e monitorar alterações nas tabelas (Nível 2)
----------------------------------------------

USE [db]
GO 

IF (OBJECT_ID('dbo.Clientes') IS NOT NULL) DROP TABLE dbo.Clientes
CREATE TABLE dbo.Clientes (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
    Nome VARCHAR(100),
    Teste VARCHAR(50)
) WITH(DATA_COMPRESSION=PAGE)

EXEC sys.sp_cdc_enable_table 
    @source_schema = N'dbo', 
    @source_name   = N'Clientes', 
    @role_name     = NULL 
GO
```

```sql
-- Caso você queira monitorar as alterações em colunas específicas
EXEC sys.sp_cdc_enable_table 
    @source_schema = N'dbo', 
    @source_name   = N'Clientes', 
    @role_name     = NULL,
    @captured_column_list = '[Id], [Nome], [Teste]'
GO
```

/*

cdc.db_capture: Job que é executado sempre que o SQL Server Agent é iniciado e executa a SP 
de sistema sys.sp_MScdc_capture_job, que por sua vez, executa a SP sys.sp_cdc_scan, iniciando o 
monitoramento da tabela.

cdc.db_cleanup: Job que é executado diariamente às 02:00 e tem a finalidade de controlar o tamanho 
das tabelas de controle do CDC, para evitar que elas cresçam descontroladamente. Esse job executa a SP de 
sistema sys.sp_MScdc_cleanup_job, que por sua vez, executa a SP sys.sp_cdc_cleanup_job_internal.

*/

```sql
----------------------------------------------
-- Consultando as alterações nas tabelas
----------------------------------------------

SELECT * FROM cdc.dbo_Clientes_CT


INSERT INTO dbo.Clientes (Nome)
VALUES('Dirceu Resende'), ('Jéssica Lima'), ('Teste 1'), ('Teste 2'), ('Teste 3')

SELECT * FROM cdc.dbo_Clientes_CT



UPDATE dbo.Clientes
SET Nome = 'Teste CDC'
WHERE Nome = 'Teste 1'

UPDATE dbo.Clientes
SET Nome = 'Teste CDC 2'
WHERE Nome = 'Teste 2'

SELECT * FROM cdc.dbo_Clientes_CT

DELETE FROM cdc.dbo_Clientes_CT WHERE Nome = 'Teste CDC 2'

SELECT * FROM cdc.dbo_Clientes_CT

TRUNCATE TABLE dbo.Clientes
```

```sql
----------------------------------------------
-- Como desativar o CDC em um database (Nível 1)
----------------------------------------------

USE [db]
GO

EXEC sys.sp_cdc_disable_db
GO
```

/* 

Vale lembrar que ao desativar o CDC a nível de database, TODOS os monitoramentos ativos do CDC a 
nível de tabela também serão desativados e os dados de histórico serão todos perdidos também 
(e você NÃO será alertado sobre a existência desses monitoramentos ativos a nível de tabela).

*/


----------------------------------------------
-- Como desativar o CDC em uma tabela (Nível 2)
----------------------------------------------

/*

Para desativar o CDC de uma tabela específica, você precisará primeiro identificar o nome da instância de 
captura do CDC, utilizando a SP sys.sp_cdc_help_change_data_capture ou consultando a cdc.change_tables, 
para depois desativar o monitoramento com a SP sys.sp_cdc_disable_table.

Vale lembrar que é possível desativar o CDC a nível de database, mesmo que existam monitoramentos ativos a 
nível de tabela (e você NÃO será alertado sobre a existência disso). No final desse tópico eu deixei alguns 
alertas sobre o que acontece quando você faz isso.. Leia até o final!

*/

```sql
USE [db]
GO

EXEC sys.sp_cdc_help_change_data_capture
GO

SELECT OBJECT_NAME([object_id]), OBJECT_NAME(source_object_id), capture_instance
FROM cdc.change_tables
```

```sql
-- Uma vez que identificamos o nome da instância (dbo_Clientes), agora podemos executar 
-- a sys.sp_cdc_disable_table
USE [db]
GO

EXEC sys.sp_cdc_disable_table
    @source_schema = 'dbo', -- sysname
    @source_name = 'Clientes', -- sysname
    @capture_instance = 'dbo_Clientes' -- sysname
```

/*

Após desativar o CDC na tabela, vocês podem observar que a tabela de monitoramento foi excluída automaticamente. 
MUITO CUIDADO com isso, para não perder os valores gravados e perder o seu histórico. Caso você queira 
desativar o CDC, mas não tem a intenção de perder o histórico, copie os dados da tabela de histórico para 
outra tabela antes de desativar o CDC na tabela.

*/

----------------------------------------------
-- Change Data Capture (CDC) e operações de Backup/Restore
----------------------------------------------

/*

Restaurando o mesmo database, na mesma instância
-------------------------------------------------------------------------------------------------------------
Nessa situação, o restore será feito normalmente e o CDC continuá ativo e funcionando após a base ser restaurada. 
Nada muda.


Restaurando o backup na mesma instância, mas com outro nome de database ou em outra instância
-------------------------------------------------------------------------------------------------------------
Nesses dois casos, o CDC será desativado e as informações de metadados gravadas serão perdidas, o que seria 
algo bem ruim. Para que isso não aconteça, você deverá utilizar o parâmetro keep_cdc no comando de restore.

*/

-- Exemplo
```sql
RESTORE DATABASE 
    [db]
FROM 
    DISK = 'C:\Backups\db.bak' 
WITH 
    MOVE 'db_dados' TO 'C:\Dados\db_dados.mdf',
    MOVE 'db_log' TO 'C:\Dados\db_log.ldf', 
    KEEP_CDC
```

```sql
-- Após o restore, você precisará executar os comandos abaixo para recriar os jobs do CDC:

USE [db]
GO

exec sys.sp_cdc_add_job 'capture'
GO

exec sys.sp_cdc_add_job 'cleanup'
GO
```