USE GathelDB;
GO

CREATE OR ALTER PROCEDURE dbo.spVoteForCandidateProposition
    @propositionId INT,
    @personId INT,
    @voteValue BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @parentPropositionId INT;
        DECLARE @targetPersonId INT;
        DECLARE @candidateStatusName VARCHAR(40);
        DECLARE @parentStatusName VARCHAR(40);
        DECLARE @existingVotePropositionId INT;

        ------------------------------------------------------------
        -- 1. Validar usuario
        ------------------------------------------------------------
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

        ------------------------------------------------------------
        -- 2. Validar que la proposición sea hija candidata
        ------------------------------------------------------------
        SELECT
            @parentPropositionId = child.parentproposition,
            @targetPersonId = child.targetPersonId,
            @candidateStatusName = childStatus.name,
            @parentStatusName = parentStatus.name
        FROM propositions child
        INNER JOIN statusTypes childStatus
            ON childStatus.statusTypeId = child.statusTypesId
        INNER JOIN propositions parent
            ON parent.propositionId = child.parentproposition
        INNER JOIN statusTypes parentStatus
            ON parentStatus.statusTypeId = parent.statusTypesId
        WHERE child.propositionId = @propositionId
          AND child.isDeleted = 0
          AND parent.isDeleted = 0
          AND childStatus.isDeleted = 0
          AND parentStatus.isDeleted = 0;

        IF @parentPropositionId IS NULL
        BEGIN
            THROW 51101, 'Solo se puede votar por una proposición candidata hija.', 1;
        END;

        IF @candidateStatusName NOT IN ('Candidate', 'Voting')
        BEGIN
            THROW 51102, 'Esta proposición candidata no está en etapa de votación.', 1;
        END;

        IF @parentStatusName NOT IN ('Candidate', 'Voting')
        BEGIN
            THROW 51103, 'El Gathel padre no está en etapa de votación.', 1;
        END;

        ------------------------------------------------------------
        -- 3. El usuario objetivo no puede votar sobre su propio Gathel
        ------------------------------------------------------------
        IF @targetPersonId = @personId
        BEGIN
            THROW 51104, 'No podés votar por opciones de un Gathel que es sobre vos.', 1;
        END;

        ------------------------------------------------------------
        -- 4. Buscar si ya votó en alguna hija del mismo padre
        ------------------------------------------------------------
        SELECT TOP 1
            @existingVotePropositionId = pv.propositionId
        FROM propositionVotes pv
        INNER JOIN propositions p
            ON p.propositionId = pv.propositionId
        WHERE pv.personId = @personId
          AND pv.isDeleted = 0
          AND pv.voteValue = 1
          AND p.parentproposition = @parentPropositionId
          AND p.isDeleted = 0;

        ------------------------------------------------------------
        -- 5. Si ya votó por otra opción hermana, bloquear
        ------------------------------------------------------------
        IF @existingVotePropositionId IS NOT NULL
           AND @existingVotePropositionId <> @propositionId
        BEGIN
            THROW 51105, 'Ya votaste por una opción de este Gathel. Solo se permite un voto por Gathel.', 1;
        END;

        ------------------------------------------------------------
        -- 6. Si ya votó por la misma opción, dejarlo idempotente
        ------------------------------------------------------------
        IF @existingVotePropositionId = @propositionId
        BEGIN
            UPDATE propositionVotes
            SET voteValue = 1,
                updatedAt = SYSDATETIME(),
                auditPersonId = @personId
            WHERE propositionId = @propositionId
              AND personId = @personId
              AND isDeleted = 0;

            COMMIT TRANSACTION;

            SELECT
                'Vote already registered for this candidate' AS message,
                @propositionId AS propositionId,
                @parentPropositionId AS parentPropositionId;

            RETURN;
        END;

        ------------------------------------------------------------
        -- 7. Insertar voto nuevo
        ------------------------------------------------------------
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

        COMMIT TRANSACTION;

        SELECT
            'Vote registered successfully' AS message,
            @propositionId AS propositionId,
            @parentPropositionId AS parentPropositionId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO