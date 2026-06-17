/*
Cambios en auditlogs y referencestypes
*/

USE GathelDB;
GO

/*=========================================================
  Eliminar tabla auditLogs vieja
=========================================================*/

IF OBJECT_ID('auditLogs', 'U') IS NOT NULL
BEGIN
    DROP TABLE auditLogs;
END;
GO


/*=========================================================
  Llenar referenceTypes CON LOS DATOS FALTANTES
=========================================================*/

INSERT INTO referenceTypes(name)
SELECT v.name
FROM
(
    VALUES
    ('PeopleType'),
    ('Country'),
    ('ReportType'),
    ('Currency'),
    ('PaymentMethod'),
    ('CommissionType'),
    ('StatusType'),
    ('PenaltyType'),
    ('SocialPlatform'),
    ('State'),
    ('City'),
    ('Address'),
    ('People'),
    ('SocialAccount'),
    ('Wallet'),
    ('AuthSession'),
    ('ExchangeRate'),
    ('PropositionVote'),
    ('PropositionLike'),
    ('PropositionComment'),
    ('FileType'),
    ('File'),
    ('FileUsageType'),
    ('FileReference'),
    ('WalletBalance'),
    ('TransactionType'),
    ('TransactionAttempt'),
    ('FinancialMovement'),
    ('FinancialBalanceHistory'),
    ('NotificationType'),
    ('StatusHistory'),
    ('AuditLog'),
    ('PredictionPayout'),
    ('AiValidationResult'),
    ('SecurityEventType'),
    ('SecurityEvent'),
    ('PermissionType'),
    ('Permission'),
    ('RolePermission'),
    ('PeoplePermission')
) v(name)
WHERE NOT EXISTS
(
    SELECT 1
    FROM referenceTypes rt
    WHERE rt.name = v.name
);
GO

/*=========================================================
  Nueva tabla auditLogs
=========================================================*/

CREATE TABLE auditLogs(
    logId INT IDENTITY(1,1) PRIMARY KEY,

    referenceTypeId INT NOT NULL,
    referenceId INT NOT NULL,

    actionType VARCHAR(30),

    oldValue VARCHAR(500),
    newValue VARCHAR(500),

    personId INT,

    actionTimestamp DATETIME2(3) DEFAULT GETDATE(),

    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_auditLogs_referenceType
        FOREIGN KEY(referenceTypeId)
        REFERENCES referenceTypes(referenceTypeId),

    CONSTRAINT FK_auditLogs_person
        FOREIGN KEY(personId)
        REFERENCES people(personId)
);
GO

/*=========================================================
  NUEVOS INDICES
=========================================================*/

CREATE INDEX IX_auditLogs_personId
ON auditLogs(personId);
GO

CREATE INDEX IX_auditLogs_referenceId
ON auditLogs(referenceTypeId, referenceId);
GO


CREATE INDEX IX_auditLogs_actionTimestamp
ON auditLogs(actionTimestamp);
GO

/*=========================================================
  RELLENAR AUDIT LOGS
=========================================================*/

DECLARE @auditCounter INT = 1;
DECLARE @maxReferenceTypeId INT;

SELECT @maxReferenceTypeId = MAX(referenceTypeId)
FROM referenceTypes;

WHILE @auditCounter <= 5000
BEGIN

    INSERT INTO auditLogs
    (
        referenceTypeId,
        referenceId,
        actionType,
        oldValue,
        newValue,
        personId,
        actionTimestamp
    )
    VALUES
    (
        ABS(CHECKSUM(NEWID())) % @maxReferenceTypeId + 1,

        ABS(CHECKSUM(NEWID())) % 5000 + 1,

        CASE ABS(CHECKSUM(NEWID())) % 3
            WHEN 0 THEN 'INSERT'
            WHEN 1 THEN 'UPDATE'
            ELSE 'DELETE'
        END,

        CASE ABS(CHECKSUM(NEWID())) % 3
            WHEN 0 THEN NULL
            ELSE CONCAT('old_value_', @auditCounter)
        END,

        CASE ABS(CHECKSUM(NEWID())) % 3
            WHEN 2 THEN NULL
            ELSE CONCAT('new_value_', @auditCounter)
        END,

        ABS(CHECKSUM(NEWID())) % 1000 + 1,

        DATEADD
        (
            DAY,
            -(ABS(CHECKSUM(NEWID())) % 365),
            GETDATE()
        )
    );

    SET @auditCounter += 1;

END;
GO