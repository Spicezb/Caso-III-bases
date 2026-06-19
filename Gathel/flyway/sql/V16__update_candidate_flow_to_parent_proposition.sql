USE GathelDB;
GO


------------------------------------------------------------
-- 1. Asegurar índice útil por parentproposition

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_propositions_parent_status'
      AND object_id = OBJECT_ID('dbo.propositions')
)
BEGIN
    CREATE INDEX IX_propositions_parent_status
    ON dbo.propositions(parentproposition, statusTypesId)
    INCLUDE (
        propositionId,
        creatorPersonId,
        targetPersonId,
        title,
        createdAt,
        updatedAt,
        isDeleted
    );
END;
GO


CREATE OR ALTER PROCEDURE dbo.spCreateProposition
    @creatorPersonId INT,
    @targetPersonId INT = NULL,
    @targetSocialAccountId INT = NULL,
    @title VARCHAR(150),
    @description VARCHAR(MAX) = NULL,
    @startPredictionDateTime DATETIME = NULL,
    @endPredictionDateTime DATETIME = NULL,
    @minimumEntryPointsAmount DECIMAL(10, 2) = NULL,
    @winningProfitPercentage DECIMAL(10, 2) = NULL,
    @parentProposition INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @votingStatusId INT;
        DECLARE @parentTargetPersonId INT;
        DECLARE @parentTargetSocialAccountId INT;
        DECLARE @parentStatusName VARCHAR(40);
        DECLARE @votingStart DATETIME2(3);
        DECLARE @votingEnd DATETIME2(3);

        ------------------------------------------------------------
        -- 1. Validar creador

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
        -- 2. Validar título

        IF @title IS NULL OR LTRIM(RTRIM(@title)) = ''
        BEGIN
            THROW 50101, 'El título de la proposición es obligatorio.', 1;
        END;

        ------------------------------------------------------------
        -- 3. Obtener o crear estado Voting

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
        -- 4. Si es proposición hija, validar padre

        IF @parentProposition IS NOT NULL
        BEGIN
            SELECT
                @parentTargetPersonId = p.targetPersonId,
                @parentTargetSocialAccountId = p.targetSocialAccountId,
                @parentStatusName = st.name,
                @votingStart = p.startPredictionDateTime,
                @votingEnd = p.endPredictionDateTime
            FROM propositions p
            INNER JOIN statusTypes st
                ON st.statusTypeId = p.statusTypesId
            WHERE p.propositionId = @parentProposition
              AND p.parentproposition IS NULL
              AND p.isDeleted = 0
              AND st.isDeleted = 0;

            IF @parentTargetPersonId IS NULL
            BEGIN
                THROW 50102, 'El Gathel padre no existe o no es una proposición padre válida.', 1;
            END;

            IF @parentStatusName NOT IN ('Candidate', 'Voting')
            BEGIN
                THROW 50103, 'Solo se pueden agregar proposiciones candidatas a un Gathel en votación.', 1;
            END;

            IF @targetPersonId IS NULL
            BEGIN
                SET @targetPersonId = @parentTargetPersonId;
            END;

            IF @targetPersonId <> @parentTargetPersonId
            BEGIN
                THROW 50104, 'La proposición hija debe tener el mismo usuario objetivo que el Gathel padre.', 1;
            END;

            IF @targetSocialAccountId IS NULL
            BEGIN
                SET @targetSocialAccountId = @parentTargetSocialAccountId;
            END;
        END;
        ELSE
        BEGIN
            ------------------------------------------------------------
            -- Si es Gathel padre, validar target

            IF @targetPersonId IS NULL
            BEGIN
                THROW 50105, 'El Gathel padre debe tener usuario objetivo.', 1;
            END;

            IF NOT EXISTS (
                SELECT 1
                FROM people
                WHERE personId = @targetPersonId
                  AND isDeleted = 0
                  AND isActive = 1
            )
            BEGIN
                THROW 50106, 'La persona objetivo no existe o no está activa.', 1;
            END;

            SET @votingStart = ISNULL(@startPredictionDateTime, SYSDATETIME());
            SET @votingEnd = ISNULL(@endPredictionDateTime, DATEADD(HOUR, 24, @votingStart));
        END;

        ------------------------------------------------------------
        -- 5. Insertar padre o hija como Voting

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
            @parentProposition,
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
            CASE
                WHEN @parentProposition IS NULL
                    THEN 'Gathel parent proposition created successfully'
                ELSE 'Candidate proposition created successfully'
            END AS message,
            @propositionId AS propositionId,
            @parentProposition AS parentPropositionId,
            @votingStart AS votingStartDateTime,
            @votingEnd AS votingEndDateTime;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


CREATE OR ALTER PROCEDURE dbo.spSelectWinningPropositionAfterVoting
    @parentPropositionId INT = NULL,
    @targetPersonId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @pendingApprovalStatusId INT;
        DECLARE @closedStatusId INT;
        DECLARE @firstCreatedAt DATETIME2(3);
        DECLARE @winnerPropositionId INT;
        DECLARE @resolvedTargetPersonId INT;

        SELECT TOP 1 @pendingApprovalStatusId = statusTypeId
        FROM statusTypes
        WHERE name = 'PendingApproval'
          AND isDeleted = 0;

        SELECT TOP 1 @closedStatusId = statusTypeId
        FROM statusTypes
        WHERE name = 'Closed'
          AND isDeleted = 0;

        IF @pendingApprovalStatusId IS NULL
            THROW 51200, 'No existe el estado PendingApproval.', 1;

        IF @closedStatusId IS NULL
            THROW 51201, 'No existe el estado Closed.', 1;

        IF @parentPropositionId IS NULL AND @targetPersonId IS NULL
            THROW 51202, 'Debe indicar parentPropositionId o targetPersonId.', 1;



        IF @parentPropositionId IS NOT NULL
        BEGIN
            SELECT
                @firstCreatedAt = p.createdAt,
                @resolvedTargetPersonId = p.targetPersonId
            FROM propositions p
            WHERE p.propositionId = @parentPropositionId
              AND p.parentproposition IS NULL
              AND p.isDeleted = 0;

            IF @firstCreatedAt IS NULL
            BEGIN
                THROW 51203, 'El Gathel padre no existe o no es válido.', 1;
            END;

            IF DATEADD(HOUR, 24, @firstCreatedAt) > SYSDATETIME()
            BEGIN
                THROW 51204, 'Aún no han pasado 24 horas desde la creación del Gathel.', 1;
            END;

            SELECT TOP 1
                @winnerPropositionId = child.propositionId
            FROM propositions child
            INNER JOIN statusTypes st
                ON st.statusTypeId = child.statusTypesId
            LEFT JOIN propositionVotes pv
                ON pv.propositionId = child.propositionId
                AND pv.isDeleted = 0
                AND pv.voteValue = 1
            WHERE child.parentproposition = @parentPropositionId
              AND child.isDeleted = 0
              AND st.name IN ('Candidate', 'Voting')
              AND st.isDeleted = 0
            GROUP BY
                child.propositionId,
                child.createdAt
            ORDER BY
                COUNT(pv.propositionVoteId) DESC,
                child.createdAt ASC;

            IF @winnerPropositionId IS NULL
            BEGIN
                THROW 51205, 'No hay proposiciones candidatas para este Gathel.', 1;
            END;

            UPDATE propositions
            SET statusTypesId = @pendingApprovalStatusId,
                updatedAt = SYSDATETIME(),
                auditPersonId = @resolvedTargetPersonId
            WHERE propositionId = @winnerPropositionId
              AND isDeleted = 0;

            UPDATE child
            SET statusTypesId = @closedStatusId,
                updatedAt = SYSDATETIME(),
                auditPersonId = @resolvedTargetPersonId
            FROM propositions child
            INNER JOIN statusTypes st
                ON st.statusTypeId = child.statusTypesId
            WHERE child.parentproposition = @parentPropositionId
              AND child.propositionId <> @winnerPropositionId
              AND child.isDeleted = 0
              AND st.name IN ('Candidate', 'Voting');

            

            UPDATE propositions
            SET statusTypesId = @closedStatusId,
                updatedAt = SYSDATETIME(),
                auditPersonId = @resolvedTargetPersonId
            WHERE propositionId = @parentPropositionId
              AND isDeleted = 0;

            COMMIT TRANSACTION;

            SELECT
                'Winning candidate selected successfully by parent proposition' AS message,
                @parentPropositionId AS parentPropositionId,
                @winnerPropositionId AS winnerPropositionId;

            RETURN;
        END;

        SELECT TOP 1 @firstCreatedAt = p.createdAt
        FROM propositions p
        INNER JOIN statusTypes st
            ON st.statusTypeId = p.statusTypesId
        WHERE p.targetPersonId = @targetPersonId
          AND p.parentproposition IS NOT NULL
          AND p.isDeleted = 0
          AND st.name IN ('Candidate', 'Voting')
          AND st.isDeleted = 0
        ORDER BY p.createdAt ASC;

        IF @firstCreatedAt IS NULL
        BEGIN
            THROW 51206, 'No hay proposiciones candidatas para este usuario.', 1;
        END;

        IF DATEADD(HOUR, 24, @firstCreatedAt) > SYSDATETIME()
        BEGIN
            THROW 51207, 'Aún no han pasado 24 horas desde la primera proposición candidata.', 1;
        END;

        SELECT TOP 1
            @winnerPropositionId = p.propositionId,
            @parentPropositionId = p.parentproposition
        FROM propositions p
        INNER JOIN statusTypes st
            ON st.statusTypeId = p.statusTypesId
        LEFT JOIN propositionVotes pv
            ON pv.propositionId = p.propositionId
            AND pv.isDeleted = 0
            AND pv.voteValue = 1
        WHERE p.targetPersonId = @targetPersonId
          AND p.parentproposition IS NOT NULL
          AND p.isDeleted = 0
          AND st.name IN ('Candidate', 'Voting')
          AND st.isDeleted = 0
          AND p.createdAt >= @firstCreatedAt
          AND p.createdAt < DATEADD(HOUR, 24, @firstCreatedAt)
        GROUP BY
            p.propositionId,
            p.parentproposition,
            p.createdAt
        ORDER BY
            COUNT(pv.propositionVoteId) DESC,
            p.createdAt ASC;

        IF @winnerPropositionId IS NULL
        BEGIN
            THROW 51208, 'No se pudo seleccionar una proposición ganadora.', 1;
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
        WHERE p.parentproposition = @parentPropositionId
          AND p.propositionId <> @winnerPropositionId
          AND p.isDeleted = 0
          AND st.name IN ('Candidate', 'Voting');

        UPDATE propositions
        SET statusTypesId = @closedStatusId,
            updatedAt = SYSDATETIME(),
            auditPersonId = @targetPersonId
        WHERE propositionId = @parentPropositionId
          AND isDeleted = 0;

        COMMIT TRANSACTION;

        SELECT
            'Winning candidate selected successfully by target fallback' AS message,
            @parentPropositionId AS parentPropositionId,
            @winnerPropositionId AS winnerPropositionId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO