# Este conjunto de triggers impede a execução de operações específicas no SQL Server, como a criação de usuários, concessão ou revogação de privilégios, e exclusão ou criação de bancos de dados.

## Triggers

1. **TRG_Prevent_Create_User**: Impede a criação de logins de usuário no servidor. Quando uma tentativa de criar um usuário é feita, o comando é revertido e uma mensagem de erro é gerada.
   
2. **TRG_Prevent_Grant_Or_Revoke_Privileges**: Bloqueia a concessão ou revogação de privilégios de acesso a usuários, tanto a nível de servidor quanto de banco de dados.

3. **TRG_PreventDropDB** (duplicado no exemplo): Evita a exclusão de bancos de dados no servidor.

4. **TRG_PreventCreateDB**: Impede a criação de novos bancos de dados no servidor.

## Benefícios
- **Segurança**: Protege o ambiente de alterações não autorizadas, mantendo a integridade dos dados e acessos.
- **Controle**: Garante que apenas usuários com permissões apropriadas possam realizar essas operações críticas.

## Observações
- Essas triggers devem ser utilizadas com cautela, pois bloqueiam operações importantes que podem ser necessárias em situações de administração.
- Apenas administradores com permissões específicas podem remover ou modificar essas triggers.

CREATE TRIGGER TRG_Prevent_Create_User ON ALL SERVER
FOR CREATE_LOGIN
AS
BEGIN
    RAISERROR('Você não pode criar um usuário.', 16,1);
    ROLLBACK;
END
GO


CREATE TRIGGER TRG_Prevent_Grant_Or_Revoke_Privileges
ON ALL SERVER
FOR DDL_SERVER_SECURITY_EVENTS, DDL_DATABASE_SECURITY_EVENTS
AS
BEGIN
    RAISERROR('Você não pode conceder acesso a um usuário', 16,1);
    ROLLBACK;
END
GO

CREATE TRIGGER [TRG_PreventDropDB] ON ALL SERVER
FOR DROP_DATABASE
AS
BEGIN
    RAISERROR('Você não pode dropar um banco', 16,1);
    ROLLBACK;
END
GO


CREATE TRIGGER [TRG_PreventDropDB] ON ALL SERVER
FOR CREATE_DATABASE
AS
BEGIN
    RAISERROR('Você não pode criar um banco de dados.', 16,1);
    ROLLBACK;
END
GO
