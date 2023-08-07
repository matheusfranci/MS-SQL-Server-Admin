CREATE TRIGGER TRG_Orion_Prevent_Create_User ON ALL SERVER
FOR CREATE_LOGIN
AS
BEGIN
    RAISERROR('Você não pode criar um usuário.', 16,1);
    ROLLBACK;
END
GO


CREATE TRIGGER TRG_Orion_Prevent_Grant_Or_Revoke_Privileges
ON ALL SERVER
FOR DDL_SERVER_SECURITY_EVENTS, DDL_DATABASE_SECURITY_EVENTS
AS
BEGIN
    RAISERROR('Você não pode conceder acesso a um usuário', 16,1);
    ROLLBACK;
END
GO

CREATE TRIGGER [TRG_Orion_PreventDropDB] ON ALL SERVER
FOR DROP_DATABASE
AS
BEGIN
    RAISERROR('Você não pode dropar um banco', 16,1);
    ROLLBACK;
END
GO


CREATE TRIGGER [TRG_Orion_PreventDropDB] ON ALL SERVER
FOR DROP_DATABASE
AS
BEGIN
    RAISERROR('Você não pode criar um banco de dados.', 16,1);
    ROLLBACK;
END
GO
