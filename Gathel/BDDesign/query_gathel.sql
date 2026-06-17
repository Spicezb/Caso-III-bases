USE GathelDB;
GO

CREATE TABLE peopleTypes(
    peopleTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(30),
    description VARCHAR(100),
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0
);
GO

CREATE TABLE countries(
    countryId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(80),
    isoCode VARCHAR(5),
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0
);
GO

CREATE TABLE reportTypes(
    reportTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(40) UNIQUE,
    description VARCHAR(120),
    auditPersonId INT NULL,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0
);
GO

CREATE TABLE currencies(
    currencyId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(30),
    code VARCHAR(10) UNIQUE,
    symbol VARCHAR(10),
    auditPersonId INT NULL,
    isDefaultCurrencie BIT DEFAULT 0,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0
);
GO

CREATE TABLE referenceTypes(
    referenceTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(30),
    auditPersonId INT NULL,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0
);
GO

CREATE TABLE paymentMethods(
    paymentMethodId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(30),
    logo INT NULL,
    config NVARCHAR(MAX),
    auditPersonId INT NULL,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0
);
GO

CREATE TABLE commissionTypes(
    commissionTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(40),
    description VARCHAR(120),
    percentage NUMERIC(5,2),
    isActive BIT DEFAULT 1,
    auditPersonId INT NULL,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0
);
GO

CREATE TABLE statusTypes(
    statusTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(40),
    description VARCHAR(120),
    auditPersonId INT NULL,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0
);
GO

CREATE TABLE penaltyTypes(
    penaltyTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(40) UNIQUE,
    description VARCHAR(120),
    pointsPercentage NUMERIC(5,2),
    auditPersonId INT NULL,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0
);
GO

CREATE TABLE socialPlatforms(
    socialPlatformId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(40),
    apiUrl VARCHAR(255),
    logo INT NULL,
    config NVARCHAR(MAX),
    auditPersonId INT NULL,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0
);
GO

CREATE TABLE states(
    stateId INT IDENTITY(1,1) PRIMARY KEY,
    countryId INT,
    name VARCHAR(80),
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_states_country
        FOREIGN KEY(countryId)
        REFERENCES countries(countryId)
);
GO

CREATE TABLE cities(
    cityId INT IDENTITY(1,1) PRIMARY KEY,
    stateId INT,
    name VARCHAR(80),
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_cities_state
        FOREIGN KEY(stateId)
        REFERENCES states(stateId)
);
GO

CREATE TABLE addresses(
    addressId INT IDENTITY(1,1) PRIMARY KEY,
    cityId INT,
    exactAddress VARCHAR(200),
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_addresses_city
        FOREIGN KEY(cityId)
        REFERENCES cities(cityId)
);
GO

CREATE TABLE people(
    personId INT IDENTITY(1,1) PRIMARY KEY,
    peopleTypeId INT,
    name VARCHAR(60),
    lastName VARCHAR(60),
    identification VARCHAR(30),
    phone VARCHAR(20),
    email VARCHAR(100),
    passwordHash VARBINARY(MAX),
    username VARCHAR(40),
    biography VARCHAR(200),
    birthDate DATE,
    addressId INT,
    isVerified BIT DEFAULT 0,
    isActive BIT DEFAULT 0,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT UQ_people_email UNIQUE(email),
    CONSTRAINT UQ_people_username UNIQUE(username),
    CONSTRAINT UQ_people_identification UNIQUE(identification),

    CONSTRAINT FK_people_peopleType
        FOREIGN KEY(peopleTypeId)
        REFERENCES peopleTypes(peopleTypeId),

    CONSTRAINT FK_people_address
        FOREIGN KEY(addressId)
        REFERENCES addresses(addressId)
);
GO

CREATE TABLE socialAccounts(
    socialAccountId INT IDENTITY(1,1) PRIMARY KEY,
    personId INT,
    socialPlatformId INT,
    username VARCHAR(80),
    profileUrl VARCHAR(255),
    accessToken VARBINARY(MAX),
    refreshToken VARBINARY(MAX),
    isVerified BIT DEFAULT 0,
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT UQ_socialAccounts_platform_username
        UNIQUE(socialPlatformId, username),

    CONSTRAINT FK_socialAccounts_person
        FOREIGN KEY(personId)
        REFERENCES people(personId),

    CONSTRAINT FK_socialAccounts_platform
        FOREIGN KEY(socialPlatformId)
        REFERENCES socialPlatforms(socialPlatformId)
);
GO

CREATE TABLE wallets(
    walletId INT IDENTITY(1,1) PRIMARY KEY,
    personId INT,
    isBlocked BIT DEFAULT 0,
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_wallets_person
        FOREIGN KEY(personId)
        REFERENCES people(personId)
);
GO

CREATE TABLE authSessions(
    authSessionId INT IDENTITY(1,1) PRIMARY KEY,
    personId INT,
    refreshToken VARBINARY(MAX),
    ipAddress VARCHAR(100),
    expiresAt DATETIME2(3) DEFAULT GETDATE(),
    lastActivityAt DATETIME2(3) DEFAULT GETDATE(),
    isRevoked BIT DEFAULT 0,
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_authSessions_person
        FOREIGN KEY(personId)
        REFERENCES people(personId)
);
GO

CREATE TABLE exchangeRates(
    exchangeRateId INT IDENTITY(1,1) PRIMARY KEY,
    currencyId INT,
    rate NUMERIC(12,6),
    isCurrent BIT DEFAULT 0,
    exchangeDateTime DATETIME2(3) DEFAULT GETDATE(),
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_exchangeRates_currency
        FOREIGN KEY(currencyId)
        REFERENCES currencies(currencyId)
);
GO

CREATE TABLE propositions(
    propositionId INT IDENTITY(1,1) PRIMARY KEY,
    parentproposition INT NULL,
    statusTypesId INT,
    creatorPersonId INT,
    targetPersonId INT,
    targetSocialAccountId INT,
    title VARCHAR(120),
    description VARCHAR(300),
    startPredictionDateTime DATETIME2(3) DEFAULT GETDATE(),
    endPredictionDateTime DATETIME2(3) DEFAULT GETDATE(),
    winningOption BIT,
    minimumEntryPointsAmount NUMERIC(16,2),
    winningProfitPercentage NUMERIC(5,2),
    isPublic BIT DEFAULT 1,
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_propositions_parent
        FOREIGN KEY(parentproposition)
        REFERENCES propositions(propositionId),

    CONSTRAINT FK_propositions_status
        FOREIGN KEY(statusTypesId)
        REFERENCES statusTypes(statusTypeId),

    CONSTRAINT FK_propositions_creator
        FOREIGN KEY(creatorPersonId)
        REFERENCES people(personId),

    CONSTRAINT FK_propositions_targetPerson
        FOREIGN KEY(targetPersonId)
        REFERENCES people(personId),

    CONSTRAINT FK_propositions_targetSocialAccount
        FOREIGN KEY(targetSocialAccountId)
        REFERENCES socialAccounts(socialAccountId)
);
GO

CREATE TABLE propositionVotes(
    propositionVoteId INT IDENTITY(1,1) PRIMARY KEY,
    propositionId INT,
    personId INT,
    voteValue BIT,
    votedAt DATETIME2(3) DEFAULT GETDATE(),
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT UQ_propositionVotes
        UNIQUE(propositionId, personId),

    CONSTRAINT FK_propositionVotes_proposition
        FOREIGN KEY(propositionId)
        REFERENCES propositions(propositionId),

    CONSTRAINT FK_propositionVotes_person
        FOREIGN KEY(personId)
        REFERENCES people(personId)
);
GO

CREATE TABLE propositionLikes(
    propositionLikeId INT IDENTITY(1,1) PRIMARY KEY,
    propositionId INT,
    personId INT,
    likedAt DATETIME2(3) DEFAULT GETDATE(),
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT UQ_propositionLikes
        UNIQUE(propositionId, personId),

    CONSTRAINT FK_propositionLikes_proposition
        FOREIGN KEY(propositionId)
        REFERENCES propositions(propositionId),

    CONSTRAINT FK_propositionLikes_person
        FOREIGN KEY(personId)
        REFERENCES people(personId)
);
GO

CREATE TABLE propositionComments(
    propositionCommentId INT IDENTITY(1,1) PRIMARY KEY,
    propositionId INT,
    personId INT,
    comment VARCHAR(255),
    commentedAt DATETIME2(3) DEFAULT GETDATE(),
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_propositionComments_proposition
        FOREIGN KEY(propositionId)
        REFERENCES propositions(propositionId),

    CONSTRAINT FK_propositionComments_person
        FOREIGN KEY(personId)
        REFERENCES people(personId)
);
GO

CREATE TABLE fileTypes(
    fileTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(20),
    mimeType VARCHAR(100),
    description VARCHAR(120),
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0
);
GO

CREATE TABLE files(
    fileId INT IDENTITY(1,1) PRIMARY KEY,
    fileTypeId INT,
    fileName VARCHAR(255),
    fileUrl VARCHAR(255),
    fileSize BIGINT,
    uploadedByPersonId INT,
    uploadedAt DATETIME2(3) DEFAULT GETDATE(),
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_files_fileType
        FOREIGN KEY(fileTypeId)
        REFERENCES fileTypes(fileTypeId),

    CONSTRAINT FK_files_uploadedByPerson
        FOREIGN KEY(uploadedByPersonId)
        REFERENCES people(personId)
);
GO

CREATE TABLE fileUsageTypes(
    fileUsageTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(40),
    description VARCHAR(120),
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0
);
GO

CREATE TABLE fileReferences(
    fileReferenceId INT IDENTITY(1,1) PRIMARY KEY,
    fileId INT,
    referenceTypeId INT,
    referenceId INT,
    fileUsageTypeId INT,
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_fileReferences_file
        FOREIGN KEY(fileId)
        REFERENCES files(fileId),

    CONSTRAINT FK_fileReferences_referenceType
        FOREIGN KEY(referenceTypeId)
        REFERENCES referenceTypes(referenceTypeId),

    CONSTRAINT FK_fileReferences_fileUsageType
        FOREIGN KEY(fileUsageTypeId)
        REFERENCES fileUsageTypes(fileUsageTypeId)
);
GO

ALTER TABLE paymentMethods
ADD CONSTRAINT FK_paymentMethods_logo
FOREIGN KEY(logo)
REFERENCES files(fileId);
GO

ALTER TABLE socialPlatforms
ADD CONSTRAINT FK_socialPlatforms_logo
FOREIGN KEY(logo)
REFERENCES files(fileId);
GO

CREATE TABLE predictions(
    predictionId INT IDENTITY(1,1) PRIMARY KEY,
    statusTypesId INT,
    propositionId INT,
    personId INT,
    predictionValue BIT,
    pointsAmount NUMERIC(10,2),
    moneyAmount NUMERIC(14,2),
    currencyId INT,
    exchangeRateId INT,
    predictionDateTime DATETIME2(3) DEFAULT GETDATE(),
    isWinner BIT DEFAULT 0,
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_predictions_statusTypes
        FOREIGN KEY(statusTypesId)
        REFERENCES statusTypes(statusTypeId),

    CONSTRAINT FK_predictions_proposition
        FOREIGN KEY(propositionId)
        REFERENCES propositions(propositionId),

    CONSTRAINT FK_predictions_person
        FOREIGN KEY(personId)
        REFERENCES people(personId),

    CONSTRAINT FK_predictions_currency
        FOREIGN KEY(currencyId)
        REFERENCES currencies(currencyId),

    CONSTRAINT FK_predictions_exchangeRate
        FOREIGN KEY(exchangeRateId)
        REFERENCES exchangeRates(exchangeRateId)
);
GO

CREATE TABLE reports(
    reportId INT IDENTITY(1,1) PRIMARY KEY,
    reportTypeId INT,
    reportedPersonId INT,
    reporterPersonId INT,
    propositionId INT,
    description VARCHAR(255),
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_reports_reportType
        FOREIGN KEY(reportTypeId)
        REFERENCES reportTypes(reportTypeId),

    CONSTRAINT FK_reports_reportedPerson
        FOREIGN KEY(reportedPersonId)
        REFERENCES people(personId),

    CONSTRAINT FK_reports_reporterPerson
        FOREIGN KEY(reporterPersonId)
        REFERENCES people(personId),

    CONSTRAINT FK_reports_proposition
        FOREIGN KEY(propositionId)
        REFERENCES propositions(propositionId)
);
GO

CREATE TABLE penalties(
    penaltyId INT IDENTITY(1,1) PRIMARY KEY,
    penaltyTypeId INT,
    reportId INT,
    pointsAmount NUMERIC(16,2),
    reasonDescription VARCHAR(255),
    executedAt DATETIME2(3) DEFAULT GETDATE(),
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_penalties_penaltyType
        FOREIGN KEY(penaltyTypeId)
        REFERENCES penaltyTypes(penaltyTypeId),

    CONSTRAINT FK_penalties_report
        FOREIGN KEY(reportId)
        REFERENCES reports(reportId)
);
GO

CREATE TABLE walletBalances(
    walletBalanceId INT IDENTITY(1,1) PRIMARY KEY,
    walletId INT,
    statusTypeId INT,
    oldPointsAmount NUMERIC(16,2),
    balancePointsAmount NUMERIC(16,2),
    newPointsAmount NUMERIC(16,2),
    calculatedAt DATETIME2(3) DEFAULT GETDATE(),
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_walletBalances_wallet
        FOREIGN KEY(walletId)
        REFERENCES wallets(walletId),

    CONSTRAINT FK_walletBalances_statusType
        FOREIGN KEY(statusTypeId)
        REFERENCES statusTypes(statusTypeId)
);
GO

CREATE TABLE walletTransactions(
    walletTransactionId INT IDENTITY(1,1) PRIMARY KEY,
    originWalletId INT,
    destinationWalletId INT,
    isSelfTransaction BIT DEFAULT 0,
    pointsAmount NUMERIC(16,2),
    transactionDateTime DATETIME2(3) DEFAULT GETDATE(),
    referenceTypeId INT,
    referenceId INT,
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_walletTransactions_originWallet
        FOREIGN KEY(originWalletId)
        REFERENCES wallets(walletId),

    CONSTRAINT FK_walletTransactions_destinationWallet
        FOREIGN KEY(destinationWalletId)
        REFERENCES wallets(walletId),

    CONSTRAINT FK_walletTransactions_referenceType
        FOREIGN KEY(referenceTypeId)
        REFERENCES referenceTypes(referenceTypeId)
);
GO

CREATE TABLE transactionTypes(
    transactionTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(40),
    description VARCHAR(120),
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0
);
GO

CREATE TABLE transactionAttempts(
    transactionAttemptId INT IDENTITY(1,1) PRIMARY KEY,
    transactionTypeId INT,
    personId INT,
    paymentMethodId INT,
    istransactionLoaded BIT DEFAULT 0,
    amount NUMERIC(16,2),
    currencyId INT,
    exchangeRateId INT,
    exchangedAmount NUMERIC(16,2),
    attemptedAt DATETIME2(3) DEFAULT GETDATE(),
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_transactionAttempts_transactionType
        FOREIGN KEY(transactionTypeId)
        REFERENCES transactionTypes(transactionTypeId),

    CONSTRAINT FK_transactionAttempts_person
        FOREIGN KEY(personId)
        REFERENCES people(personId),

    CONSTRAINT FK_transactionAttempts_paymentMethod
        FOREIGN KEY(paymentMethodId)
        REFERENCES paymentMethods(paymentMethodId),

    CONSTRAINT FK_transactionAttempts_currency
        FOREIGN KEY(currencyId)
        REFERENCES currencies(currencyId),

    CONSTRAINT FK_transactionAttempts_exchangeRate
        FOREIGN KEY(exchangeRateId)
        REFERENCES exchangeRates(exchangeRateId)
);
GO

CREATE TABLE transactions(
    transactionId INT IDENTITY(1,1) PRIMARY KEY,
    transactionAttemptId INT,
    personId INT,
    transactionTypeId INT,
    paymentMethodId INT,
    amount NUMERIC(16,2),
    currencyId INT,
    exchangeRateId INT,
    exchangedAmount NUMERIC(16,2),
    processedAt DATETIME2(3) DEFAULT GETDATE(),
    referenceTypeId INT,
    referenceId INT,
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_transactions_attempt
        FOREIGN KEY(transactionAttemptId)
        REFERENCES transactionAttempts(transactionAttemptId),

    CONSTRAINT FK_transactions_person
        FOREIGN KEY(personId)
        REFERENCES people(personId),

    CONSTRAINT FK_transactions_transactionType
        FOREIGN KEY(transactionTypeId)
        REFERENCES transactionTypes(transactionTypeId),

    CONSTRAINT FK_transactions_paymentMethod
        FOREIGN KEY(paymentMethodId)
        REFERENCES paymentMethods(paymentMethodId),

    CONSTRAINT FK_transactions_currency
        FOREIGN KEY(currencyId)
        REFERENCES currencies(currencyId),

    CONSTRAINT FK_transactions_exchangeRate
        FOREIGN KEY(exchangeRateId)
        REFERENCES exchangeRates(exchangeRateId),

    CONSTRAINT FK_transactions_referenceType
        FOREIGN KEY(referenceTypeId)
        REFERENCES referenceTypes(referenceTypeId)
);
GO

CREATE TABLE financialMovements(
    movementId INT IDENTITY(1,1) PRIMARY KEY,
    transactionTypeId INT,
    amount NUMERIC(14,2),
    currencyId INT,
    exchangeRateId INT,
    exchangedAmount NUMERIC(14,2),
    referenceTypeId INT,
    referenceId INT,
    description VARCHAR(120),
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_financialMovements_transactionType
        FOREIGN KEY(transactionTypeId)
        REFERENCES transactionTypes(transactionTypeId),

    CONSTRAINT FK_financialMovements_currency
        FOREIGN KEY(currencyId)
        REFERENCES currencies(currencyId),

    CONSTRAINT FK_financialMovements_exchangeRate
        FOREIGN KEY(exchangeRateId)
        REFERENCES exchangeRates(exchangeRateId),

    CONSTRAINT FK_financialMovements_referenceType
        FOREIGN KEY(referenceTypeId)
        REFERENCES referenceTypes(referenceTypeId)
);
GO

CREATE TABLE financialBalancesHistory(
    balanceId INT IDENTITY(1,1) PRIMARY KEY,
    totalBalance NUMERIC(16,2),
    calculatedAt DATETIME2(3) DEFAULT GETDATE(),
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0
);
GO

CREATE TABLE commissions(
    commissionId INT IDENTITY(1,1) PRIMARY KEY,
    commissionTypeId INT,
    referenceTypeId INT,
    referenceId INT,
    sourceWalletTransactionId INT,
    financialMovementId INT,
    appliedAmount NUMERIC(16,2),
    percentage NUMERIC(5,2),
    commissionAmount NUMERIC(16,2),
    executedAt DATETIME2(3) DEFAULT GETDATE(),
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_commissions_commissionType
        FOREIGN KEY(commissionTypeId)
        REFERENCES commissionTypes(commissionTypeId),

    CONSTRAINT FK_commissions_referenceType
        FOREIGN KEY(referenceTypeId)
        REFERENCES referenceTypes(referenceTypeId),

    CONSTRAINT FK_commissions_walletTransaction
        FOREIGN KEY(sourceWalletTransactionId)
        REFERENCES walletTransactions(walletTransactionId),

    CONSTRAINT FK_commissions_financialMovement
        FOREIGN KEY(financialMovementId)
        REFERENCES financialMovements(movementId)
);
GO

CREATE TABLE notificationTypes(
    notificationTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(40) UNIQUE,
    description VARCHAR(120),
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0
);
GO

CREATE TABLE notifications(
    notificationId INT IDENTITY(1,1) PRIMARY KEY,
    notificationTypeId INT,
    personId INT,
    title VARCHAR(120),
    message VARCHAR(255),
    isRead BIT,
    readAt DATETIME2(3) DEFAULT GETDATE(),
    referenceTypeId INT,
    referenceId INT,
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_notifications_notificationType
        FOREIGN KEY(notificationTypeId)
        REFERENCES notificationTypes(notificationTypeId),

    CONSTRAINT FK_notifications_person
        FOREIGN KEY(personId)
        REFERENCES people(personId),

    CONSTRAINT FK_notifications_referenceType
        FOREIGN KEY(referenceTypeId)
        REFERENCES referenceTypes(referenceTypeId)
);
GO

CREATE TABLE statusHistory(
    statusHistoryId INT IDENTITY(1,1) PRIMARY KEY,
    referenceTypeId INT,
    referenceId INT,
    statusTypeId INT,
    changedAt DATETIME2(3) DEFAULT GETDATE(),
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_statusHistory_referenceType
        FOREIGN KEY(referenceTypeId)
        REFERENCES referenceTypes(referenceTypeId),

    CONSTRAINT FK_statusHistory_statusType
        FOREIGN KEY(statusTypeId)
        REFERENCES statusTypes(statusTypeId)
);
GO

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

CREATE TABLE predictionPayouts(
    predictionPayoutId INT IDENTITY(1,1) PRIMARY KEY,
    predictionId INT,
    walletTransactionId INT,
    moneyPayoutAmount NUMERIC(8,2),
    pointsPayoutAmount NUMERIC(8,2),
    commissionAmount NUMERIC(8,2),
    executedAt DATETIME2(3) DEFAULT GETDATE(),
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_predictionPayouts_prediction
        FOREIGN KEY(predictionId)
        REFERENCES predictions(predictionId),

    CONSTRAINT FK_predictionPayouts_walletTransaction
        FOREIGN KEY(walletTransactionId)
        REFERENCES walletTransactions(walletTransactionId)
);
GO

CREATE TABLE walletReservations(
    walletReservationId INT IDENTITY(1,1) PRIMARY KEY,
    walletId INT,
    predictionId INT,
    reservedPointsAmount NUMERIC(16,2),
    reservedMoneyAmount NUMERIC(16,2),
    statusTypeId INT,
    reservedAt DATETIME2(3) DEFAULT GETDATE(),
    releasedAt DATETIME2(3) NULL,
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_walletReservations_wallet
        FOREIGN KEY(walletId)
        REFERENCES wallets(walletId),

    CONSTRAINT FK_walletReservations_prediction
        FOREIGN KEY(predictionId)
        REFERENCES predictions(predictionId),

    CONSTRAINT FK_walletReservations_statusType
        FOREIGN KEY(statusTypeId)
        REFERENCES statusTypes(statusTypeId)
);
GO

CREATE TABLE aiValidationResults(
    validationId INT IDENTITY(1,1) PRIMARY KEY,
    propositionId INT,
    statusTypeId INT,
    aiComments VARCHAR(500),
    auditPersonId INT,
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_aiValidationResults_proposition
        FOREIGN KEY(propositionId)
        REFERENCES propositions(propositionId),

    CONSTRAINT FK_aiValidationResults_statusType
        FOREIGN KEY(statusTypeId)
        REFERENCES statusTypes(statusTypeId)
);
GO

CREATE TABLE securityEventTypes(
    securityEventTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(50) UNIQUE,
    description VARCHAR(200),
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0
);
GO

CREATE TABLE securityEvents(
    securityEventId INT IDENTITY(1,1) PRIMARY KEY,
    securityEventTypeId INT,
    personId INT,
    authSessionId INT,
    eventDateTime DATETIME2(3) DEFAULT GETDATE(),
    details VARCHAR(500),
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_securityEvents_type
        FOREIGN KEY(securityEventTypeId)
        REFERENCES securityEventTypes(securityEventTypeId),

    CONSTRAINT FK_securityEvents_person
        FOREIGN KEY(personId)
        REFERENCES people(personId),

    CONSTRAINT FK_securityEvents_authSession
        FOREIGN KEY(authSessionId)
        REFERENCES authSessions(authSessionId)
);
GO

CREATE TABLE permissionTypes(
    permissionTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(20),
    description VARCHAR(100),
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0
);
GO

CREATE TABLE permissions(
    permissionId INT IDENTITY(1,1) PRIMARY KEY,

    permissionTypeId INT NOT NULL,
    referenceTypeId INT NOT NULL,

    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_permissions_permissionTypes
        FOREIGN KEY(permissionTypeId)
        REFERENCES permissionTypes(permissionTypeId),

    CONSTRAINT FK_permissions_referenceTypes
        FOREIGN KEY(referenceTypeId)
        REFERENCES referenceTypes(referenceTypeId),

    CONSTRAINT UQ_permissions
        UNIQUE(permissionTypeId, referenceTypeId)
);
GO

CREATE TABLE rolePermissions(
    rolePermissionId INT IDENTITY(1,1) PRIMARY KEY,

    peopleTypeId INT NOT NULL,
    permissionId INT NOT NULL,

    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_rolePermissions_peopleTypes
        FOREIGN KEY(peopleTypeId)
        REFERENCES peopleTypes(peopleTypeId),

    CONSTRAINT FK_rolePermissions_permissions
        FOREIGN KEY(permissionId)
        REFERENCES permissions(permissionId),

    CONSTRAINT UQ_rolePermissions
        UNIQUE(peopleTypeId, permissionId)
);
GO

CREATE TABLE peoplePermissions(
    peoplePermissionId INT IDENTITY(1,1) PRIMARY KEY,

    personId INT NOT NULL,
    permissionId INT NOT NULL,

    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_peoplePermissions_people
        FOREIGN KEY(personId)
        REFERENCES people(personId),

    CONSTRAINT FK_peoplePermissions_permissions
        FOREIGN KEY(permissionId)
        REFERENCES permissions(permissionId),

    CONSTRAINT UQ_peoplePermissions
        UNIQUE(personId, permissionId)
);
GO

/* CATÁLOGOS */

ALTER TABLE reportTypes
ADD CONSTRAINT FK_reportTypes_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE currencies
ADD CONSTRAINT FK_currencies_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE referenceTypes
ADD CONSTRAINT FK_referenceTypes_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE paymentMethods
ADD CONSTRAINT FK_paymentMethods_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE commissionTypes
ADD CONSTRAINT FK_commissionTypes_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE statusTypes
ADD CONSTRAINT FK_statusTypes_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE penaltyTypes
ADD CONSTRAINT FK_penaltyTypes_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE socialPlatforms
ADD CONSTRAINT FK_socialPlatforms_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

/************ SOCIALES ************/

ALTER TABLE socialAccounts
ADD CONSTRAINT FK_socialAccounts_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE wallets
ADD CONSTRAINT FK_wallets_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE authSessions
ADD CONSTRAINT FK_authSessions_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

/************ PROPOSICIONES ************/

ALTER TABLE exchangeRates
ADD CONSTRAINT FK_exchangeRates_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE propositions
ADD CONSTRAINT FK_propositions_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE propositionVotes
ADD CONSTRAINT FK_propositionVotes_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE propositionLikes
ADD CONSTRAINT FK_propositionLikes_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE propositionComments
ADD CONSTRAINT FK_propositionComments_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

/************ FILES ************/

ALTER TABLE fileTypes
ADD CONSTRAINT FK_fileTypes_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE files
ADD CONSTRAINT FK_files_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE fileUsageTypes
ADD CONSTRAINT FK_fileUsageTypes_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE fileReferences
ADD CONSTRAINT FK_fileReferences_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

/************ FINANCIERO ************/

ALTER TABLE predictions
ADD CONSTRAINT FK_predictions_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE reports
ADD CONSTRAINT FK_reports_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE penalties
ADD CONSTRAINT FK_penalties_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE walletBalances
ADD CONSTRAINT FK_walletBalances_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE walletTransactions
ADD CONSTRAINT FK_walletTransactions_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE transactionTypes
ADD CONSTRAINT FK_transactionTypes_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE transactionAttempts
ADD CONSTRAINT FK_transactionAttempts_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE transactions
ADD CONSTRAINT FK_transactions_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE financialMovements
ADD CONSTRAINT FK_financialMovements_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE financialBalancesHistory
ADD CONSTRAINT FK_financialBalancesHistory_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE commissions
ADD CONSTRAINT FK_commissions_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

/************ SISTEMA ************/

ALTER TABLE notificationTypes
ADD CONSTRAINT FK_notificationTypes_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE notifications
ADD CONSTRAINT FK_notifications_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE statusHistory
ADD CONSTRAINT FK_statusHistory_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE walletReservations
ADD CONSTRAINT FK_walletReservations_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

ALTER TABLE aiValidationResults
ADD CONSTRAINT FK_aiValidationResults_auditPerson
FOREIGN KEY (auditPersonId) REFERENCES people(personId);
GO

/* ============================================================
   UBICACIÓN
============================================================ */

CREATE INDEX IX_states_countryId
ON states(countryId);
GO

CREATE INDEX IX_cities_stateId
ON cities(stateId);
GO

CREATE INDEX IX_addresses_cityId
ON addresses(cityId);
GO

/* ============================================================
   PEOPLE
============================================================ */

CREATE INDEX IX_people_peopleTypeId
ON people(peopleTypeId);
GO

CREATE INDEX IX_people_addressId
ON people(addressId);
GO

CREATE INDEX IX_people_isActive
ON people(isActive);
GO

CREATE INDEX IX_people_isVerified
ON people(isVerified);
GO

/* ============================================================
   SOCIAL
============================================================ */

CREATE INDEX IX_socialAccounts_personId
ON socialAccounts(personId);
GO

CREATE INDEX IX_socialAccounts_platformId
ON socialAccounts(socialPlatformId);
GO

/* ============================================================
   AUTH
============================================================ */

CREATE INDEX IX_authSessions_personId
ON authSessions(personId);
GO

CREATE INDEX IX_authSessions_expiresAt
ON authSessions(expiresAt);
GO

CREATE INDEX IX_authSessions_isRevoked
ON authSessions(isRevoked);
GO

/* ============================================================
   EXCHANGE RATES
============================================================ */

CREATE INDEX IX_exchangeRates_currencyId
ON exchangeRates(currencyId);
GO

CREATE INDEX IX_exchangeRates_isCurrent
ON exchangeRates(isCurrent);
GO

CREATE INDEX IX_exchangeRates_exchangeDateTime
ON exchangeRates(exchangeDateTime);
GO

/* ============================================================
   PROPOSITIONS
============================================================ */

CREATE INDEX IX_propositions_statusTypesId
ON propositions(statusTypesId);
GO

CREATE INDEX IX_propositions_creatorPersonId
ON propositions(creatorPersonId);
GO

CREATE INDEX IX_propositions_targetPersonId
ON propositions(targetPersonId);
GO

CREATE INDEX IX_propositions_targetSocialAccountId
ON propositions(targetSocialAccountId);
GO

CREATE INDEX IX_propositions_parentProposition
ON propositions(parentProposition);
GO

CREATE INDEX IX_propositions_startPredictionDateTime
ON propositions(startPredictionDateTime);
GO

CREATE INDEX IX_propositions_endPredictionDateTime
ON propositions(endPredictionDateTime);
GO

/* ============================================================
   INTERACCIÓN
============================================================ */

CREATE INDEX IX_propositionVotes_personId
ON propositionVotes(personId);
GO

CREATE INDEX IX_propositionLikes_personId
ON propositionLikes(personId);
GO

CREATE INDEX IX_propositionComments_propositionId
ON propositionComments(propositionId);
GO

CREATE INDEX IX_propositionComments_personId
ON propositionComments(personId);
GO

/* ============================================================
   FILES
============================================================ */

CREATE INDEX IX_files_fileTypeId
ON files(fileTypeId);
GO

CREATE INDEX IX_files_uploadedByPersonId
ON files(uploadedByPersonId);
GO

CREATE INDEX IX_fileReferences_fileId
ON fileReferences(fileId);
GO

CREATE INDEX IX_fileReferences_referenceTypeId
ON fileReferences(referenceTypeId);
GO

CREATE INDEX IX_fileReferences_referenceId
ON fileReferences(referenceId);
GO

CREATE INDEX IX_fileReferences_usageTypeId
ON fileReferences(fileUsageTypeId);
GO

/**************************************************************
 PREDICTIONS
**************************************************************/

CREATE INDEX IX_predictions_propositionId
ON predictions(propositionId);
GO

CREATE INDEX IX_predictions_personId
ON predictions(personId);
GO

CREATE INDEX IX_predictions_statusTypesId
ON predictions(statusTypesId);
GO

CREATE INDEX IX_predictions_currencyId
ON predictions(currencyId);
GO

CREATE INDEX IX_predictions_predictionDateTime
ON predictions(predictionDateTime);
GO

/**************************************************************
 REPORTS
**************************************************************/

CREATE INDEX IX_reports_reportTypeId
ON reports(reportTypeId);
GO

CREATE INDEX IX_reports_reportedPersonId
ON reports(reportedPersonId);
GO

CREATE INDEX IX_reports_reporterPersonId
ON reports(reporterPersonId);
GO

CREATE INDEX IX_reports_propositionId
ON reports(propositionId);
GO

/**************************************************************
 PENALTIES
**************************************************************/

CREATE INDEX IX_penalties_penaltyTypeId
ON penalties(penaltyTypeId);
GO

CREATE INDEX IX_penalties_reportId
ON penalties(reportId);
GO

/**************************************************************
 WALLETS
**************************************************************/

CREATE INDEX IX_wallets_personId
ON wallets(personId);
GO

CREATE INDEX IX_walletBalances_walletId
ON walletBalances(walletId);
GO

CREATE INDEX IX_walletBalances_statusTypeId
ON walletBalances(statusTypeId);
GO

CREATE INDEX IX_walletTransactions_originWalletId
ON walletTransactions(originWalletId);
GO

CREATE INDEX IX_walletTransactions_destinationWalletId
ON walletTransactions(destinationWalletId);
GO

CREATE INDEX IX_walletTransactions_referenceTypeId
ON walletTransactions(referenceTypeId);
GO

CREATE INDEX IX_walletTransactions_transactionDateTime
ON walletTransactions(transactionDateTime);
GO

/**************************************************************
 TRANSACTIONS
**************************************************************/

CREATE INDEX IX_transactionAttempts_personId
ON transactionAttempts(personId);
GO

CREATE INDEX IX_transactionAttempts_paymentMethodId
ON transactionAttempts(paymentMethodId);
GO

CREATE INDEX IX_transactionAttempts_transactionTypeId
ON transactionAttempts(transactionTypeId);
GO

CREATE INDEX IX_transactions_attemptId
ON transactions(transactionAttemptId);
GO

CREATE INDEX IX_transactions_personId
ON transactions(personId);
GO

CREATE INDEX IX_transactions_paymentMethodId
ON transactions(paymentMethodId);
GO

CREATE INDEX IX_transactions_transactionTypeId
ON transactions(transactionTypeId);
GO

CREATE INDEX IX_transactions_referenceTypeId
ON transactions(referenceTypeId);
GO

/**************************************************************
 FINANCIAL
**************************************************************/

CREATE INDEX IX_financialMovements_transactionTypeId
ON financialMovements(transactionTypeId);
GO

CREATE INDEX IX_financialMovements_referenceTypeId
ON financialMovements(referenceTypeId);
GO

CREATE INDEX IX_commissions_walletTransactionId
ON commissions(sourceWalletTransactionId);
GO

CREATE INDEX IX_commissions_financialMovementId
ON commissions(financialMovementId);
GO

/**************************************************************
 NOTIFICATIONS
**************************************************************/

CREATE INDEX IX_notifications_personId
ON notifications(personId);
GO

CREATE INDEX IX_notifications_notificationTypeId
ON notifications(notificationTypeId);
GO

CREATE INDEX IX_notifications_isRead
ON notifications(isRead);
GO

/**************************************************************
 STATUS HISTORY
**************************************************************/

CREATE INDEX IX_statusHistory_referenceTypeId
ON statusHistory(referenceTypeId);
GO

CREATE INDEX IX_statusHistory_referenceId
ON statusHistory(referenceId);
GO

CREATE INDEX IX_statusHistory_statusTypeId
ON statusHistory(statusTypeId);
GO

/**************************************************************
 AUDIT
**************************************************************/

CREATE INDEX IX_auditLogs_personId
ON auditLogs(personId);
GO

CREATE INDEX IX_auditLogs_referenceId
ON auditLogs(referenceTypeId, referenceId);
GO

CREATE INDEX IX_auditLogs_actionTimestamp
ON auditLogs(actionTimestamp);
GO


/**************************************************************
 PAYOUTS
**************************************************************/

CREATE INDEX IX_predictionPayouts_predictionId
ON predictionPayouts(predictionId);
GO

CREATE INDEX IX_predictionPayouts_walletTransactionId
ON predictionPayouts(walletTransactionId);
GO

/**************************************************************
 RESERVATIONS
**************************************************************/

CREATE INDEX IX_walletReservations_walletId
ON walletReservations(walletId);
GO

CREATE INDEX IX_walletReservations_predictionId
ON walletReservations(predictionId);
GO

CREATE INDEX IX_walletReservations_statusTypeId
ON walletReservations(statusTypeId);
GO

/**************************************************************
 AI
**************************************************************/

CREATE INDEX IX_aiValidationResults_propositionId
ON aiValidationResults(propositionId);
GO

CREATE INDEX IX_aiValidationResults_statusTypeId
ON aiValidationResults(statusTypeId);
GO

/**************************************************************
 SECURITY
**************************************************************/

CREATE INDEX IX_securityEvents_personId
ON securityEvents(personId);
GO

CREATE INDEX IX_securityEvents_authSessionId
ON securityEvents(authSessionId);
GO

CREATE INDEX IX_securityEvents_typeId
ON securityEvents(securityEventTypeId);
GO

CREATE INDEX IX_securityEvents_eventDateTime
ON securityEvents(eventDateTime);
GO