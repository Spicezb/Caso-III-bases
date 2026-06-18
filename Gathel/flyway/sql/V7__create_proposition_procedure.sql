USE GathelDB;
GO

CREATE OR ALTER PROCEDURE spCreateProposition
    @creatorPersonId INT,
    @targetPersonId INT,
    @targetSocialAccountId INT = NULL,
    @title VARCHAR(150),
    @description VARCHAR(MAX) = NULL,
    @startPredictionDateTime DATETIME,
    @endPredictionDateTime DATETIME,
    @minimumEntryPointsAmount DECIMAL(10, 2) = NULL,
    @winningProfitPercentage DECIMAL(10, 2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1
            FROM people
            WHERE personId = @creatorPersonId
              AND isDeleted = 0
              AND isActive = 1
        )
        BEGIN
            THROW 50100, 'El creador de la proposición no existe o no está activo.', 1;
        END;

        IF NOT EXISTS (
            SELECT 1
            FROM people
            WHERE personId = @targetPersonId
              AND isDeleted = 0
              AND isActive = 1
        )
        BEGIN
            THROW 50101, 'La persona objetivo no existe o no está activa.', 1;
        END;

        DECLARE @activeStatusId INT;

        SELECT TOP 1 @activeStatusId = statusTypeId
        FROM statusTypes
        WHERE name IN ('Active', 'Activa', 'Abierta', 'ACTIVE')
          AND isDeleted = 0;

        IF @activeStatusId IS NULL
        BEGIN
            INSERT INTO statusTypes (
                name,
                description,
                auditPersonId,
                createdAt,
                updatedAt,
                isDeleted
            )
            VALUES (
                'Active',
                'Estado activo para proposiciones',
                @creatorPersonId,
                SYSDATETIME(),
                SYSDATETIME(),
                0
            );

            SET @activeStatusId = SCOPE_IDENTITY();
        END;

        INSERT INTO propositions (
            parentproposition,
            statusTypesId,
            creatorPersonId,
            targetPersonId,
            targetSocialAccountId,
            title,
            description,
            startPredictionDateTime,
            endPredictionDateTime,
            winningOption,
            minimumEntryPointsAmount,
            winningProfitPercentage,
            isPublic,
            auditPersonId,
            createdAt,
            updatedAt,
            isDeleted
        )
        VALUES (
            NULL,
            @activeStatusId,
            @creatorPersonId,
            @targetPersonId,
            @targetSocialAccountId,
            @title,
            @description,
            @startPredictionDateTime,
            @endPredictionDateTime,
            NULL,
            ISNULL(@minimumEntryPointsAmount, 1),
            ISNULL(@winningProfitPercentage, 10),
            1,
            @creatorPersonId,
            SYSDATETIME(),
            SYSDATETIME(),
            0
        );

        DECLARE @propositionId INT = SCOPE_IDENTITY();

        COMMIT TRANSACTION;

        SELECT
            @propositionId AS propositionId;
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