USE GathelDB;
GO

/* ============================================================
   V11 - Gathel candidate voting procedures
   Usa tablas existentes:
   - propositions
   - propositionVotes
   - people
   - wallets
   - walletBalances
   - statusTypes
   ============================================================ */

------------------------------------------------------------
-- 1. Votar por una proposición candidata
------------------------------------------------------------

CREATE OR ALTER PROCEDURE spVoteForCandidateProposition
    @propositionId INT,
    @personId INT,
    @voteValue BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @statusName VARCHAR(40);
        DECLARE @targetPersonId INT;
        DECLARE @creatorPersonId INT;

        IF NOT EXISTS (
            SELECT 1
            FROM people
            WHERE personId = @personId
              AND isDeleted = 0
              AND isActive = 1
        )
        BEGIN
            THROW 51100, 'El usuario no existe o no está activo.', 1;
        END;

        SELECT
            @statusName = st.name,
            @targetPersonId = p.targetPersonId,
            @creatorPersonId = p.creatorPersonId
        FROM propositions p
        INNER JOIN statusTypes st
            ON st.statusTypeId = p.statusTypesId
        WHERE p.propositionId = @propositionId
          AND p.isDeleted = 0
          AND st.isDeleted = 0;

        IF @statusName IS NULL
        BEGIN
            THROW 51101, 'La proposición no existe.', 1;
        END;

        IF @statusName NOT IN ('Candidate', 'Voting')
        BEGIN
            THROW 51102, 'Solo se puede votar por proposiciones candidatas o en votación.', 1;
        END;

        IF @personId = @targetPersonId
        BEGIN
            THROW 51103, 'El usuario objetivo no debe votar por proposiciones sobre sí mismo.', 1;
        END;

        IF EXISTS (
            SELECT 1
            FROM propositionVotes
            WHERE propositionId = @propositionId
              AND personId = @personId
              AND isDeleted = 0
        )
        BEGIN
            UPDATE propositionVotes
            SET voteValue = @voteValue,
                votedAt = SYSDATETIME(),
                updatedAt = SYSDATETIME(),
                auditPersonId = @personId
            WHERE propositionId = @propositionId
              AND personId = @personId
              AND isDeleted = 0;
        END;
        ELSE
        BEGIN
            INSERT INTO propositionVotes (
                propositionId,
                personId,
                voteValue,
                votedAt,
                auditPersonId,
                createdAt,
                updatedAt,
                isDeleted
            )
            VALUES (
                @propositionId,
                @personId,
                @voteValue,
                SYSDATETIME(),
                @personId,
                SYSDATETIME(),
                SYSDATETIME(),
                0
            );
        END;

        COMMIT TRANSACTION;

        SELECT 'Vote registered successfully' AS message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

------------------------------------------------------------
-- 2. Seleccionar proposición ganadora después de 24 horas
--    Grupo: mismas proposiciones relacionadas por targetPersonId
--    y creadas dentro de una ventana de 24 horas desde la primera.
------------------------------------------------------------

CREATE OR ALTER PROCEDURE spSelectWinningPropositionAfterVoting
    @targetPersonId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @pendingApprovalStatusId INT;
        DECLARE @closedStatusId INT;
        DECLARE @firstCreatedAt DATETIME2(3);
        DECLARE @winnerPropositionId INT;

        SELECT TOP 1 @pendingApprovalStatusId = statusTypeId
        FROM statusTypes
        WHERE name = 'PendingApproval'
          AND isDeleted = 0;

        SELECT TOP 1 @closedStatusId = statusTypeId
        FROM statusTypes
        WHERE name = 'Closed'
          AND isDeleted = 0;

        IF @pendingApprovalStatusId IS NULL
        BEGIN
            THROW 51200, 'No existe el estado PendingApproval.', 1;
        END;

        IF @closedStatusId IS NULL
        BEGIN
            THROW 51201, 'No existe el estado Closed.', 1;
        END;

        SELECT TOP 1 @firstCreatedAt = p.createdAt
        FROM propositions p
        INNER JOIN statusTypes st
            ON st.statusTypeId = p.statusTypesId
        WHERE p.targetPersonId = @targetPersonId
          AND p.isDeleted = 0
          AND st.name IN ('Candidate', 'Voting')
          AND st.isDeleted = 0
        ORDER BY p.createdAt ASC;

        IF @firstCreatedAt IS NULL
        BEGIN
            THROW 51202, 'No hay proposiciones candidatas para este usuario.', 1;
        END;

        IF DATEADD(HOUR, 24, @firstCreatedAt) > SYSDATETIME()
        BEGIN
            THROW 51203, 'Aún no han pasado 24 horas desde la primera proposición candidata.', 1;
        END;

        SELECT TOP 1
            @winnerPropositionId = p.propositionId
        FROM propositions p
        INNER JOIN statusTypes st
            ON st.statusTypeId = p.statusTypesId
        LEFT JOIN propositionVotes pv
            ON pv.propositionId = p.propositionId
            AND pv.isDeleted = 0
            AND pv.voteValue = 1
        WHERE p.targetPersonId = @targetPersonId
          AND p.isDeleted = 0
          AND st.name IN ('Candidate', 'Voting')
          AND st.isDeleted = 0
          AND p.createdAt >= @firstCreatedAt
          AND p.createdAt < DATEADD(HOUR, 24, @firstCreatedAt)
        GROUP BY
            p.propositionId,
            p.createdAt
        ORDER BY
            COUNT(pv.propositionVoteId) DESC,
            p.createdAt ASC;

        IF @winnerPropositionId IS NULL
        BEGIN
            THROW 51204, 'No se pudo seleccionar una proposición ganadora.', 1;
        END;

        UPDATE propositions
        SET statusTypesId = @pendingApprovalStatusId,
            updatedAt = SYSDATETIME(),
            auditPersonId = @targetPersonId
        WHERE propositionId = @winnerPropositionId
          AND isDeleted = 0;

        UPDATE p
        SET statusTypesId = @closedStatusId,
            updatedAt = SYSDATETIME(),
            auditPersonId = @targetPersonId
        FROM propositions p
        INNER JOIN statusTypes st
            ON st.statusTypeId = p.statusTypesId
        WHERE p.targetPersonId = @targetPersonId
          AND p.propositionId <> @winnerPropositionId
          AND p.isDeleted = 0
          AND st.name IN ('Candidate', 'Voting')
          AND p.createdAt >= @firstCreatedAt
          AND p.createdAt < DATEADD(HOUR, 24, @firstCreatedAt);

        COMMIT TRANSACTION;

        SELECT
            'Winning proposition selected successfully' AS message,
            @winnerPropositionId AS winnerPropositionId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

------------------------------------------------------------
-- 3. Aceptar proposición ganadora
--    El usuario objetivo define la ventana de predicciones.
------------------------------------------------------------

CREATE OR ALTER PROCEDURE spAcceptWinningProposition
    @propositionId INT,
    @targetPersonId INT,
    @startPredictionDateTime DATETIME2(3),
    @endPredictionDateTime DATETIME2(3)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @activeStatusId INT;
        DECLARE @currentStatusName VARCHAR(40);

        IF @endPredictionDateTime <= @startPredictionDateTime
        BEGIN
            THROW 51300, 'La fecha de cierre debe ser posterior a la fecha de inicio.', 1;
        END;

        SELECT TOP 1 @activeStatusId = statusTypeId
        FROM statusTypes
        WHERE name = 'Active'
          AND isDeleted = 0;

        IF @activeStatusId IS NULL
        BEGIN
            THROW 51301, 'No existe el estado Active.', 1;
        END;

        SELECT @currentStatusName = st.name
        FROM propositions p
        INNER JOIN statusTypes st
            ON st.statusTypeId = p.statusTypesId
        WHERE p.propositionId = @propositionId
          AND p.targetPersonId = @targetPersonId
          AND p.isDeleted = 0
          AND st.isDeleted = 0;

        IF @currentStatusName IS NULL
        BEGIN
            THROW 51302, 'La proposición no existe o no pertenece al usuario objetivo.', 1;
        END;

        IF @currentStatusName <> 'PendingApproval'
        BEGIN
            THROW 51303, 'Solo se puede aceptar una proposición pendiente de aprobación.', 1;
        END;

        UPDATE propositions
        SET statusTypesId = @activeStatusId,
            startPredictionDateTime = @startPredictionDateTime,
            endPredictionDateTime = @endPredictionDateTime,
            updatedAt = SYSDATETIME(),
            auditPersonId = @targetPersonId
        WHERE propositionId = @propositionId
          AND targetPersonId = @targetPersonId
          AND isDeleted = 0;

        COMMIT TRANSACTION;

        SELECT 'Proposition accepted and activated successfully' AS message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

------------------------------------------------------------
-- 4. Rechazar proposición ganadora
--    Si rechaza, pierde 1 punto.
------------------------------------------------------------

CREATE OR ALTER PROCEDURE spRejectWinningProposition
    @propositionId INT,
    @targetPersonId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @rejectedStatusId INT;
        DECLARE @penaltyStatusId INT;
        DECLARE @currentStatusName VARCHAR(40);
        DECLARE @walletId INT;
        DECLARE @currentBalance NUMERIC(16,2);
        DECLARE @newBalance NUMERIC(16,2);
        DECLARE @penaltyPoints NUMERIC(16,2) = 1;

        SELECT TOP 1 @rejectedStatusId = statusTypeId
        FROM statusTypes
        WHERE name = 'Rejected'
          AND isDeleted = 0;

        IF @rejectedStatusId IS NULL
        BEGIN
            THROW 51400, 'No existe el estado Rejected.', 1;
        END;

        SELECT TOP 1 @penaltyStatusId = statusTypeId
        FROM statusTypes
        WHERE name = 'Penalty'
          AND isDeleted = 0;

        IF @penaltyStatusId IS NULL
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
                'Penalty',
                'Movimiento de puntos por penalización',
                @targetPersonId,
                SYSDATETIME(),
                SYSDATETIME(),
                0
            );

            SET @penaltyStatusId = SCOPE_IDENTITY();
        END;

        SELECT @currentStatusName = st.name
        FROM propositions p
        INNER JOIN statusTypes st
            ON st.statusTypeId = p.statusTypesId
        WHERE p.propositionId = @propositionId
          AND p.targetPersonId = @targetPersonId
          AND p.isDeleted = 0
          AND st.isDeleted = 0;

        IF @currentStatusName IS NULL
        BEGIN
            THROW 51401, 'La proposición no existe o no pertenece al usuario objetivo.', 1;
        END;

        IF @currentStatusName <> 'PendingApproval'
        BEGIN
            THROW 51402, 'Solo se puede rechazar una proposición pendiente de aprobación.', 1;
        END;

        SELECT TOP 1 @walletId = walletId
        FROM wallets
        WHERE personId = @targetPersonId
          AND isDeleted = 0
          AND isBlocked = 0;

        IF @walletId IS NULL
        BEGIN
            THROW 51403, 'El usuario objetivo no tiene wallet activa.', 1;
        END;

        SELECT TOP 1 @currentBalance = balancePointsAmount
        FROM walletBalances
        WHERE walletId = @walletId
          AND isDeleted = 0
        ORDER BY calculatedAt DESC, walletBalanceId DESC;

        SET @currentBalance = ISNULL(@currentBalance, 0);

        IF @currentBalance < @penaltyPoints
        BEGIN
            THROW 51404, 'El usuario objetivo no tiene puntos suficientes para cubrir la penalización.', 1;
        END;

        SET @newBalance = @currentBalance - @penaltyPoints;

        UPDATE propositions
        SET statusTypesId = @rejectedStatusId,
            updatedAt = SYSDATETIME(),
            auditPersonId = @targetPersonId
        WHERE propositionId = @propositionId
          AND targetPersonId = @targetPersonId
          AND isDeleted = 0;

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
            @penaltyStatusId,
            @currentBalance,
            @newBalance,
            @newBalance,
            SYSDATETIME(),
            @targetPersonId,
            SYSDATETIME(),
            SYSDATETIME(),
            0
        );

        COMMIT TRANSACTION;

        SELECT
            'Proposition rejected and penalty applied successfully' AS message,
            @newBalance AS newPointsBalance;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO