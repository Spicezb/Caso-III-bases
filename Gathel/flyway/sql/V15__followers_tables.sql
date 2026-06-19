USE GathelDB;
GO

/*=========================================================
  FOLLOW STATUS TYPES
=========================================================*/

IF NOT EXISTS (
    SELECT 1
    FROM statusTypes
    WHERE name = 'Pending'
      AND isDeleted = 0
)
BEGIN
    INSERT INTO statusTypes (
        name,
        description,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES (
        'Pending',
        'Follow request pending',
        GETDATE(),
        GETDATE(),
        0
    );
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM statusTypes
    WHERE name = 'Rejected'
      AND isDeleted = 0
)
BEGIN
    INSERT INTO statusTypes (
        name,
        description,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES (
        'Rejected',
        'Follow request rejected',
        GETDATE(),
        GETDATE(),
        0
    );
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM statusTypes
    WHERE name = 'Accepted'
      AND isDeleted = 0
)
BEGIN
    INSERT INTO statusTypes (
        name,
        description,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES (
        'Accepted',
        'Follow request accepted',
        GETDATE(),
        GETDATE(),
        0
    );
END;
GO

/*=========================================================
  FOLLOW REQUESTS TABLE
=========================================================*/

IF OBJECT_ID('dbo.followRequests', 'U') IS NULL
BEGIN
    CREATE TABLE followRequests(
        followRequestId INT IDENTITY(1,1) PRIMARY KEY,

        senderPersonId INT NOT NULL,
        receiverPersonId INT NOT NULL,

        statusTypeId INT NOT NULL,

        requestDate DATETIME2(3) DEFAULT GETDATE(),
        responseDate DATETIME2(3) NULL,

        createdAt DATETIME2(3) DEFAULT GETDATE(),
        updatedAt DATETIME2(3) DEFAULT GETDATE(),
        isDeleted BIT DEFAULT 0,

        CONSTRAINT FK_followRequests_sender
            FOREIGN KEY(senderPersonId)
            REFERENCES people(personId),

        CONSTRAINT FK_followRequests_receiver
            FOREIGN KEY(receiverPersonId)
            REFERENCES people(personId),

        CONSTRAINT FK_followRequests_statusType
            FOREIGN KEY(statusTypeId)
            REFERENCES statusTypes(statusTypeId),

        CONSTRAINT UQ_followRequests
            UNIQUE(senderPersonId, receiverPersonId)
    );
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_followRequests_senderPersonId'
      AND object_id = OBJECT_ID('dbo.followRequests')
)
BEGIN
    CREATE INDEX IX_followRequests_senderPersonId
    ON followRequests(senderPersonId);
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_followRequests_receiverPersonId'
      AND object_id = OBJECT_ID('dbo.followRequests')
)
BEGIN
    CREATE INDEX IX_followRequests_receiverPersonId
    ON followRequests(receiverPersonId);
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_followRequests_statusTypeId'
      AND object_id = OBJECT_ID('dbo.followRequests')
)
BEGIN
    CREATE INDEX IX_followRequests_statusTypeId
    ON followRequests(statusTypeId);
END;
GO

/*=========================================================
  FOLLOWS TABLE
=========================================================*/

IF OBJECT_ID('dbo.follows', 'U') IS NULL
BEGIN
    CREATE TABLE follows(
        followId INT IDENTITY(1,1) PRIMARY KEY,

        followerPersonId INT NOT NULL,
        followedPersonId INT NOT NULL,

        followDate DATETIME2(3) DEFAULT GETDATE(),

        createdAt DATETIME2(3) DEFAULT GETDATE(),
        updatedAt DATETIME2(3) DEFAULT GETDATE(),
        isDeleted BIT DEFAULT 0,

        CONSTRAINT FK_follows_follower
            FOREIGN KEY(followerPersonId)
            REFERENCES people(personId),

        CONSTRAINT FK_follows_followed
            FOREIGN KEY(followedPersonId)
            REFERENCES people(personId),

        CONSTRAINT UQ_follows
            UNIQUE(followerPersonId, followedPersonId)
    );
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_follows_followerPersonId'
      AND object_id = OBJECT_ID('dbo.follows')
)
BEGIN
    CREATE INDEX IX_follows_followerPersonId
    ON follows(followerPersonId);
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_follows_followedPersonId'
      AND object_id = OBJECT_ID('dbo.follows')
)
BEGIN
    CREATE INDEX IX_follows_followedPersonId
    ON follows(followedPersonId);
END;
GO

/*=========================================================
  FOLLOW REQUESTS SEED
=========================================================*/

DECLARE @pendingStatusTypeId INT;
DECLARE @rejectedStatusTypeId INT;
DECLARE @acceptedStatusTypeId INT;

SELECT @pendingStatusTypeId = statusTypeId
FROM statusTypes
WHERE name = 'Pending'
  AND isDeleted = 0;

SELECT @rejectedStatusTypeId = statusTypeId
FROM statusTypes
WHERE name = 'Rejected'
  AND isDeleted = 0;

SELECT @acceptedStatusTypeId = statusTypeId
FROM statusTypes
WHERE name = 'Accepted'
  AND isDeleted = 0;

IF @pendingStatusTypeId IS NULL
    THROW 55000, 'No existe el estado Pending.', 1;

IF @rejectedStatusTypeId IS NULL
    THROW 55001, 'No existe el estado Rejected.', 1;

IF @acceptedStatusTypeId IS NULL
    THROW 55002, 'No existe el estado Accepted.', 1;

DECLARE @followRequestCounter INT = 1;

WHILE @followRequestCounter <= 3000
BEGIN
    DECLARE @senderId INT;
    DECLARE @receiverId INT;
    DECLARE @statusTypeId INT;

    SET @senderId = ABS(CHECKSUM(NEWID())) % 1000 + 1;
    SET @receiverId = ABS(CHECKSUM(NEWID())) % 1000 + 1;

    WHILE @receiverId = @senderId
    BEGIN
        SET @receiverId = ABS(CHECKSUM(NEWID())) % 1000 + 1;
    END;

    SET @statusTypeId =
        CASE
            WHEN @followRequestCounter <= 1500 THEN @pendingStatusTypeId
            WHEN @followRequestCounter <= 2200 THEN @rejectedStatusTypeId
            ELSE @acceptedStatusTypeId
        END;

    IF EXISTS (
        SELECT 1
        FROM people
        WHERE personId = @senderId
          AND isDeleted = 0
    )
    AND EXISTS (
        SELECT 1
        FROM people
        WHERE personId = @receiverId
          AND isDeleted = 0
    )
    AND NOT EXISTS (
        SELECT 1
        FROM followRequests
        WHERE senderPersonId = @senderId
          AND receiverPersonId = @receiverId
    )
    BEGIN
        INSERT INTO followRequests (
            senderPersonId,
            receiverPersonId,
            statusTypeId,
            requestDate,
            responseDate
        )
        VALUES (
            @senderId,
            @receiverId,
            @statusTypeId,
            DATEADD(
                DAY,
                -(ABS(CHECKSUM(NEWID())) % 365),
                GETDATE()
            ),
            CASE
                WHEN @statusTypeId IN (@rejectedStatusTypeId, @acceptedStatusTypeId)
                THEN DATEADD(
                    DAY,
                    -(ABS(CHECKSUM(NEWID())) % 300),
                    GETDATE()
                )
                ELSE NULL
            END
        );
    END;

    SET @followRequestCounter += 1;
END;
GO

/*=========================================================
  FOLLOWS SEED
=========================================================*/

DECLARE @acceptedStatusTypeId2 INT;

SELECT @acceptedStatusTypeId2 = statusTypeId
FROM statusTypes
WHERE name = 'Accepted'
  AND isDeleted = 0;

INSERT INTO follows (
    followerPersonId,
    followedPersonId,
    followDate
)
SELECT
    fr.senderPersonId,
    fr.receiverPersonId,
    ISNULL(fr.responseDate, fr.requestDate)
FROM followRequests fr
WHERE fr.statusTypeId = @acceptedStatusTypeId2
  AND fr.isDeleted = 0
  AND NOT EXISTS (
      SELECT 1
      FROM follows f
      WHERE f.followerPersonId = fr.senderPersonId
        AND f.followedPersonId = fr.receiverPersonId
  );
GO