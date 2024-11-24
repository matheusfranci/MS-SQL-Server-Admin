### Descrição da Query

Esta query gera uma string de conexão para o SQL Server, baseada no tipo de autenticação do usuário. Se o login for do tipo `WINDOWS_LOGIN`, será gerada uma string de conexão que utiliza autenticação do Windows. Caso contrário, a string usará autenticação do SQL Server, incluindo o nome do usuário e senha (que deve ser substituída pelo valor real).

- **`@@servername`**: Retorna o nome do servidor SQL.
- **`db_name()`**: Retorna o nome do banco de dados atual.
- **`suser_name()`**: Retorna o nome de usuário do SQL Server.
- **`type_desc`**: Descrição do tipo de autenticação (se for `WINDOWS_LOGIN`, utiliza a autenticação do Windows, caso contrário, autenticação do SQL Server com o nome de usuário e senha).

### Sugestão de Nome para o Arquivo

- **`gerar_string_conexao_sql_server.sql`**
- **`conexao_sql_server_usuario_atual.sql`**

```SQL
select
    'data source=' + @@servername +
    ';initial catalog=' + db_name() +
    case type_desc
        when 'WINDOWS_LOGIN' 
            then ';trusted_connection=true'
        else
            ';user id=' + suser_name() + ';password=<<YourPassword>>'
    end
    as ConnectionString
from sys.server_principals
where name = suser_name()
```
