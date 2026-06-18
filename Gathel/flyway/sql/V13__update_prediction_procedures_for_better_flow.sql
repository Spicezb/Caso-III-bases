USE GathelDB;
GO

------------------------------------------------------------
-- 1. Predicción con puntos
------------------------------------------------------------

CREATE OR ALTER PROCEDURE spCreatePointPrediction
    @propositionId INT,
    @personId INT,
    @predictionValue BIT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @activeStatusName VARCHAR(40);
        DECLARE @predictionStatusId INT;
        DECLARE @creatorPersonId INT;
        DECLARE @targetPersonId INT;
        DECLARE @endPredictionDateTime DATETIME2(3);

        DECLARE @walletId INT;
        DECLARE @currentBalance NUMERIC(16,2);
        DECLARE @newBalance NUMERIC(16,2);

        DECLARE @pointsAmount NUMERIC(10,2) = 1;
        DECLARE @existingPredictionId INT;
        DECLARE @existingPredictionValue BIT;

        ------------------------------------------------------------
        -- Validar usuario
        ------------------------------------------------------------

        IF NOT EXISTS (
            SELECT 1
            FROM people
            WHERE personId = @personId
              AND isDeleted = 0
              AND isActive = 1
        )
        BEGIN
            THROW 52100, 'El usuario no existe o no está activo.', 1;
        END;

        ------------------------------------------------------------
        -- Validar proposición activa
        ------------------------------------------------------------

        SELECT
            @activeStatusName = st.name,
            @creatorPersonId = p.creatorPersonId,
            @targetPersonId = p.targetPersonId,
            @endPredictionDateTime = p.endPredictionDateTime
        FROM propositions p
        INNER JOIN statusTypes st
            ON st.statusTypeId = p.statusTypesId
        WHERE p.propositionId = @propositionId
          AND p.isDeleted = 0
          AND st.isDeleted = 0;

        IF @activeStatusName IS NULL
        BEGIN
            THROW 52101, 'La proposición no existe.', 1;
        END;

        IF @activeStatusName <> 'Active'
        BEGIN
            THROW 52102, 'Solo se puede apostar en proposiciones activas y aceptadas.', 1;
        END;

        IF @endPredictionDateTime <= SYSDATETIME()
        BEGIN
            THROW 52103, 'La etapa de predicciones ya cerró.', 1;
        END;

        ------------------------------------------------------------
        -- Reglas de quién no puede apostar
        ------------------------------------------------------------

        IF @personId = @creatorPersonId
        BEGIN
            THROW 52104, 'No podés apostar en una proposición que creaste.', 1;
        END;

        IF @personId = @targetPersonId
        BEGIN
            THROW 52105, 'No podés apostar en una proposición sobre vos mismo.', 1;
        END;

        ------------------------------------------------------------
        -- Estado para prediction
        ------------------------------------------------------------

        SELECT TOP 1 @predictionStatusId = statusTypeId
        FROM statusTypes
        WHERE name = 'Active'
          AND isDeleted = 0;

        IF @predictionStatusId IS NULL
        BEGIN
            THROW 52106, 'No existe el estado Active.', 1;
        END;

        ------------------------------------------------------------
        -- Validar wallet y balance
        ------------------------------------------------------------

        SELECT TOP 1 @walletId = walletId
        FROM wallets
        WHERE personId = @personId
          AND isDeleted = 0
          AND isBlocked = 0;

        IF @walletId IS NULL
        BEGIN
            THROW 52107, 'El usuario no tiene wallet activa.', 1;
        END;

        SELECT TOP 1 @currentBalance = balancePointsAmount
        FROM walletBalances
        WHERE walletId = @walletId
          AND isDeleted = 0
        ORDER BY calculatedAt DESC, walletBalanceId DESC;

        SET @currentBalance = ISNULL(@currentBalance, 0);

        IF @currentBalance < @pointsAmount
        BEGIN
            THROW 52108, 'No tenés puntos suficientes para hacer este pronóstico.', 1;
        END;

        ------------------------------------------------------------
        -- Ver si ya existe predicción del usuario en esta proposición
        ------------------------------------------------------------

        SELECT TOP 1
            @existingPredictionId = predictionId,
            @existingPredictionValue = predictionValue
        FROM predictions
        WHERE propositionId = @propositionId
          AND personId = @personId
          AND isDeleted = 0
        ORDER BY predictionDateTime ASC, predictionId ASC;

        IF @existingPredictionId IS NOT NULL
        BEGIN
            IF @existingPredictionValue <> @predictionValue
            BEGIN
                THROW 52109, 'No podés cambiar el sentido de tu pronóstico.', 1;
            END;

            IF EXISTS (
                SELECT 1
                FROM predictions
                WHERE predictionId = @existingPredictionId
                  AND ISNULL(pointsAmount, 0) >= 1
                  AND isDeleted = 0
            )
            BEGIN
                THROW 52110, 'Ya usaste el máximo de 1 punto para esta proposición.', 1;
            END;
        END;

        ------------------------------------------------------------
        -- Descontar punto
        ------------------------------------------------------------

        SET @newBalance = @currentBalance - @pointsAmount;

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
            @predictionStatusId,
            @currentBalance,
            @newBalance,
            @newBalance,
            SYSDATETIME(),
            @personId,
            SYSDATETIME(),
            SYSDATETIME(),
            0
        );

        ------------------------------------------------------------
        -- Insertar o actualizar predicción
        ------------------------------------------------------------

        IF @existingPredictionId IS NULL
        BEGIN
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
                @predictionStatusId,
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
        END;
        ELSE
        BEGIN
            UPDATE predictions
            SET pointsAmount = ISNULL(pointsAmount, 0) + @pointsAmount,
                updatedAt = SYSDATETIME(),
                auditPersonId = @personId
            WHERE predictionId = @existingPredictionId
              AND isDeleted = 0;
        END;

        COMMIT TRANSACTION;

        SELECT
            'Point prediction created successfully' AS message,
            @newBalance AS newPointsBalance;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

------------------------------------------------------------
-- 2. Predicción con dinero
------------------------------------------------------------

CREATE OR ALTER PROCEDURE spCreateMoneyPrediction
    @propositionId INT,
    @personId INT,
    @predictionValue BIT,
    @moneyAmount NUMERIC(14,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @activeStatusName VARCHAR(40);
        DECLARE @predictionStatusId INT;
        DECLARE @creatorPersonId INT;
        DECLARE @targetPersonId INT;
        DECLARE @endPredictionDateTime DATETIME2(3);

        DECLARE @existingPredictionId INT;
        DECLARE @existingPredictionValue BIT;

        DECLARE @initialMoneyBalance NUMERIC(14,2) = 100.00;
        DECLARE @usedMoney NUMERIC(14,2);
        DECLARE @availableMoney NUMERIC(14,2);

        ------------------------------------------------------------
        -- Validar monto
        ------------------------------------------------------------

        IF @moneyAmount IS NULL OR @moneyAmount <= 0
        BEGIN
            THROW 52200, 'El monto de dinero debe ser mayor a 0.', 1;
        END;

        ------------------------------------------------------------
        -- Validar usuario
        ------------------------------------------------------------

        IF NOT EXISTS (
            SELECT 1
            FROM people
            WHERE personId = @personId
              AND isDeleted = 0
              AND isActive = 1
        )
        BEGIN
            THROW 52201, 'El usuario no existe o no está activo.', 1;
        END;

        ------------------------------------------------------------
        -- Validar proposición activa
        ------------------------------------------------------------

        SELECT
            @activeStatusName = st.name,
            @creatorPersonId = p.creatorPersonId,
            @targetPersonId = p.targetPersonId,
            @endPredictionDateTime = p.endPredictionDateTime
        FROM propositions p
        INNER JOIN statusTypes st
            ON st.statusTypeId = p.statusTypesId
        WHERE p.propositionId = @propositionId
          AND p.isDeleted = 0
          AND st.isDeleted = 0;

        IF @activeStatusName IS NULL
        BEGIN
            THROW 52202, 'La proposición no existe.', 1;
        END;

        IF @activeStatusName <> 'Active'
        BEGIN
            THROW 52203, 'Solo se puede apostar en proposiciones activas y aceptadas.', 1;
        END;

        IF @endPredictionDateTime <= SYSDATETIME()
        BEGIN
            THROW 52204, 'La etapa de predicciones ya cerró.', 1;
        END;

        ------------------------------------------------------------
        -- Reglas de quién no puede apostar
        ------------------------------------------------------------

        IF @personId = @creatorPersonId
        BEGIN
            THROW 52205, 'No podés apostar en una proposición que creaste.', 1;
        END;

        IF @personId = @targetPersonId
        BEGIN
            THROW 52206, 'No podés apostar en una proposición sobre vos mismo.', 1;
        END;

        ------------------------------------------------------------
        -- Estado para prediction
        ------------------------------------------------------------

        SELECT TOP 1 @predictionStatusId = statusTypeId
        FROM statusTypes
        WHERE name = 'Active'
          AND isDeleted = 0;

        IF @predictionStatusId IS NULL
        BEGIN
            THROW 52207, 'No existe el estado Active.', 1;
        END;

        ------------------------------------------------------------
        -- Dinero demo disponible
        ------------------------------------------------------------

        SELECT @usedMoney = ISNULL(SUM(moneyAmount), 0)
        FROM predictions
        WHERE personId = @personId
          AND isDeleted = 0
          AND moneyAmount IS NOT NULL;

        SET @availableMoney = @initialMoneyBalance - ISNULL(@usedMoney, 0);

        IF @moneyAmount > @availableMoney
        BEGIN
            THROW 52208, 'No tenés dinero suficiente para aumentar este pronóstico.', 1;
        END;

        ------------------------------------------------------------
        -- Ver si ya existe predicción del usuario en esta proposición
        ------------------------------------------------------------

        SELECT TOP 1
            @existingPredictionId = predictionId,
            @existingPredictionValue = predictionValue
        FROM predictions
        WHERE propositionId = @propositionId
          AND personId = @personId
          AND isDeleted = 0
        ORDER BY predictionDateTime ASC, predictionId ASC;

        IF @existingPredictionId IS NOT NULL
        BEGIN
            IF @existingPredictionValue <> @predictionValue
            BEGIN
                THROW 52209, 'No podés cambiar el sentido de tu pronóstico.', 1;
            END;

            UPDATE predictions
            SET moneyAmount = ISNULL(moneyAmount, 0) + @moneyAmount,
                updatedAt = SYSDATETIME(),
                auditPersonId = @personId
            WHERE predictionId = @existingPredictionId
              AND isDeleted = 0;
        END;
        ELSE
        BEGIN
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
                @predictionStatusId,
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
        END;

        COMMIT TRANSACTION;

        SELECT
            'Money prediction created or increased successfully' AS message,
            @availableMoney - @moneyAmount AS availableMoney;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO