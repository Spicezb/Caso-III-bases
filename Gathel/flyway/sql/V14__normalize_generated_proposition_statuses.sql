USE GathelDB;
GO

DECLARE @votingStatusId INT;
DECLARE @pendingApprovalStatusId INT;
DECLARE @activeStatusId INT;
DECLARE @closedStatusId INT;

SELECT @votingStatusId = statusTypeId
FROM statusTypes
WHERE name = 'Voting'
  AND isDeleted = 0;

SELECT @pendingApprovalStatusId = statusTypeId
FROM statusTypes
WHERE name = 'PendingApproval'
  AND isDeleted = 0;

SELECT @activeStatusId = statusTypeId
FROM statusTypes
WHERE name = 'Active'
  AND isDeleted = 0;

SELECT @closedStatusId = statusTypeId
FROM statusTypes
WHERE name = 'Closed'
  AND isDeleted = 0;

IF @votingStatusId IS NULL
    THROW 53000, 'No existe el estado Voting.', 1;

IF @pendingApprovalStatusId IS NULL
    THROW 53001, 'No existe el estado PendingApproval.', 1;

IF @activeStatusId IS NULL
    THROW 53002, 'No existe el estado Active.', 1;

IF @closedStatusId IS NULL
    THROW 53003, 'No existe el estado Closed.', 1;

------------------------------------------------------------
-- 1. Proposiciones generadas con target NULL no deberían ser apostables
------------------------------------------------------------

UPDATE propositions
SET statusTypesId = @closedStatusId,
    updatedAt = SYSDATETIME()
WHERE title LIKE 'Prediction #%'
  AND targetPersonId IS NULL
  AND isDeleted = 0;
GO

------------------------------------------------------------
-- 2. Distribuir proposiciones generadas con target válido
------------------------------------------------------------

DECLARE @votingStatusId2 INT;
DECLARE @pendingApprovalStatusId2 INT;
DECLARE @activeStatusId2 INT;
DECLARE @closedStatusId2 INT;

SELECT @votingStatusId2 = statusTypeId
FROM statusTypes
WHERE name = 'Voting'
  AND isDeleted = 0;

SELECT @pendingApprovalStatusId2 = statusTypeId
FROM statusTypes
WHERE name = 'PendingApproval'
  AND isDeleted = 0;

SELECT @activeStatusId2 = statusTypeId
FROM statusTypes
WHERE name = 'Active'
  AND isDeleted = 0;

SELECT @closedStatusId2 = statusTypeId
FROM statusTypes
WHERE name = 'Closed'
  AND isDeleted = 0;

UPDATE propositions
SET statusTypesId =
    CASE
        WHEN propositionId % 10 IN (0, 1, 2, 3, 4, 5) THEN @votingStatusId2
        WHEN propositionId % 10 IN (6, 7) THEN @pendingApprovalStatusId2
        WHEN propositionId % 10 = 8 THEN @activeStatusId2
        ELSE @closedStatusId2
    END,
    startPredictionDateTime =
    CASE
        WHEN propositionId % 10 = 8 THEN DATEADD(DAY, -1, SYSDATETIME())
        ELSE startPredictionDateTime
    END,
    endPredictionDateTime =
    CASE
        WHEN propositionId % 10 = 8 THEN DATEADD(DAY, 7, SYSDATETIME())
        ELSE endPredictionDateTime
    END,
    updatedAt = SYSDATETIME()
WHERE title LIKE 'Prediction #%'
  AND targetPersonId IS NOT NULL
  AND isDeleted = 0;
GO