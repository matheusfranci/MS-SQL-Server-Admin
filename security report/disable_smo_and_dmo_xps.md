## Descrição do Script

Este script configura o SQL Server para desabilitar o uso do SQL-DMO (SQL Distributed Management Objects) e SMO (SQL Server Management Objects), que são tecnologias de gerenciamento distribuído e gerenciamento de objetos do SQL Server.

### 1. **Habilitando as Opções Avançadas**
   - O script começa habilitando as opções avançadas com o comando `sp_configure 'advanced options', 1`, seguido pelo comando `RECONFIGURE` para aplicar a configuração.

### 2. **Verificando a Configuração de SMO e DMO**
   - A consulta `SELECT * FROM sys.configurations WHERE name = 'SMO and DMO XPs'` é usada para verificar o valor atual da configuração de `SMO and DMO XPs`.

### 3. **Desabilitando o Uso de SMO e DMO**
   - O script desabilita a configuração `SMO and DMO XPs` definindo o valor como 0, o que impede o uso de SQL-DMO e SMO para gerenciar o SQL Server. Em seguida, o comando `RECONFIGURE` aplica essa alteração.

## Sugestão de Nome

```SQL
sp_configure 'advanced options', 1
RECONFIGURE
```

```SQL
SELECT * FROM sys.configurations WHERE name = 'SMO and DMO XPs'
```

```SQL
sp_configure 'SMO and DMO XPs', 0 -- SQL-DMO (SQL Distributed Management Objects) / SMO (SQL Server Management Objects)
GO

RECONFIGURE
GO
```