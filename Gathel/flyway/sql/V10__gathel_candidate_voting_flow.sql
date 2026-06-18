USE GathelDB;
GO

/* ============================================================
   V10 - Gathel candidate voting flow
   Usa tablas existentes:
   - propositions
   - propositionVotes
   - statusTypes
   ============================================================ */

------------------------------------------------------------
-- 1. Estados requeridos para el flujo real de Gathel
------------------------------------------------------------

IF NOT EXISTS (
    SELECT 1 FROM statusTypes
    WHERE name = 'Candidate' AND isDeleted = 0
)
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
        'Candidate',
        'Proposición candidata antes de ser votada o seleccionada',
        NULL,
        SYSDATETIME(),
        SYSDATETIME(),
        0
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM statusTypes
    WHERE name = 'Voting' AND isDeleted = 0
)
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
        NULL,
        SYSDATETIME(),
        SYSDATETIME(),
        0
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM statusTypes
    WHERE name = 'PendingApproval' AND isDeleted = 0
)
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
        'PendingApproval',
        'Proposición ganadora esperando aceptación o rechazo del usuario objetivo',
        NULL,
        SYSDATETIME(),
        SYSDATETIME(),
        0
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM statusTypes
    WHERE name = 'Rejected' AND isDeleted = 0
)
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
        'Rejected',
        'Proposición rechazada por el usuario objetivo',
        NULL,
        SYSDATETIME(),
        SYSDATETIME(),
        0
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM statusTypes
    WHERE name = 'Closed' AND isDeleted = 0
)
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
        'Closed',
        'Proposición cerrada para nuevas predicciones',
        NULL,
        SYSDATETIME(),
        SYSDATETIME(),
        0
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM statusTypes
    WHERE name = 'Validation' AND isDeleted = 0
)
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
        'Validation',
        'Proposición esperando evidencia o validación del resultado',
        NULL,
        SYSDATETIME(),
        SYSDATETIME(),
        0
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM statusTypes
    WHERE name = 'Ambiguous' AND isDeleted = 0
)
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
        'Ambiguous',
        'Resultado ambiguo, requiere evidencia adicional o validación manual',
        NULL,
        SYSDATETIME(),
        SYSDATETIME(),
        0
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM statusTypes
    WHERE name = 'Finalized' AND isDeleted = 0
)
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
        'Finalized',
        'Proposición finalizada con resultado validado',
        NULL,
        SYSDATETIME(),
        SYSDATETIME(),
        0
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM statusTypes
    WHERE name = 'Refunded' AND isDeleted = 0
)
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
        'Refunded',
        'Proposición sin validación posible, apuestas devueltas',
        NULL,
        SYSDATETIME(),
        SYSDATETIME(),
        0
    );
END;
GO

------------------------------------------------------------
-- 2. Índice para contar votos de una proposición más rápido
--    Ya existe IX_propositionVotes_personId, pero falta uno por propositionId.
------------------------------------------------------------

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_propositionVotes_propositionId'
      AND object_id = OBJECT_ID('dbo.propositionVotes')
)
BEGIN
    CREATE INDEX IX_propositionVotes_propositionId
    ON dbo.propositionVotes(propositionId)
    INCLUDE (personId, voteValue, votedAt, isDeleted);
END;
GO

------------------------------------------------------------
-- 3. Índice para buscar votos positivos por proposición
------------------------------------------------------------

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_propositionVotes_positiveVotes'
      AND object_id = OBJECT_ID('dbo.propositionVotes')
)
BEGIN
    CREATE INDEX IX_propositionVotes_positiveVotes
    ON dbo.propositionVotes(propositionId, voteValue)
    INCLUDE (personId, votedAt)
    WHERE isDeleted = 0;
END;
GO