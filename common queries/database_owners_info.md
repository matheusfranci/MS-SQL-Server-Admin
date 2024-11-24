# Consulta para Obter Informações sobre Bancos de Dados e seus Criadores

## Descrição da Consulta

Esta consulta retorna informações sobre todos os bancos de dados presentes no servidor SQL Server, incluindo o nome do banco de dados e o proprietário (criador) do banco. O proprietário é identificado pelo SID (Security Identifier) armazenado no sistema, sendo convertido para o nome do usuário com a função `suser_sname`.

### Detalhes:
1. **Fontes de Dados:**
   - `sys.databases`: Esta visão de catálogo contém informações sobre todos os bancos de dados no servidor SQL, incluindo propriedades como nome, estado, e o proprietário do banco.
   
2. **Colunas Retornadas:**
   - **Database**: O nome do banco de dados.
   - **Creator**: O nome do usuário que criou o banco de dados, obtido a partir do SID do proprietário através da função `suser_sname`.

### Finalidade:
Essa consulta é útil para auditorias e verificações de segurança, permitindo identificar quem é o criador de cada banco de dados no servidor, o que pode ajudar em processos de gerenciamento e controle de acesso.

```SQL
SELECT name AS 'Database', suser_sname(owner_sid) AS 'Creator' FROM sys.databases;
```