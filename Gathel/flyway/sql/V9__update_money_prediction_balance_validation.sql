USE GathelDB;
GO

CREATE OR ALTER PROCEDURE spCreateMoneyPrediction
    @propositionId INT,
    @personId INT,
    @predictionValue BIT,
    @moneyAmount DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @pendingStatusId INT;
        DECLARE @initialMoneyBalance DECIMAL(10,2) = 100.00;
        DECLARE @usedMoney DECIMAL(10,2);
        DECLARE @availableMoney DECIMAL(10,2);

        IF @moneyAmount IS NULL OR @moneyAmount <= 0
        BEGIN
            THROW 50300, 'El monto de dinero debe ser mayor a 0.', 1;
        END;

        IF NOT EXISTS (
            SELECT 1 FROM people
            WHERE personId = @personId
              AND isDeleted = 0
              AND isActive = 1
        )
        BEGIN
            THROW 50301, 'El usuario no existe o no está activo.', 1;
        END;

        IF NOT EXISTS (
            SELECT 1 FROM propositions
            WHERE propositionId = @propositionId
              AND isDeleted = 0
              AND endPredictionDateTime > SYSDATETIME()
        )
        BEGIN
            THROW 50302, 'La proposición no existe o ya cerró.', 1;
        END;

        IF EXISTS (
            SELECT 1 FROM predictions
            WHERE propositionId = @propositionId
              AND personId = @personId
              AND isDeleted = 0
        )
        BEGIN
            THROW 50303, 'Ya hiciste un pronóstico para esta proposición.', 1;
        END;

        IF EXISTS (
            SELECT 1
            FROM propositions
            WHERE propositionId = @propositionId
              AND isDeleted = 0
              AND (
                    creatorPersonId = @personId
                    OR targetPersonId = @personId
                  )
        )
        BEGIN
            THROW 50304, 'No podés pronosticar en una proposición que creaste o que es sobre vos.', 1;
        END;

        SELECT @usedMoney = ISNULL(SUM(moneyAmount), 0)
        FROM predictions
        WHERE personId = @personId
          AND isDeleted = 0
          AND moneyAmount IS NOT NULL;

        SET @availableMoney = @initialMoneyBalance - @usedMoney;

        IF @moneyAmount > @availableMoney
        BEGIN
            THROW 50305, 'No tenés dinero suficiente para hacer este pronóstico.', 1;
        END;

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
            NULL,
            @moneyAmount,
            NULL,
            NULL,
            SYSDATETIME(),
            0,
            @personId,
            SYSDATETIME(),
            SYSDATETIME(),
            0
        );

        COMMIT TRANSACTION;

        SELECT
            'Money prediction created successfully' AS message,
            @availableMoney - @moneyAmount AS availableMoney;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO