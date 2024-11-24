
markdown
Copiar código
# Descrição da Consulta para Verificar Membros de Funções em Bancos de Dados

## Descrição da Consulta

Esta consulta tem como objetivo identificar os membros de funções específicas nos bancos de dados de um servidor SQL, particularmente o usuário `POLIEDRO\VICTOR.LOIOLA`. O processo é feito da seguinte forma:

1. **Criação de Tabela Temporária:**
   - A tabela temporária `#tmpresult` é criada para armazenar os resultados da consulta. Ela contém as seguintes colunas:
     - **role_principal_name**: Nome da função de banco de dados (role).
     - **member_principal_name**: Nome do membro da função.
     - **Banco**: Nome do banco de dados.
     - **Servidor**: Nome do servidor onde o banco de dados está localizado.

2. **Execução de `sp_MSforeachdb`:**
   - A consulta usa o comando `sp_MSforeachdb` para iterar por todos os bancos de dados do servidor. Para cada banco de dados:
     - **Verificação de Membro**: A consulta seleciona as funções (roles) e membros (users) onde o membro do banco de dados é o usuário `POLIEDRO\VICTOR.LOIOLA`.
     - **Informações Obtidas**: Para cada banco de dados, são obtidos o nome da função (`role_principal_name`), o nome do membro da função (`member_principal_name`), o nome do banco de dados (`Banco`), e o nome do servidor (`Servidor`).

3. **Resultado Final:**
   - A consulta exibe os resultados, que incluem os bancos de dados e as funções em que o usuário `POLIEDRO\VICTOR.LOIOLA` é membro, juntamente com o nome do servidor.

4. **Limpeza:**
   - Após a exibição dos resultados, a tabela temporária `#tmpresult` é excluída para liberar recursos.

```SQL
CREATE TABLE #tmpresult
(
role_principal_name VARCHAR(MAX),
member_principal_name VARCHAR(MAX),
Banco VARCHAR(MAX),
Servidor VARCHAR(MAX)
)
INSERT INTO #tmpresult
EXEC master.sys.sp_MSforeachdb 
'USE [?]
SELECT r.name role_principal_name, m.name AS member_principal_name, DB_NAME() AS Banco, @@servername AS Servidor
FROM sys.database_role_members rm 
JOIN sys.database_principals r 
    ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m 
    ON rm.member_principal_id = m.principal_id
where m.name IN ("POLIEDRO\VICTOR.LOIOLA")
order by m.name;'
SELECT * FROM #tmpresult
DROP TABLE #tmpresult
```