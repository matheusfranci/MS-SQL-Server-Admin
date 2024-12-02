# Descrição do Script

Este script demonstra como trabalhar com Tabelas Temporais (ou Versionadas) no SQL Server, abordando desde a consulta de tabelas temporais, criação, conversão de tabelas comuns para temporais, até a consulta e desativação do versionamento. Além disso, inclui exemplos de como fazer expurgo de dados antigos.

### Passos do Script:

1. **Consultando Tabelas Temporais**:
   - A primeira parte do script consulta a tabela `sys.tables` para identificar quais tabelas na base de dados são temporais, ou seja, têm versionamento ativado. O script retorna o nome da tabela, o ID do objeto, o tipo de versão, a tabela de histórico associada, e outras informações.

2. **Como Criar uma Tabela Temporal (Versionada)**:
   - O script cria uma tabela chamada `Tabela_Temporal`, com campos para armazenar dados e colunas adicionais para armazenar as informações de início e fim de validade (metadados do versionamento).
   - Ele também ativa o versionamento de sistema (`SYSTEM_VERSIONING = ON`) e cria a tabela de histórico associada (`Tabela_Temporal_Historico`).

3. **Como Converter uma Tabela Comum para Tabela Temporal**:
   - O script mostra como converter uma tabela comum (`Tabela_Comum`) em uma tabela temporal. Para isso, ele desativa o versionamento na tabela original, adiciona as colunas de controle temporal (início e fim) e ativa o versionamento, criando uma tabela de histórico.
   - Caso a tabela já possua registros, o script também inclui a criação das colunas de controle de validade com valores padrão.

4. **Consultando os Dados de uma Tabela Temporal**:
   - O script insere alguns dados de exemplo na tabela temporal `Tabela_Temporal` e realiza diversas consultas para mostrar como obter informações do histórico de alterações:
     - `FOR SYSTEM_TIME ALL`: Retorna todas as alterações feitas na tabela.
     - `FOR SYSTEM_TIME AS OF`: Retorna as alterações feitas em um ponto específico no tempo.
     - `FOR SYSTEM_TIME FROM ... TO`: Retorna as alterações feitas em um intervalo de tempo.
     - `FOR SYSTEM_TIME BETWEEN`: Retorna as alterações feitas entre duas datas.
     - `FOR SYSTEM_TIME CONTAINED IN`: Retorna as alterações feitas dentro de um intervalo de datas.

5. **Como Desativar o Versionamento de uma Tabela Temporal**:
   - O script mostra como desativar o versionamento em uma tabela temporal, removendo as colunas de controle temporal e apagando a tabela de histórico associada.

6. **Expurgo de Dados de Tabelas Temporais**:
   - Para realizar o expurgo de dados antigos, o script desativa o versionamento, deleta os registros históricos com mais de 30 dias da tabela `Tabela_Temporal_Historico`, e reativa o versionamento.

### Considerações:
- **Tabelas Temporais**: O recurso de tabelas temporais é muito útil para rastrear alterações ao longo do tempo, mantendo o histórico de registros sem a necessidade de operações manuais.
- **Versionamento**: O `SYSTEM_VERSIONING` permite que você mantenha automaticamente o histórico das alterações, facilitando a auditoria e consultas em períodos específicos.
- **Consultas Temporais**: As consultas com `FOR SYSTEM_TIME` são essenciais para realizar auditorias e entender como os dados evoluíram ao longo do tempo.
- **Expurgo**: A prática de expurgo é importante para manter a performance e reduzir o tamanho da tabela de histórico, removendo dados antigos que não são mais necessários.

Este script oferece uma maneira eficaz de gerenciar e auditar dados históricos no SQL Server utilizando tabelas temporais.

```sql
USE [Auditoria]
GO

----------------------------------------------------
-- -- Quais tabelas são temporais na minha base?
----------------------------------------------------

SELECT
    A.[name],
    A.[object_id],
    A.temporal_type,
    A.temporal_type_desc,
    A.history_table_id,
    B.[name]
FROM
    sys.tables A
    LEFT JOIN sys.tables B ON B.[object_id] = A.history_table_id
WHERE
    A.temporal_type <> 0
ORDER BY
    A.[name]
```

```sql
----------------------------------------------------
-- Como criar uma Tabela Temporal (Versionada)?
----------------------------------------------------

IF (OBJECT_ID('dbo.Tabela_Temporal') IS NOT NULL) 
BEGIN
    ALTER TABLE dbo.Tabela_Temporal SET (SYSTEM_VERSIONING=OFF)
    ALTER TABLE dbo.Tabela_Temporal DROP PERIOD FOR SYSTEM_TIME;
    
	ALTER TABLE dbo.Tabela_Temporal DROP COLUMN Dt_Inicio, Dt_Fim;
    IF (OBJECT_ID('dbo.Tabela_Temporal_Historico') IS NOT NULL) DROP TABLE dbo.Tabela_Temporal_Historico

    DROP TABLE dbo.Tabela_Temporal

END
```

```sql
CREATE TABLE dbo.Tabela_Temporal (
    
    -- Dados normais da tabela
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Ds_Nome VARCHAR(100) NOT NULL,
    Dt_Nascimento DATETIME NOT NULL,
    Nr_Telefone VARCHAR(15) NOT NULL,
    Nr_CPF VARCHAR(14) NOT NULL,

    -- Informações referentes ao versionamento (Temporal table)
    Dt_Inicio DATETIME2(0) GENERATED ALWAYS AS ROW START, 
    Dt_Fim DATETIME2(0) GENERATED ALWAYS AS ROW END, 
    PERIOD FOR SYSTEM_TIME (Dt_Inicio, Dt_Fim)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Tabela_Temporal_Historico))
```

```sql
----------------------------------------------------
-- Como converter uma tabela comum para Tabela Temporal?
----------------------------------------------------

IF (OBJECT_ID('dbo.Tabela_Comum') IS NOT NULL) 
BEGIN
    ALTER TABLE dbo.Tabela_Comum SET (SYSTEM_VERSIONING=OFF);
    ALTER TABLE dbo.Tabela_Comum DROP PERIOD FOR SYSTEM_TIME;

    DROP TABLE dbo.Tabela_Comum
END


CREATE TABLE dbo.Tabela_Comum (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Ds_Nome VARCHAR(100) NOT NULL,
    Dt_Nascimento DATETIME NOT NULL,
    Nr_Telefone VARCHAR(15) NOT NULL,
    Nr_CPF VARCHAR(14) NOT NULL,
) WITH(DATA_COMPRESSION=PAGE)

INSERT INTO dbo.Tabela_Comum
VALUES ( 'Dirceu Resende', '1987-05-28', '111111', '22222' )
```

```sql
-- Crio as colunas de metadados para controlar a validade dos registros
ALTER TABLE dbo.Tabela_Comum ADD 
    Dt_Inicio DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL, 
    Dt_Fim DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME (Dt_Inicio, Dt_Fim)
```

```sql
-- Ativo o versionamento na tabela
ALTER TABLE dbo.Tabela_Comum SET (SYSTEM_VERSIONING=ON (HISTORY_TABLE = dbo.Tabela_Comum_Historico))
```

```sql
----------------------------------------------------
-- E se a tabela já possuir registros ?
----------------------------------------------------

-- Criação normal de uma tabela
IF (OBJECT_ID('dbo.Tabela_Comum') IS NOT NULL) 
BEGIN
    ALTER TABLE dbo.Tabela_Comum SET (SYSTEM_VERSIONING=OFF)
    DROP TABLE dbo.Tabela_Comum
END


CREATE TABLE dbo.Tabela_Comum (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Ds_Nome VARCHAR(100) NOT NULL,
    Dt_Nascimento DATETIME NOT NULL,
    Nr_Telefone VARCHAR(15) NOT NULL,
    Nr_CPF VARCHAR(14) NOT NULL,
) WITH(DATA_COMPRESSION=PAGE)


INSERT INTO dbo.Tabela_Comum
(
    Ds_Nome,
    Dt_Nascimento,
    Nr_Telefone,
    Nr_CPF
)
VALUES
(
    'Dirceu Resende', -- Ds_Nome - varchar(100)
    '1990-01-01', -- Dt_Nascimento - datetime
    '2799999999', -- Nr_Telefone - varchar(15)
    '11111111111' -- Nr_CPF - varchar(14)
)
```

```sql
-- Crio as colunas de metadados para controlar a validade dos registros
ALTER TABLE dbo.Tabela_Comum ADD 
    Dt_Inicio DATETIME2 GENERATED ALWAYS AS ROW START CONSTRAINT DF_Tabela_Comum_Dt_Inicio DEFAULT SYSUTCDATETIME() NOT NULL, 
    Dt_Fim DATETIME2 GENERATED ALWAYS AS ROW END CONSTRAINT DF_Tabela_Comum_Dt_Fim DEFAULT '9999-12-31 23:59:59.9999999' NOT NULL,
    PERIOD FOR SYSTEM_TIME (Dt_Inicio, Dt_Fim)
```

```sql
-- Ativo o versionamento na tabela
ALTER TABLE dbo.Tabela_Comum SET (SYSTEM_VERSIONING=ON (HISTORY_TABLE = dbo.Tabela_Comum_Historico))
```

```sql
----------------------------------------------------
-- Como consultar os dados da Tabela Temporal?
----------------------------------------------------

INSERT INTO dbo.Tabela_Temporal
(
    Ds_Nome,
    Dt_Nascimento,
    Nr_Telefone,
    Nr_CPF
)
VALUES
(
    'Dirceu Resende', -- Ds_Nome - varchar(100)
    '1900-05-28', -- Dt_Nascimento - datetime
    '2799999999', -- Nr_Telefone - varchar(15)
    '12345678909'
),
(
    'Teste 2', -- Ds_Nome - varchar(100)
    '1900-01-01', -- Dt_Nascimento - datetime
    '27888888888', -- Nr_Telefone - varchar(15)
    '11111111111'
)
GO

UPDATE dbo.Tabela_Temporal
SET Ds_Nome = 'Teste'
WHERE Ds_Nome = 'Teste 2'
GO

UPDATE dbo.Tabela_Temporal
SET Nr_CPF = '22222222222'
WHERE Ds_Nome = 'Dirceu Resende'
GO

DELETE FROM dbo.Tabela_Temporal
WHERE Ds_Nome = 'Teste'
GO
```

```sql
-- Consulta básica
SELECT * FROM dbo.Tabela_Temporal
```

```sql
-- Retorna todas as alterações realizadas na tabela
SELECT * FROM dbo.Tabela_Temporal
FOR SYSTEM_TIME ALL
ORDER BY Dt_Inicio, Id
```

```sql
-- Retorna todas as alterações numa data específica
SELECT * FROM dbo.Tabela_Temporal
FOR SYSTEM_TIME AS OF '2020-12-16 12:02:00'
ORDER BY Dt_Inicio, Id
```

```sql
-- Retorna todas as alterações num intervalo de tempo (Dt_Inicial < data final informada e 
-- campo Dt_Final > data inicial informada)
SELECT * FROM dbo.Tabela_Temporal
FOR SYSTEM_TIME FROM '2020-12-16 12:02:00' TO '2020-12-16 12:03:01'
ORDER BY Dt_Inicio, Id
```

```sql
-- Retorna todas as alterações num intervalo de datas (Dt_Inicial <= data final informada e 
-- campo Dt_Final > data inicial informada)
SELECT * FROM dbo.Tabela_Temporal
FOR SYSTEM_TIME BETWEEN '2020-12-16 12:02:00' AND '2020-12-16 12:03:01'
ORDER BY Dt_Inicio, Id
```

```sql
-- Retorna todas as alterações num intervalo de datas (Dt_Inicial >= data inicial informada e 
-- campo Dt_Final <= data final informada)
SELECT * FROM dbo.Tabela_Temporal
FOR SYSTEM_TIME CONTAINED IN('2020-12-16 12:02:00', '9999-12-31 23:59:59')
ORDER BY Dt_Inicio, Id
```

```sql
----------------------------------------------------
-- Como desativar o versionamento de uma Tabela Temporal?
----------------------------------------------------

-- Desativa temporariamente
ALTER TABLE dbo.Tabela_Temporal SET (SYSTEM_VERSIONING = OFF);

-- Remove os metadados da tabela temporal
ALTER TABLE dbo.Tabela_Temporal DROP PERIOD FOR SYSTEM_TIME;

-- Apaga as colunas de controle temporal na tabela original
ALTER TABLE dbo.Tabela_Temporal DROP COLUMN Dt_Inicio, Dt_Fim;

-- Apaga a tabela de histórico
IF (OBJECT_ID('dbo.Tabela_Temporal_Historico') IS NOT NULL) DROP TABLE dbo.Tabela_Temporal_Historico
```

```sql
----------------------------------------------------
-- Como fazer expurgo dos dados
----------------------------------------------------

ALTER TABLE dbo.Tabela_Temporal SET (SYSTEM_VERSIONING = OFF)
GO

DELETE FROM dbo.Tabela_Temporal_Historico
WHERE Dt_Fim <= DATEADD(DAY, -30, GETDATE())

ALTER TABLE dbo.Tabela_Temporal
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[Tabela_Temporal_Historico], DATA_CONSISTENCY_CHECK = ON))
```