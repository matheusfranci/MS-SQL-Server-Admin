# Descrição do Script

Este script tem como objetivo criar um mecanismo de auditoria para registrar todas as alterações feitas na tabela `Cliente` (inserções, atualizações e exclusões) no banco de dados SQL Server. A auditoria é realizada através de uma trigger que grava um histórico das operações em uma tabela de log separada, chamada `Cliente_Log`.

### Passos do Script:

1. **Criação da Tabela Original `Cliente`**: Cria a tabela `Cliente` com os campos `Id_Cliente`, `Nome`, `Data_Nascimento` e `Salario`. Esta tabela simula um banco de dados de clientes.

2. **Criação da Tabela de Log `Cliente_Log`**: Cria a tabela `Cliente_Log`, que armazena o histórico das alterações realizadas na tabela `Cliente`. Essa tabela inclui informações como:
   - `Dt_Atualizacao`: Data e hora da alteração.
   - `Login`: Login do usuário que fez a alteração.
   - `Hostname`: Nome do host do qual a alteração foi feita.
   - `Operacao`: Tipo de operação (INSERT, UPDATE, DELETE).
   - Campos correspondentes à tabela `Cliente`: `Id_Cliente`, `Nome`, `Data_Nascimento`, `Salario`.

3. **Criação da Trigger `trgHistorico_Cliente`**: Cria a trigger de auditoria associada à tabela `Cliente`. Esta trigger é acionada após qualquer operação de inserção (`INSERT`), atualização (`UPDATE`) ou exclusão (`DELETE`) realizada na tabela `Cliente`. Ela registra a operação na tabela de log `Cliente_Log` com os seguintes detalhes:
   - Se houver inserção, registra um histórico do tipo 'INSERT'.
   - Se houver atualização, registra um histórico do tipo 'UPDATE'.
   - Se houver exclusão, registra um histórico do tipo 'DELETE'.
   - As informações de `Login` e `Hostname` são capturadas para identificar o usuário e o local da alteração.

4. **Simulação de Alterações**: Após a criação da trigger, são realizadas algumas operações de exemplo na tabela `Cliente`:
   - Um `INSERT` de um novo cliente (`Bartolomeu`).
   - Um `UPDATE` no salário do cliente `Bartolomeu`.
   - Um `DELETE` do cliente `André`.
   - Outras atualizações para testar o funcionamento da trigger e registrar essas ações na tabela de log.

5. **Resultados Esperados**: A trigger registra todas as operações de alteração feitas na tabela `Cliente`, criando um histórico completo de ações na tabela `Cliente_Log`. O histórico inclui o tipo de operação (INSERT, UPDATE, DELETE), a data e hora da alteração, o login do usuário que fez a alteração e o nome do host.

### Considerações:
- **Auditoria em Tempo Real**: As alterações são registradas em tempo real, independentemente de qual rotina ou usuário esteja manipulando a tabela.
- **Visibilidade**: Tanto o DBA quanto o desenvolvedor têm acesso ao código-fonte da trigger e podem gerenciar a auditoria.
- **Impacto em Alterações em Massa**: Em caso de alterações em massa (como grandes inserções ou exclusões), a auditoria pode gerar um volume significativo de dados na tabela de log, o que pode afetar o desempenho do sistema. Isso pode ser contornado desativando temporariamente a trigger.

Esse processo de auditoria via trigger proporciona uma solução transparente, de fácil implementação e gerenciamento, permitindo que o histórico de dados seja mantido sem a necessidade de modificações no código da aplicação.

```sql
/*
Gerando histórico através de trigger no banco de dados:

- Uma vez desenvolvida, a implantação do recurso envolve apenas a criação de uma tabela e uma trigger no 
banco de dados

- Não importa qual rotina ou usuário esteja manipulando a tabela, todas as alterações sempre serão gravadas

- UPDATE, INSERT e DELETE feitos manualmente no banco de dados serão logados e auditados pela trigger, e será 
gerado histórico para isso

- Tanto o DBA quanto o Desenvolvedor tem visibilidade sobre a existência da rotina e seu código-fonte

- Se for necessário desativar a trigger temporariamente para alguma operação, isso pode ser feito em poucos 
segundos pelo DBA

- O gerenciamento da rotina de auditoria fica nas mãos do DBA

- Caso a tabela sofra uma grande alteração de dados manual, seja via INSERT, DELETE ou UPDATE, todas as 
alterações serão gravadas na tabela de histórico, o que pode gerar um volume de gravações na tabela de histórico 
muito grande e causar lentidão no ambiente. Isso pode ser contornado desativando a trigger enquanto essas 
alterações em massa são realizadas e ativando novamente ao término

- Caso a alteração seja realizada pelo sistema, e o sistema utilize um usuário fixo, a trigger irá gravar o 
usuário do sistema, e não o usuário da pessoa que realizou a alteração



Gerando histórico através do sistema:

- A implementação envolve realizar alterações no código-fonte de todos os trechos de código da aplicação e 
telas que manipulam dados na tabela envolvida (além de arquivos dependentes), onde geralmente existem janelas 
rígidas para qualquer modificação em sistema

- Apenas as telas que foram alteradas para gravar histórico efetivamente o farão

- UPDATE, INSERT e DELETE feitos manualmente no banco de dados NÃO serão logados e não haverá histórico para 
essas alterações

- Apenas o desenvolvedor sabe que esse recurso existe e como ele funciona. O DBA geralmente não tem acesso a 
esse tipo de informação e muito menos, o código-fonte para entender como esse histórico está sendo gerado

- Se for necessário desativar esse recurso temporariamente, o desenvolvedor terá que alterar no código-fonte 
da aplicação e fazer o deploy em produção, consumindo bastante tempo de duas equipes e com possibilidade de 
desconectar sessões ativas no servidor de aplicação

- O gerenciamento da rotina de auditoria fica nas mãos do Desenvolvedor

- Caso a tabela sofra uma grande alteração de dados manual, seja via INSERT, DELETE ou UPDATE, o ambiente não 
será afetado, pois alterações manuais no banco não serão gravadas

- Caso a alteração seja realizada pelo sistema, é possível identificar o usuário logado na aplicação e gravar 
o login ou até mesmo realizar queries no banco e retornar um Id_Usuario da tabela Usuarios, por exemplo, para 
gravar na tabela de histórico

- Como vocês observaram nos itens citados acima, existem vantagens e desvantagens em cada uma das abordagens. 
Sendo assim, você deverá decidir qual se encaixa melhor ao seu negócio e à sua infraestrutura.

*/
```

```sql
IF (OBJECT_ID('db.dbo.Cliente') IS NOT NULL) DROP TABLE db.dbo.Cliente
CREATE TABLE db.dbo.Cliente (
    Id_Cliente INT IDENTITY(1, 1),
    Nome VARCHAR(100),
    Data_Nascimento DATETIME,
    Salario FLOAT
)
GO

INSERT INTO db.dbo.Cliente
VALUES 
    ('João', '1981-05-14', 4521),
    ('Marcos', '1975-01-07', 1478.58),
    ('André', '1962-11-11', 7151.45),
    ('Simão', '1991-12-18', 2584.97),
    ('Pedro', '1986-11-20', 987.52),
    ('Paulo', '1974-08-04', 6259.14),
    ('José', '1979-09-01', 5272.13)
GO
```

```sql
-- Criando a tabela com a mesma estrutura da original, mas adicionando colunas de controle
IF (OBJECT_ID('db.dbo.Cliente_Log') IS NOT NULL) DROP TABLE db.dbo.Cliente_Log
CREATE TABLE db.dbo.Cliente_Log (
    Id INT IDENTITY(1, 1),
    Dt_Atualizacao DATETIME DEFAULT GETDATE(),
    [Login] VARCHAR(100),
    Hostname VARCHAR(100),
    Operacao VARCHAR(20),

    -- Dados da tabela original
    Id_Cliente INT,
    Nome VARCHAR(100),
    Data_Nascimento DATETIME,
    Salario FLOAT
)
GO
```

```sql
USE [db]
GO

-- Criando o processo de auditoria
IF ((SELECT COUNT(*) FROM sys.triggers WHERE name = 'trgHistorico_Cliente' AND parent_id = OBJECT_ID('db.dbo.Cliente')) > 0)
    DROP TRIGGER trgHistorico_Cliente
GO

CREATE TRIGGER trgHistorico_Cliente ON db.dbo.Cliente -- Tabela que a trigger será associada
AFTER INSERT, UPDATE, DELETE 
AS
BEGIN
    
    SET NOCOUNT ON

    DECLARE 
        @Login VARCHAR(100) = ORIGINAL_LOGIN(), 
        @HostName VARCHAR(100) = HOST_NAME(),
        @Data DATETIME = GETDATE()
        

    IF (EXISTS(SELECT * FROM Inserted) AND EXISTS (SELECT * FROM Deleted))
    BEGIN
        
        INSERT INTO db.dbo.Cliente_Log
        SELECT @Data, @Login, @HostName, 'UPDATE', *
        FROM Inserted

    END
    ELSE BEGIN

        IF (EXISTS(SELECT * FROM Inserted))
        BEGIN

            INSERT INTO db.dbo.Cliente_Log
            SELECT @Data, @Login, @HostName, 'INSERT', *
            FROM Inserted

        END
        ELSE BEGIN

            INSERT INTO db.dbo.Cliente_Log
            SELECT @Data, @Login, @HostName, 'DELETE', *
            FROM Deleted

        END

    END

END
GO
```

```sql
-- E agora vamos simular algumas alterações na base:
INSERT INTO db.dbo.Cliente
VALUES ('Bartolomeu', '1975-05-28', 6158.74)

WAITFOR DELAY '00:00:00.123'

UPDATE db.dbo.Cliente
SET Salario = Salario * 1.5
WHERE Nome = 'Bartolomeu'

WAITFOR DELAY '00:00:00.123'

DELETE FROM db.dbo.Cliente
WHERE Nome = 'André'

WAITFOR DELAY '00:00:00.123'

UPDATE db.dbo.Cliente
SET Salario = Salario * 1.1
WHERE Id_Cliente = 2

WAITFOR DELAY '00:00:00.123'

UPDATE db.dbo.Cliente
SET Salario = 10, Nome = 'Judas Iscariodes', Data_Nascimento = '06/06/2066'
WHERE Id_Cliente = 1

WAITFOR DELAY '00:00:00.123'
```

```sql
SELECT * FROM db.dbo.Cliente
SELECT * FROM db.dbo.Cliente_Log
```
