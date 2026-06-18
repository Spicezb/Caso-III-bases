USE GathelDB;
GO

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
GO

CREATE INDEX IX_followRequests_senderPersonId
ON followRequests(senderPersonId);
GO

CREATE INDEX IX_followRequests_receiverPersonId
ON followRequests(receiverPersonId);
GO

CREATE INDEX IX_followRequests_statusTypeId
ON followRequests(statusTypeId);
GO


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
GO

CREATE INDEX IX_follows_followerPersonId
ON follows(followerPersonId);
GO

CREATE INDEX IX_follows_followedPersonId
ON follows(followedPersonId);
GO

/*=========================================================
  FOLLOW STATUS
=========================================================*/

INSERT INTO statusTypes
(
    name,
    description
)
VALUES
(
    'Accepted',
    'Process accepted'
);
GO

/*=========================================================
  FOLLOW REQUESTS
=========================================================*/

DECLARE @followRequestCounter INT = 1;

WHILE @followRequestCounter <= 3000
BEGIN

    DECLARE @senderId INT;
    DECLARE @receiverId INT;
    DECLARE @statusTypeId INT;

    SET @senderId =
        ABS(CHECKSUM(NEWID())) % 1000 + 1;

    SET @receiverId =
        ABS(CHECKSUM(NEWID())) % 1000 + 1;

    WHILE @receiverId = @senderId
    BEGIN
        SET @receiverId =
            ABS(CHECKSUM(NEWID())) % 1000 + 1;
    END;

    SET @statusTypeId =
        CASE
            WHEN @followRequestCounter <= 1500 THEN 1
            WHEN @followRequestCounter <= 2200 THEN 5
            ELSE 8
        END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM followRequests
        WHERE senderPersonId = @senderId
          AND receiverPersonId = @receiverId
    )
    BEGIN

        INSERT INTO followRequests
        (
            senderPersonId,
            receiverPersonId,
            statusTypeId,
            requestDate,
            responseDate
        )
        VALUES
        (
            @senderId,
            @receiverId,
            @statusTypeId,

            DATEADD
            (
                DAY,
                -(ABS(CHECKSUM(NEWID())) % 365),
                GETDATE()
            ),

            CASE
                WHEN @statusTypeId IN (5,8)
                THEN DATEADD
                (
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
  FOLLOWS
=========================================================*/

INSERT INTO follows
(
    followerPersonId,
    followedPersonId,
    followDate
)
SELECT
    senderPersonId,
    receiverPersonId,

    ISNULL
    (
        responseDate,
        requestDate
    )
FROM followRequests
WHERE statusTypeId = 8;
GO