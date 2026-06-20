USE GathelDB;
GO

CREATE OR ALTER PROCEDURE spCreatePointPrediction
    @propositionId INT,
    @personId INT,
    @predictionValue BIT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @pointsAmount DECIMAL(10,2) = 1;
        DECLARE @walletId INT;
        DECLARE @currentBalance DECIMAL(10,2);
        DECLARE @newBalance DECIMAL(10,2);
        DECLARE @pendingStatusId INT;

        IF NOT EXISTS (
            SELECT 1
            FROM people
            WHERE personId = @personId
              AND isDeleted = 0
              AND isActive = 1
        )
        BEGIN
            THROW 50200, 'El usuario no existe o no está activo.', 1;
        END;

        IF NOT EXISTS (
            SELECT 1
            FROM propositions
            WHERE propositionId = @propositionId
              AND isDeleted = 0
              AND endPredictionDateTime > SYSDATETIME()
        )
        BEGIN
            THROW 50201, 'La proposición no existe o ya cerró.', 1;
        END;

        IF EXISTS (
            SELECT 1
            FROM predictions
            WHERE propositionId = @propositionId
              AND personId = @personId
              AND isDeleted = 0
        )
        BEGIN
            THROW 50202, 'Ya hiciste un pronóstico para esta proposición.', 1;
        END;

        SELECT TOP 1 @walletId = walletId
        FROM wallets
        WHERE personId = @personId
          AND isDeleted = 0
          AND isBlocked = 0;

        IF @walletId IS NULL
        BEGIN
            THROW 50203, 'El usuario no tiene wallet activa.', 1;
        END;

        SELECT TOP 1
            @currentBalance = COALESCE(newPointsAmount, balancePointsAmount, 0)
        FROM walletBalances
        WHERE walletId = @walletId
          AND isDeleted = 0
        ORDER BY calculatedAt DESC, walletBalanceId DESC;

        SET @currentBalance = ISNULL(@currentBalance, 0);

        IF @currentBalance < @pointsAmount
        BEGIN
            THROW 50204, 'No tenés puntos suficientes para hacer este pronóstico.', 1;
        END;

        SET @newBalance = @currentBalance - @pointsAmount;

        SELECT TOP 1 @pendingStatusId = statusTypeId
        FROM statusTypes
        WHERE name IN ('Pending', 'Pendiente', 'PENDING')
          AND isDeleted = 0;

        IF @pendingStatusId IS NULL
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
                'Pending',
                'Estado pendiente para predicciones',
                @personId,
                SYSDATETIME(),
                SYSDATETIME(),
                0
            );

            SET @pendingStatusId = SCOPE_IDENTITY();
        END;

        INSERT INTO predictions (
            statusTypesId,
            propositionId,
            personId,
            predictionValue,
            pointsAmount,
            moneyAmount,
            currencyId,
            exchangeRateId,
            predictionDateTime,
            isWinner,
            auditPersonId,
            createdAt,
            updatedAt,
            isDeleted
        )
        VALUES (
            @pendingStatusId,
            @propositionId,
            @personId,
            @predictionValue,
            @pointsAmount,
            NULL,
            NULL,
            NULL,
            SYSDATETIME(),
            0,
            @personId,
            SYSDATETIME(),
            SYSDATETIME(),
            0
        );

        INSERT INTO walletBalances (
            walletId,
            statusTypeId,
            oldPointsAmount,
            balancePointsAmount,
            newPointsAmount,
            calculatedAt,
            auditPersonId,
            createdAt,
            updatedAt,
            isDeleted
        )
        VALUES (
            @walletId,
            @pendingStatusId,
            @currentBalance,
            @newBalance,
            @newBalance,
            SYSDATETIME(),
            @personId,
            SYSDATETIME(),
            SYSDATETIME(),
            0
        );

        COMMIT TRANSACTION;

        SELECT
            'Prediction created successfully' AS message,
            @newBalance AS newPointsBalance;
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