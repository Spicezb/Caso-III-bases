USE GathelDB;
GO


CREATE OR ALTER PROCEDURE spCreateProposition
    @creatorPersonId INT,
    @targetPersonId INT,
    @targetSocialAccountId INT = NULL,
    @title VARCHAR(150),
    @description VARCHAR(MAX) = NULL,
    @startPredictionDateTime DATETIME = NULL,
    @endPredictionDateTime DATETIME = NULL,
    @minimumEntryPointsAmount DECIMAL(10, 2) = NULL,
    @winningProfitPercentage DECIMAL(10, 2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @votingStatusId INT;
        DECLARE @votingStart DATETIME2(3) = SYSDATETIME();
        DECLARE @votingEnd DATETIME2(3) = DATEADD(HOUR, 24, SYSDATETIME());

        ------------------------------------------------------------
        -- 1. Validar creador
        ------------------------------------------------------------

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

        ------------------------------------------------------------
        -- 2. Validar usuario objetivo
        ------------------------------------------------------------

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

        ------------------------------------------------------------
        -- 3. Validar datos básicos
        ------------------------------------------------------------

        IF @title IS NULL OR LTRIM(RTRIM(@title)) = ''
        BEGIN
            THROW 50102, 'El título de la proposición es obligatorio.', 1;
        END;

        ------------------------------------------------------------
        -- 4. Obtener o crear estado Voting
        ------------------------------------------------------------

        SELECT TOP 1 @votingStatusId = statusTypeId
        FROM statusTypes
        WHERE name = 'Voting'
          AND isDeleted = 0;

        IF @votingStatusId IS NULL
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
                'Voting',
                'Proposición en etapa de votación de interés por 24 horas',
                @creatorPersonId,
                SYSDATETIME(),
                SYSDATETIME(),
                0
            );

            SET @votingStatusId = SCOPE_IDENTITY();
        END;

        ------------------------------------------------------------
        -- 5. Insertar proposición como Voting, NO como Active
        --
        -- startPredictionDateTime y endPredictionDateTime se usan
        -- temporalmente para representar la ventana de votación.
        -- Cuando el usuario objetivo acepte, esos campos se actualizan
        -- con la ventana real de predicciones.
        ------------------------------------------------------------

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
            @votingStatusId,
            @creatorPersonId,
            @targetPersonId,
            @targetSocialAccountId,
            @title,
            @description,
            @votingStart,
            @votingEnd,
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
            'Proposition created as candidate for voting' AS message,
            @propositionId AS propositionId,
            @votingStart AS votingStartDateTime,
            @votingEnd AS votingEndDateTime;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO