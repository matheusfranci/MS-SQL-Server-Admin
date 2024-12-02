# Descri��o dos Scripts de Monitoramento de Mudan�as com CDC no SQL Server

Este conjunto de scripts lida com o **Change Data Capture (CDC)** no SQL Server, que permite capturar e monitorar altera��es (inser��es, atualiza��es e exclus�es) em tabelas espec�ficas. Cada script abaixo realiza opera��es relacionadas ao CDC.

## 1. Consultando databases com CDC ativo

O script verifica quais bancos de dados t�m o CDC habilitado.

## 2. Consultando tabelas monitoradas com CDC

Este script lista as tabelas que est�o sendo monitoradas pelo CDC.

## 3. Habilitando o CDC em um database (N�vel 1)

O script habilita o CDC em um banco de dados espec�fico. Ele cria o schema `cdc` e v�rias tabelas internas para gerenciar o CDC. Tamb�m permite consultar as tabelas internas de controle do CDC, como `change_tables`, `captured_columns`, entre outras.

## 4. Habilitando o CDC e monitorando altera��es nas tabelas (N�vel 2)

O script cria uma tabela exemplo (`Clientes`) e habilita o CDC para monitorar as altera��es nela. Tamb�m permite monitorar altera��es em colunas espec�ficas da tabela.

## 5. Consultando as altera��es nas tabelas

Ap�s habilitar o CDC, o script permite consultar as altera��es feitas nas tabelas monitoradas. Voc� pode visualizar as inser��es, atualiza��es e exclus�es feitas nas tabelas com CDC habilitado.

## 6. Desativando o CDC em um database (N�vel 1)

Este script desativa o CDC a n�vel de banco de dados, o que tamb�m desativa o monitoramento nas tabelas e remove os dados hist�ricos.

## 7. Desativando o CDC em uma tabela (N�vel 2)

Para desativar o CDC em uma tabela espec�fica, o script consulta a inst�ncia de captura e depois usa o comando para desativar o CDC nessa tabela. Ap�s desativar o CDC, a tabela de monitoramento ser� exclu�da automaticamente.

## 8. CDC e opera��es de Backup/Restore

Este script lida com a preserva��o do CDC durante opera��es de backup e restaura��o. Se o backup for restaurado na mesma inst�ncia, o CDC permanecer� ativo. Se restaurado em outra inst�ncia ou com outro nome de banco, o CDC ser� desativado, a menos que o par�metro `KEEP_CDC` seja utilizado. Ap�s a restaura��o, o script permite recriar os jobs necess�rios para o CDC funcionar corretamente.

```sql
----------------------------------------------
-- Quais databases est�o com o CDC ativo?
----------------------------------------------

SELECT [name]
FROM sys.databases
WHERE is_cdc_enabled = 1
```

```sql
----------------------------------------------
-- Quais tabelas est�o sendo monitoradas com CDC?
----------------------------------------------

SELECT [name]
FROM sys.tables
WHERE is_tracked_by_cdc = 1
```

```sql
----------------------------------------------
-- Como habilitar o CDC em um database (N�vel 1)
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
-- Como ativar o CDC e monitorar altera��es nas tabelas (N�vel 2)
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
-- Caso voc� queira monitorar as altera��es em colunas espec�ficas
EXEC sys.sp_cdc_enable_table 
    @source_schema = N'dbo', 
    @source_name   = N'Clientes', 
    @role_name     = NULL,
    @captured_column_list = '[Id], [Nome], [Teste]'
GO
```

/*

cdc.db_capture: Job que � executado sempre que o SQL Server Agent � iniciado e executa a SP 
de sistema sys.sp_MScdc_capture_job, que por sua vez, executa a SP sys.sp_cdc_scan, iniciando o 
monitoramento da tabela.

cdc.db_cleanup: Job que � executado diariamente �s 02:00 e tem a finalidade de controlar o tamanho 
das tabelas de controle do CDC, para evitar que elas cres�am descontroladamente. Esse job executa a SP de 
sistema sys.sp_MScdc_cleanup_job, que por sua vez, executa a SP sys.sp_cdc_cleanup_job_internal.

*/

```sql
----------------------------------------------
-- Consultando as altera��es nas tabelas
----------------------------------------------

SELECT * FROM cdc.dbo_Clientes_CT


INSERT INTO dbo.Clientes (Nome)
VALUES('Dirceu Resende'), ('J�ssica Lima'), ('Teste 1'), ('Teste 2'), ('Teste 3')

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
-- Como desativar o CDC em um database (N�vel 1)
----------------------------------------------

USE [db]
GO

EXEC sys.sp_cdc_disable_db
GO
```

/* 

Vale lembrar que ao desativar o CDC a n�vel de database, TODOS os monitoramentos ativos do CDC a 
n�vel de tabela tamb�m ser�o desativados e os dados de hist�rico ser�o todos perdidos tamb�m 
(e voc� N�O ser� alertado sobre a exist�ncia desses monitoramentos ativos a n�vel de tabela).

*/


----------------------------------------------
-- Como desativar o CDC em uma tabela (N�vel 2)
----------------------------------------------

/*

Para desativar o CDC de uma tabela espec�fica, voc� precisar� primeiro identificar o nome da inst�ncia de 
captura do CDC, utilizando a SP sys.sp_cdc_help_change_data_capture ou consultando a cdc.change_tables, 
para depois desativar o monitoramento com a SP sys.sp_cdc_disable_table.

Vale lembrar que � poss�vel desativar o CDC a n�vel de database, mesmo que existam monitoramentos ativos a 
n�vel de tabela (e voc� N�O ser� alertado sobre a exist�ncia disso). No final desse t�pico eu deixei alguns 
alertas sobre o que acontece quando voc� faz isso.. Leia at� o final!

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
-- Uma vez que identificamos o nome da inst�ncia (dbo_Clientes), agora podemos executar 
-- a sys.sp_cdc_disable_table
USE [db]
GO

EXEC sys.sp_cdc_disable_table
    @source_schema = 'dbo', -- sysname
    @source_name = 'Clientes', -- sysname
    @capture_instance = 'dbo_Clientes' -- sysname
```

/*

Ap�s desativar o CDC na tabela, voc�s podem observar que a tabela de monitoramento foi exclu�da automaticamente. 
MUITO CUIDADO com isso, para n�o perder os valores gravados e perder o seu hist�rico. Caso voc� queira 
desativar o CDC, mas n�o tem a inten��o de perder o hist�rico, copie os dados da tabela de hist�rico para 
outra tabela antes de desativar o CDC na tabela.

*/

----------------------------------------------
-- Change Data Capture (CDC) e opera��es de Backup/Restore
----------------------------------------------

/*

Restaurando o mesmo database, na mesma inst�ncia
-------------------------------------------------------------------------------------------------------------
Nessa situa��o, o restore ser� feito normalmente e o CDC continu� ativo e funcionando ap�s a base ser restaurada. 
Nada muda.


Restaurando o backup na mesma inst�ncia, mas com outro nome de database ou em outra inst�ncia
-------------------------------------------------------------------------------------------------------------
Nesses dois casos, o CDC ser� desativado e as informa��es de metadados gravadas ser�o perdidas, o que seria 
algo bem ruim. Para que isso n�o aconte�a, voc� dever� utilizar o par�metro keep_cdc no comando de restore.

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
-- Ap�s o restore, voc� precisar� executar os comandos abaixo para recriar os jobs do CDC:

USE [db]
GO

exec sys.sp_cdc_add_job 'capture'
GO

exec sys.sp_cdc_add_job 'cleanup'
GO
```