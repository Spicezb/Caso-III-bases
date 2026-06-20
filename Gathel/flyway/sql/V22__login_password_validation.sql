USE GathelDB;
GO

CREATE OR ALTER PROCEDURE dbo.spLoginPerson
    @identifier NVARCHAR(255),
    @password NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF @identifier IS NULL OR LTRIM(RTRIM(@identifier)) = ''
    BEGIN
        THROW 51301, 'Debe ingresar correo o nombre de usuario.', 1;
    END;

    IF @password IS NULL OR LTRIM(RTRIM(@password)) = ''
    BEGIN
        THROW 51302, 'Debe ingresar la contraseña.', 1;
    END;

    SELECT TOP 1
        p.personId,
        p.name,
        p.lastName,
        p.username,
        p.email,
        p.isVerified,
        p.isActive
    FROM dbo.people p
    WHERE p.isDeleted = 0
      AND p.isActive = 1
      AND (
            p.email = @identifier
            OR p.username = @identifier
          )
      AND p.passwordHash = HASHBYTES('SHA2_256', CONVERT(VARCHAR(255), @password));
END;
GO