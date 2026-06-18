USE GathelDB;
GO

CREATE OR ALTER PROCEDURE spRegisterPerson
    @name VARCHAR(60),
    @lastName VARCHAR(60),
    @username VARCHAR(40),
    @email VARCHAR(100),
    @password VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (
            SELECT 1
            FROM people
            WHERE email = @email
              AND isDeleted = 0
        )
        BEGIN
            THROW 50010, 'Ya existe una cuenta con ese correo.', 1;
        END;

        IF EXISTS (
            SELECT 1
            FROM people
            WHERE username = @username
              AND isDeleted = 0
        )
        BEGIN
            THROW 50011, 'Ya existe una cuenta con ese nombre de usuario.', 1;
        END;

        DECLARE @peopleTypeId INT;

        SELECT TOP 1 @peopleTypeId = peopleTypeId
        FROM peopleTypes
        WHERE name IN ('Player', 'Jugador', 'Regular player')
          AND isDeleted = 0;

        IF @peopleTypeId IS NULL
        BEGIN
            INSERT INTO peopleTypes (
                name,
                description,
                createdAt,
                updatedAt,
                isDeleted
            )
            VALUES (
                'Player',
                'Jugador regular de Gathel',
                SYSDATETIME(),
                SYSDATETIME(),
                0
            );

            SET @peopleTypeId = SCOPE_IDENTITY();
        END;

        INSERT INTO people (
            peopleTypeId,
            name,
            lastName,
            identification,
            phone,
            email,
            passwordHash,
            username,
            biography,
            birthDate,
            addressId,
            isVerified,
            isActive,
            createdAt,
            updatedAt,
            isDeleted
        )
        VALUES (
            @peopleTypeId,
            @name,
            @lastName,
            CONCAT('REG-', @username),
            NULL,
            @email,
            CONVERT(VARBINARY(MAX), HASHBYTES('SHA2_256', CONVERT(NVARCHAR(200), @password))),
            @username,
            NULL,
            NULL,
            NULL,
            0,
            1,
            SYSDATETIME(),
            SYSDATETIME(),
            0
        );

        DECLARE @personId INT = SCOPE_IDENTITY();

        INSERT INTO wallets (
            personId,
            isBlocked,
            createdAt,
            updatedAt,
            isDeleted
        )
        VALUES (
            @personId,
            0,
            SYSDATETIME(),
            SYSDATETIME(),
            0
        );

        DECLARE @walletId INT = SCOPE_IDENTITY();

        INSERT INTO walletBalances (
            walletId,
            statusTypeId,
            oldPointsAmount,
            balancePointsAmount,
            newPointsAmount,
            calculatedAt,
            createdAt,
            updatedAt,
            isDeleted
        )
        VALUES (
            @walletId,
            NULL,
            0,
            100,
            100,
            SYSDATETIME(),
            SYSDATETIME(),
            SYSDATETIME(),
            0
        );

        COMMIT TRANSACTION;

        SELECT
            personId,
            name,
            lastName,
            username,
            email
        FROM people
        WHERE personId = @personId;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        THROW;
    END CATCH;
END;
GO