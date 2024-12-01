# Procedimento para Corrigir Usuários Órfãos

Este script é utilizado para corrigir usuários órfãos no SQL Server, remapeando-os para seus logins correspondentes. Usuários órfãos são aqueles cujo `SID` (Identificador de Segurança) não está associado a nenhum login no sistema, frequentemente ocorrendo após a restauração de um banco de dados ou movimentação de um usuário entre servidores.

## Etapas:

1. **Declarar Variáveis**:
    - A variável `@username` é declarada para armazenar o nome de usuário de cada usuário órfão.

2. **Declarar Cursor**:
    - O cursor `fixusers` é declarado para selecionar todos os usuários do SQL Server que possuem um `SID` e não possuem um login correspondente (`suser_sname(sid) IS NULL`).

3. **Buscar Usuários**:
    - O cursor itera por todos os usuários órfãos selecionados.

4. **Corrigir Usuários Órfãos**:
    - O procedimento armazenado do sistema `sp_change_users_login` é utilizado para remapear o usuário órfão para seu login correspondente, usando a opção `update_one`.

5. **Fechar e Desalocar o Cursor**:
    - Após processar todos os usuários, o cursor é fechado e desalocado.

## Uso:
- Este script é normalmente executado após a restauração de um banco de dados para reverter os usuários órfãos aos seus logins correspondentes, garantindo o controle de acesso adequado.

```sql
USE DB_NAME
BEGIN 

DECLARE @username varchar(25) 

DECLARE fixusers CURSOR 
FOR 

SELECT UserName = name FROM sysusers 
WHERE issqluser = 1 and (sid is not null and sid <> 0x0) 
and suser_sname(sid) is null 
ORDER BY name 

OPEN fixusers 

FETCH NEXT FROM fixusers 
INTO @username 

WHILE @@FETCH_STATUS = 0 
BEGIN 
EXEC sp_change_users_login 'update_one', @username, @username 
FETCH NEXT FROM fixusers 
INTO @username 
END 


CLOSE fixusers 

DEALLOCATE fixusers 

END 

go
```