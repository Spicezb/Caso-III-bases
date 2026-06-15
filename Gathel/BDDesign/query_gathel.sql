CREATE DATABASE Gathel;
GO

USE Gathel;
GO

/* ========================================================
   TABLE: peopleTypes
======================================================== */
CREATE TABLE peopleTypes (
    peopleTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(30),
    description VARCHAR(100),
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT
);
GO
CREATE INDEX IX_peopleTypes_isDeleted ON peopleTypes(isDeleted);
GO

/* ========================================================
   TABLE: roles
======================================================== */
CREATE TABLE roles (
    roleId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(50) UNIQUE,
    description VARCHAR(150),
    isSystemRole BIT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT
);
GO
CREATE UNIQUE INDEX UX_roles_name ON roles(name);
GO

/* ========================================================
   TABLE: permissions
======================================================== */
CREATE TABLE permissions (
    permissionId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(80) UNIQUE,
    description VARCHAR(200),
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT
);
GO
CREATE UNIQUE INDEX UX_permissions_name ON permissions(name);
GO

/* ========================================================
   TABLE: countries
======================================================== */
CREATE TABLE countries (
    countryId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(80),
    isoCode VARCHAR(5) UNIQUE,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT
);
GO
CREATE INDEX IX_countries_isDeleted ON countries(isDeleted);
GO

/* ========================================================
   TABLE: notificationTypes
======================================================== */
CREATE TABLE notificationTypes (
    notificationTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(40),
    description VARCHAR(120),
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT
);
GO

/* ========================================================
   TABLE: evidenceTypes
======================================================== */
CREATE TABLE evidenceTypes (
    evidenceTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(40),
    description VARCHAR(120),
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT
);
GO

/* ========================================================
   TABLE: propositionResultTypes
======================================================== */
CREATE TABLE propositionResultTypes (
    propositionResultTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(40),
    description VARCHAR(120),
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT
);
GO

/* ========================================================
   TABLE: aiModerationStatuses
======================================================== */
CREATE TABLE aiModerationStatuses (
    aiModerationStatusId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(40),
    description VARCHAR(120),
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT
);
GO

/* ========================================================
   TABLE: propositionEventTypes
======================================================== */
CREATE TABLE propositionEventTypes (
    propositionEventTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(40),
    description VARCHAR(120),
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT
);
GO

/* ========================================================
   TABLE: processingStatuses
======================================================== */
CREATE TABLE processingStatuses (
    processingStatusId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(40),
    description VARCHAR(120),
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT
);
GO

/* ========================================================
   TABLE: cities
======================================================== */
CREATE TABLE cities (
    cityId INT IDENTITY(1,1) PRIMARY KEY,
    countryId INT,
    name VARCHAR(80),
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,
    CONSTRAINT UQ_cities_country_name UNIQUE(countryId, name),
    CONSTRAINT FK_cities_country FOREIGN KEY(countryId)
        REFERENCES countries(countryId)
);
GO
CREATE INDEX IX_cities_countryId ON cities(countryId);
GO

/* ========================================================
   TABLE: addresses
======================================================== */
CREATE TABLE addresses (
    addressId INT IDENTITY(1,1) PRIMARY KEY,
    cityId INT,
    exactAddress VARCHAR(200),
    isSensitive BIT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,
    CONSTRAINT FK_addresses_city FOREIGN KEY(cityId)
        REFERENCES cities(cityId)
);
GO
CREATE INDEX IX_addresses_cityId ON addresses(cityId);
GO

/* ========================================================
   TABLE: people
======================================================== */
CREATE TABLE people (
    personId INT IDENTITY(1,1) PRIMARY KEY,
    personTypeId INT,
    name VARCHAR(60),
    lastName VARCHAR(60),
    identification VARCHAR(30) UNIQUE,
    phone VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    passwordHash VARBINARY(512),
    passwordSalt VARBINARY(256),
    passwordAlgorithm VARCHAR(40),
    passwordChangedAt DATETIME2,
    failedLoginAttempts INT,
    lockedUntil DATETIME2,
    username VARCHAR(40) UNIQUE,
    profilePhotoUrl VARCHAR(255),
    biography VARCHAR(200),
    birthDate DATE,
    addressId INT,
    isVerified BIT,
    isActive BIT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,
    CONSTRAINT FK_people_peopleTypes FOREIGN KEY(personTypeId)
        REFERENCES peopleTypes(peopleTypeId),
    CONSTRAINT FK_people_addresses FOREIGN KEY(addressId)
        REFERENCES addresses(addressId)
);
GO
CREATE UNIQUE INDEX UX_people_email ON people(email);
CREATE UNIQUE INDEX UX_people_username ON people(username);
CREATE INDEX IX_people_personTypeId ON people(personTypeId);
CREATE INDEX IX_people_addressId ON people(addressId);
CREATE INDEX IX_people_isActive_isDeleted ON people(isActive, isDeleted);
GO

/* ========================================================
   TABLE: propositionStatuses
======================================================== */
CREATE TABLE propositionStatuses (
    propositionStatusId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(40),
    description VARCHAR(120),
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_propositionStatuses_people
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_propositionStatuses_auditpersonId
ON propositionStatuses(auditpersonId);
GO

/* ========================================================
   TABLE: predictionStatuses
======================================================== */
CREATE TABLE predictionStatuses (
    predictionStatusId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(40),
    description VARCHAR(120),
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_predictionStatuses_people
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_predictionStatuses_auditpersonId
ON predictionStatuses(auditpersonId);
GO

/* ========================================================
   TABLE: reportTypes
======================================================== */
CREATE TABLE reportTypes (
    reportTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(40),
    description VARCHAR(120),
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_reportTypes_people
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_reportTypes_auditpersonId
ON reportTypes(auditpersonId);
GO

/* ========================================================
   TABLE: currencies
======================================================== */
CREATE TABLE currencies (
    currencyId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(30),
    code VARCHAR(10),
    symbol VARCHAR(10),
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_currencies_people
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE UNIQUE INDEX UX_currencies_code
ON currencies(code);
GO

CREATE INDEX IX_currencies_auditpersonId
ON currencies(auditpersonId);
GO

/* ========================================================
   TABLE: referenceTypes
======================================================== */
CREATE TABLE referenceTypes (
    referenceTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(30),
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_referenceTypes_people
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_referenceTypes_auditpersonId
ON referenceTypes(auditpersonId);
GO

/* ========================================================
   TABLE: walletTransactionTypes
======================================================== */
CREATE TABLE walletTransactionTypes (
    walletTransactionTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(40),
    description VARCHAR(120),
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_walletTransactionTypes_people
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_walletTransactionTypes_auditpersonId
ON walletTransactionTypes(auditpersonId);
GO

/* ========================================================
   TABLE: paymentMethods
======================================================== */
CREATE TABLE paymentMethods (
    paymentMethodId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(30),
    logoUrl VARCHAR(255),
    publicConfig NVARCHAR(MAX),
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_paymentMethods_people
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_paymentMethods_auditpersonId
ON paymentMethods(auditpersonId);
GO

/* ========================================================
   TABLE: paymentMethodSecrets
======================================================== */
CREATE TABLE paymentMethodSecrets (
    paymentMethodSecretId BIGINT IDENTITY(1,1) PRIMARY KEY,
    paymentMethodId INT,
    encryptedSecret VARBINARY(MAX),
    encryptionKeyVersion VARCHAR(30),
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_paymentMethodSecrets_paymentMethods
        FOREIGN KEY(paymentMethodId)
        REFERENCES paymentMethods(paymentMethodId)
);
GO

CREATE INDEX IX_paymentMethodSecrets_paymentMethodId
ON paymentMethodSecrets(paymentMethodId);
GO

/* ========================================================
   TABLE: financialTransactionTypes
======================================================== */
CREATE TABLE financialTransactionTypes (
    transactionTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(30),
    description VARCHAR(80),
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_financialTransactionTypes_people
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_financialTransactionTypes_auditpersonId
ON financialTransactionTypes(auditpersonId);
GO

/* ========================================================
   TABLE: commissionTypes
======================================================== */
CREATE TABLE commissionTypes (
    commissionTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(40),
    description VARCHAR(120),
    percentage DECIMAL(5,2)
        CHECK (percentage BETWEEN 0 AND 100),
    isActive BIT,
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_commissionTypes_people
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_commissionTypes_isActive
ON commissionTypes(isActive);
GO

/* ========================================================
   TABLE: withdrawalRequestStatuses
======================================================== */
CREATE TABLE withdrawalRequestStatuses (
    withdrawalRequestStatusId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(40),
    description VARCHAR(120),
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_withdrawalRequestStatuses_people
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_withdrawalRequestStatuses_auditpersonId
ON withdrawalRequestStatuses(auditpersonId);
GO

/* ========================================================
   TABLE: penaltyTypes
======================================================== */
CREATE TABLE penaltyTypes (
    penaltyTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(40),
    description VARCHAR(120),
    pointsPercentage DECIMAL(5,2)
        CHECK (pointsPercentage BETWEEN 0 AND 100),
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_penaltyTypes_people
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_penaltyTypes_auditpersonId
ON penaltyTypes(auditpersonId);
GO

/* ========================================================
   TABLE: socialPlatforms
======================================================== */
CREATE TABLE socialPlatforms (
    socialPlatformId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(40),
    apiUrl VARCHAR(255),
    logoUrl VARCHAR(255),
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_socialPlatforms_people
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE UNIQUE INDEX UX_socialPlatforms_name
ON socialPlatforms(name);
GO

/* ========================================================
   TABLE: rolePermissions
======================================================== */
CREATE TABLE rolePermissions (
    rolePermissionId BIGINT IDENTITY(1,1) PRIMARY KEY,
    roleId INT,
    permissionId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT UQ_rolePermissions UNIQUE(roleId, permissionId),

    CONSTRAINT FK_rolePermissions_roles
        FOREIGN KEY(roleId)
        REFERENCES roles(roleId),

    CONSTRAINT FK_rolePermissions_permissions
        FOREIGN KEY(permissionId)
        REFERENCES permissions(permissionId)
);
GO

CREATE INDEX IX_rolePermissions_roleId
ON rolePermissions(roleId);
GO

CREATE INDEX IX_rolePermissions_permissionId
ON rolePermissions(permissionId);
GO

/* ========================================================
   TABLE: personRoles
======================================================== */
CREATE TABLE personRoles (
    personRoleId BIGINT IDENTITY(1,1) PRIMARY KEY,
    personId INT,
    roleId INT,
    assignedAt DATETIME2,
    assignedByPersonId INT,
    expiresAt DATETIME2,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT UQ_personRoles UNIQUE(personId, roleId),

    CONSTRAINT FK_personRoles_people
        FOREIGN KEY(personId)
        REFERENCES people(personId),

    CONSTRAINT FK_personRoles_roles
        FOREIGN KEY(roleId)
        REFERENCES roles(roleId),

    CONSTRAINT FK_personRoles_assignedBy
        FOREIGN KEY(assignedByPersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_personRoles_personId
ON personRoles(personId);
GO

CREATE INDEX IX_personRoles_roleId
ON personRoles(roleId);
GO

/* ========================================================
   TABLE: socialAccounts
======================================================== */
CREATE TABLE socialAccounts (
    socialAccountId INT IDENTITY(1,1) PRIMARY KEY,
    personId INT,
    socialPlatformId INT,
    username VARCHAR(80),
    profileUrl VARCHAR(255),
    isVerified BIT,
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT UQ_socialAccounts
        UNIQUE(personId, socialPlatformId, username),

    CONSTRAINT FK_socialAccounts_people
        FOREIGN KEY(personId)
        REFERENCES people(personId),

    CONSTRAINT FK_socialAccounts_socialPlatforms
        FOREIGN KEY(socialPlatformId)
        REFERENCES socialPlatforms(socialPlatformId),

    CONSTRAINT FK_socialAccounts_auditPeople
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_socialAccounts_personId
ON socialAccounts(personId);
GO

CREATE INDEX IX_socialAccounts_socialPlatformId
ON socialAccounts(socialPlatformId);
GO

/* ========================================================
   TABLE: socialAccountSecrets
======================================================== */
CREATE TABLE socialAccountSecrets (
    socialAccountSecretId BIGINT IDENTITY(1,1) PRIMARY KEY,
    socialAccountId INT,
    encryptedAccessToken VARBINARY(MAX),
    encryptedRefreshToken VARBINARY(MAX),
    tokenScope VARCHAR(255),
    tokenExpiresAt DATETIME2,
    encryptionKeyVersion VARCHAR(30),
    isRevoked BIT,
    revokedAt DATETIME2,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_socialAccountSecrets_socialAccounts
        FOREIGN KEY(socialAccountId)
        REFERENCES socialAccounts(socialAccountId)
);
GO

CREATE INDEX IX_socialAccountSecrets_socialAccountId
ON socialAccountSecrets(socialAccountId);
GO

/* ========================================================
   TABLE: wallets
======================================================== */
CREATE TABLE wallets (
    walletId INT IDENTITY(1,1) PRIMARY KEY,
    personId INT UNIQUE,
    availablePointsAmount DECIMAL(16,2)
        CHECK (availablePointsAmount >= 0),
    lockedPointsAmount DECIMAL(16,2)
        CHECK (lockedPointsAmount >= 0),
    isBlocked BIT,
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_wallets_people
        FOREIGN KEY(personId)
        REFERENCES people(personId),

    CONSTRAINT FK_wallets_auditPeople
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE UNIQUE INDEX UX_wallets_personId
ON wallets(personId);
GO

/* ========================================================
   TABLE: moneyWallets
======================================================== */
CREATE TABLE moneyWallets (
    moneyWalletId BIGINT IDENTITY(1,1) PRIMARY KEY,
    personId INT,
    currencyId INT,
    availableAmount DECIMAL(18,2)
        CHECK (availableAmount >= 0),
    lockedAmount DECIMAL(18,2)
        CHECK (lockedAmount >= 0),
    rowVersion ROWVERSION,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT UQ_moneyWallets
        UNIQUE(personId, currencyId),

    CONSTRAINT FK_moneyWallets_people
        FOREIGN KEY(personId)
        REFERENCES people(personId),

    CONSTRAINT FK_moneyWallets_currencies
        FOREIGN KEY(currencyId)
        REFERENCES currencies(currencyId)
);
GO

CREATE UNIQUE INDEX UX_moneyWallets_person_currency
ON moneyWallets(personId, currencyId);
GO

/* ========================================================
   TABLE: walletCurrentBalances
======================================================== */
CREATE TABLE walletCurrentBalances (
    walletCurrentBalanceId INT IDENTITY(1,1) PRIMARY KEY,
    walletId INT UNIQUE,
    currentPointsAmount DECIMAL(16,2),
    lockedPointsAmount DECIMAL(16,2),
    availablePointsAmount DECIMAL(16,2),
    lastTransactionDateTime DATETIME2,
    rowVersion ROWVERSION,
    previousHash VARBINARY(512),
    currentHash VARBINARY(512),
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_walletCurrentBalances_wallets
        FOREIGN KEY(walletId)
        REFERENCES wallets(walletId),

    CONSTRAINT FK_walletCurrentBalances_people
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE UNIQUE INDEX UX_walletCurrentBalances_walletId
ON walletCurrentBalances(walletId);
GO

/* ========================================================
   TABLE: authSessions
======================================================== */
CREATE TABLE authSessions (
    authSessionId INT IDENTITY(1,1) PRIMARY KEY,
    personId INT,
    ipAddress VARCHAR(100),
    userAgent VARCHAR(255),
    deviceFingerprint VARCHAR(255),
    mfaValidated BIT,
    sessionType VARCHAR(40),
    expiresAt DATETIME2,
    lastActivityAt DATETIME2,
    isRevoked BIT,
    revokedAt DATETIME2,
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_authSessions_people
        FOREIGN KEY(personId)
        REFERENCES people(personId),

    CONSTRAINT FK_authSessions_auditPeople
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_authSessions_personId_expiresAt
ON authSessions(personId, expiresAt DESC);
GO

CREATE INDEX IX_authSessions_isRevoked_expiresAt
ON authSessions(isRevoked, expiresAt);
GO

/* ========================================================
   TABLE: authSessionSecrets
======================================================== */
CREATE TABLE authSessionSecrets (
    authSessionSecretId BIGINT IDENTITY(1,1) PRIMARY KEY,
    authSessionId INT,
    encryptedRefreshToken VARBINARY(MAX),
    encryptionKeyVersion VARCHAR(30),
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_authSessionSecrets_authSessions
        FOREIGN KEY(authSessionId)
        REFERENCES authSessions(authSessionId)
);
GO

CREATE INDEX IX_authSessionSecrets_authSessionId
ON authSessionSecrets(authSessionId);
GO

/* ========================================================
   TABLE: loginAttempts
======================================================== */
CREATE TABLE loginAttempts (
    loginAttemptId BIGINT IDENTITY(1,1) PRIMARY KEY,
    personId INT,
    attemptedEmail VARCHAR(100),
    ipAddress VARCHAR(100),
    userAgent VARCHAR(255),
    wasSuccessful BIT,
    failureReason VARCHAR(120),
    attemptedAt DATETIME2,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_loginAttempts_people
        FOREIGN KEY(personId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_loginAttempts_personId_attemptedAt
ON loginAttempts(personId, attemptedAt DESC);
GO

CREATE INDEX IX_loginAttempts_ipAddress_attemptedAt
ON loginAttempts(ipAddress, attemptedAt DESC);
GO

/* ========================================================
   TABLE: securityEvents
======================================================== */
CREATE TABLE securityEvents (
    securityEventId BIGINT IDENTITY(1,1) PRIMARY KEY,
    personId INT,
    authSessionId INT,
    eventType VARCHAR(60),
    eventDescription VARCHAR(255),
    ipAddress VARCHAR(100),
    userAgent VARCHAR(255),
    correlationId VARCHAR(100),
    occurredAt DATETIME2,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_securityEvents_people
        FOREIGN KEY(personId)
        REFERENCES people(personId),

    CONSTRAINT FK_securityEvents_authSessions
        FOREIGN KEY(authSessionId)
        REFERENCES authSessions(authSessionId)
);
GO

CREATE INDEX IX_securityEvents_personId_occurredAt
ON securityEvents(personId, occurredAt DESC);
GO

/* ========================================================
   TABLE: mfaMethods
======================================================== */
CREATE TABLE mfaMethods (
    mfaMethodId BIGINT IDENTITY(1,1) PRIMARY KEY,
    personId INT,
    methodType VARCHAR(40),
    encryptedSecret VARBINARY(MAX),
    recoveryCodeHash VARBINARY(MAX),
    isPrimary BIT,
    isActive BIT,
    verifiedAt DATETIME2,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_mfaMethods_people
        FOREIGN KEY(personId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_mfaMethods_personId
ON mfaMethods(personId);
GO

/* ========================================================
   TABLE: exchangeRates
======================================================== */
CREATE TABLE exchangeRates (
    exchangeRateId INT IDENTITY(1,1) PRIMARY KEY,
    currencyId INT,
    rateToUsd DECIMAL(12,6)
        CHECK (rateToUsd > 0),
    isCurrent BIT,
    exchangeDateTime DATETIME2,
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_exchangeRates_currencies
        FOREIGN KEY(currencyId)
        REFERENCES currencies(currencyId),

    CONSTRAINT FK_exchangeRates_people
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_exchangeRates_currencyId_exchangeDateTime
ON exchangeRates(currencyId, exchangeDateTime DESC);
GO

/* ========================================================
   TABLE: propositions
======================================================== */
CREATE TABLE propositions (
    propositionId BIGINT IDENTITY(1,1) PRIMARY KEY,
    parentPropositionId BIGINT,
    propositionStatusId INT,
    propositionResultTypeId INT,
    aiModerationStatusId INT,
    creatorPersonId INT,
    targetPersonId INT,
    targetSocialAccountId INT,
    title VARCHAR(120),
    description VARCHAR(300),
    startPredictionDateTime DATETIME2,
    endPredictionDateTime DATETIME2,
    winningOption BIT,
    minimumEntryPointsAmount DECIMAL(16,2),
    winningProfitPercentage DECIMAL(5,2)
        CHECK (winningProfitPercentage BETWEEN 0 AND 100),
    resolvedByAI BIT,
    resolvedAt DATETIME2,
    isPublic BIT,
    processingStatusId INT,
    correlationId VARCHAR(100),
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_propositions_parent
        FOREIGN KEY(parentPropositionId)
        REFERENCES propositions(propositionId),

    CONSTRAINT FK_propositions_status
        FOREIGN KEY(propositionStatusId)
        REFERENCES propositionStatuses(propositionStatusId),

    CONSTRAINT FK_propositions_resultType
        FOREIGN KEY(propositionResultTypeId)
        REFERENCES propositionResultTypes(propositionResultTypeId),

    CONSTRAINT FK_propositions_aiModeration
        FOREIGN KEY(aiModerationStatusId)
        REFERENCES aiModerationStatuses(aiModerationStatusId),

    CONSTRAINT FK_propositions_creator
        FOREIGN KEY(creatorPersonId)
        REFERENCES people(personId),

    CONSTRAINT FK_propositions_targetPerson
        FOREIGN KEY(targetPersonId)
        REFERENCES people(personId),

    CONSTRAINT FK_propositions_targetSocialAccount
        FOREIGN KEY(targetSocialAccountId)
        REFERENCES socialAccounts(socialAccountId),

    CONSTRAINT FK_propositions_processingStatus
        FOREIGN KEY(processingStatusId)
        REFERENCES processingStatuses(processingStatusId),

    CONSTRAINT FK_propositions_auditPeople
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_propositions_status_endDate_createdAt
ON propositions(propositionStatusId, endPredictionDateTime, createdAt DESC);
GO

CREATE INDEX IX_propositions_creatorPersonId_createdAt
ON propositions(creatorPersonId, createdAt DESC);
GO

CREATE INDEX IX_propositions_targetPersonId_createdAt
ON propositions(targetPersonId, createdAt DESC);
GO

CREATE INDEX IX_propositions_processingStatusId_createdAt
ON propositions(processingStatusId, createdAt);
GO

CREATE INDEX IX_propositions_correlationId
ON propositions(correlationId);
GO

/* ========================================================
   TABLE: propositionEvidence
======================================================== */
CREATE TABLE propositionEvidence (
    propositionEvidenceId BIGINT IDENTITY(1,1) PRIMARY KEY,
    propositionId BIGINT,
    evidenceTypeId INT,
    evidenceUrl VARCHAR(255),
    mimeType VARCHAR(100),
    storageProvider VARCHAR(60),
    signedUrlExpiresAt DATETIME2,
    isSensitive BIT,
    uploadedAt DATETIME2,
    correlationId VARCHAR(100),
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_propositionEvidence_propositions
        FOREIGN KEY(propositionId)
        REFERENCES propositions(propositionId),

    CONSTRAINT FK_propositionEvidence_evidenceTypes
        FOREIGN KEY(evidenceTypeId)
        REFERENCES evidenceTypes(evidenceTypeId),

    CONSTRAINT FK_propositionEvidence_people
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_propositionEvidence_propositionId
ON propositionEvidence(propositionId);
GO

/* ========================================================
   TABLE: predictions
======================================================== */
CREATE TABLE predictions (
    predictionId BIGINT IDENTITY(1,1) PRIMARY KEY,
    predictionStatusId INT,
    propositionId BIGINT,
    personId INT,
    predictionValue BIT,
    pointsAmount DECIMAL(10,2)
        CHECK (pointsAmount >= 0 AND pointsAmount <= 1),
    lockedPointsAmount DECIMAL(10,2)
        CHECK (lockedPointsAmount >= 0),
    moneyAmount DECIMAL(14,2)
        CHECK (moneyAmount >= 0),
    lockedMoneyAmount DECIMAL(14,2)
        CHECK (lockedMoneyAmount >= 0),
    currencyId INT,
    exchangeRateId INT,
    exchangeRateSnapshot DECIMAL(18,8),
    financialState VARCHAR(40),
    predictionDateTime DATETIME2,
    isWinner BIT,
    processingStatusId INT,
    correlationId VARCHAR(100),
    batchId VARCHAR(100),
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT UQ_predictions
        UNIQUE(propositionId, personId),

    CONSTRAINT CHK_predictions_nonzero
        CHECK (NOT (pointsAmount = 0 AND moneyAmount = 0)),

    CONSTRAINT FK_predictions_status
        FOREIGN KEY(predictionStatusId)
        REFERENCES predictionStatuses(predictionStatusId),

    CONSTRAINT FK_predictions_propositions
        FOREIGN KEY(propositionId)
        REFERENCES propositions(propositionId),

    CONSTRAINT FK_predictions_people
        FOREIGN KEY(personId)
        REFERENCES people(personId),

    CONSTRAINT FK_predictions_currencies
        FOREIGN KEY(currencyId)
        REFERENCES currencies(currencyId),

    CONSTRAINT FK_predictions_exchangeRates
        FOREIGN KEY(exchangeRateId)
        REFERENCES exchangeRates(exchangeRateId),

    CONSTRAINT FK_predictions_processingStatuses
        FOREIGN KEY(processingStatusId)
        REFERENCES processingStatuses(processingStatusId),

    CONSTRAINT FK_predictions_auditPeople
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_predictions_propositionId_predictionStatusId_createdAt
ON predictions(propositionId, predictionStatusId, createdAt);
GO

CREATE INDEX IX_predictions_personId_createdAt
ON predictions(personId, createdAt DESC);
GO

CREATE INDEX IX_predictions_processingStatusId_createdAt
ON predictions(processingStatusId, createdAt);
GO

CREATE INDEX IX_predictions_batchId
ON predictions(batchId);
GO

CREATE INDEX IX_predictions_correlationId
ON predictions(correlationId);
GO

/* ========================================================
   TABLE: predictionFundingEvents
======================================================== */
CREATE TABLE predictionFundingEvents (
    predictionFundingEventId BIGINT IDENTITY(1,1) PRIMARY KEY,
    predictionId BIGINT,
    eventType VARCHAR(40),
    oldMoneyAmount DECIMAL(18,2),
    newMoneyAmount DECIMAL(18,2),
    deltaMoneyAmount DECIMAL(18,2),
    oldPointsAmount DECIMAL(16,2),
    newPointsAmount DECIMAL(16,2),
    deltaPointsAmount DECIMAL(16,2),
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_predictionFundingEvents_predictions
        FOREIGN KEY(predictionId)
        REFERENCES predictions(predictionId)
);
GO

CREATE INDEX IX_predictionFundingEvents_predictionId_createdAt
ON predictionFundingEvents(predictionId, createdAt DESC);
GO

/* ========================================================
   TABLE: reports
======================================================== */
CREATE TABLE reports (
    reportId BIGINT IDENTITY(1,1) PRIMARY KEY,
    reportTypeId INT,
    reportedPersonId INT,
    reporterPersonId INT,
    propositionId BIGINT,
    description VARCHAR(255),
    correlationId VARCHAR(100),
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_reports_reportTypes
        FOREIGN KEY(reportTypeId)
        REFERENCES reportTypes(reportTypeId),

    CONSTRAINT FK_reports_reportedPerson
        FOREIGN KEY(reportedPersonId)
        REFERENCES people(personId),

    CONSTRAINT FK_reports_reporterPerson
        FOREIGN KEY(reporterPersonId)
        REFERENCES people(personId),

    CONSTRAINT FK_reports_propositions
        FOREIGN KEY(propositionId)
        REFERENCES propositions(propositionId),

    CONSTRAINT FK_reports_auditPeople
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_reports_reportedPersonId_createdAt
ON reports(reportedPersonId, createdAt DESC);
GO

CREATE INDEX IX_reports_reporterPersonId_createdAt
ON reports(reporterPersonId, createdAt DESC);
GO

CREATE INDEX IX_reports_propositionId
ON reports(propositionId);
GO

/* ========================================================
   TABLE: walletBalanceHistory
======================================================== */
CREATE TABLE walletBalanceHistory (
    walletBalanceHistoryId BIGINT IDENTITY(1,1) PRIMARY KEY,
    walletId INT,
    walletTransactionTypeId INT,
    oldPointsAmount DECIMAL(16,2),
    lockedPointsAmount DECIMAL(16,2),
    availablePointsAmount DECIMAL(16,2),
    balancePointsAmount DECIMAL(16,2),
    newPointsAmount DECIMAL(16,2),
    calculatedAt DATETIME2,
    correlationId VARCHAR(100),
    batchId VARCHAR(100),
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_walletBalanceHistory_wallets
        FOREIGN KEY(walletId)
        REFERENCES wallets(walletId),

    CONSTRAINT FK_walletBalanceHistory_transactionTypes
        FOREIGN KEY(walletTransactionTypeId)
        REFERENCES walletTransactionTypes(walletTransactionTypeId),

    CONSTRAINT FK_walletBalanceHistory_people
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_walletBalanceHistory_walletId_calculatedAt
ON walletBalanceHistory(walletId, calculatedAt DESC);
GO

/* ========================================================
   TABLE: walletTransactions
======================================================== */
CREATE TABLE walletTransactions (
    walletTransactionId BIGINT IDENTITY(1,1) PRIMARY KEY,
    originWalletId INT,
    destinationWalletId INT,
    isSelfTransaction BIT,
    pointsAmount DECIMAL(16,2)
        CHECK (pointsAmount > 0),
    transactionDirection VARCHAR(20),
    transactionDateTime DATETIME2,
    referenceTypeId INT,
    referenceId INT,
    processingStatusId INT,
    idempotencyKey VARCHAR(100),
    correlationId VARCHAR(100),
    batchId VARCHAR(100),
    processingNode VARCHAR(100),
    processedAt DATETIME2,
    failedAt DATETIME2,
    retryCount INT,
    previousHash VARBINARY(512),
    currentHash VARBINARY(512),
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_walletTransactions_originWallet
        FOREIGN KEY(originWalletId)
        REFERENCES wallets(walletId),

    CONSTRAINT FK_walletTransactions_destinationWallet
        FOREIGN KEY(destinationWalletId)
        REFERENCES wallets(walletId),

    CONSTRAINT FK_walletTransactions_referenceTypes
        FOREIGN KEY(referenceTypeId)
        REFERENCES referenceTypes(referenceTypeId),

    CONSTRAINT FK_walletTransactions_processingStatuses
        FOREIGN KEY(processingStatusId)
        REFERENCES processingStatuses(processingStatusId),

    CONSTRAINT FK_walletTransactions_people
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE UNIQUE INDEX UX_walletTransactions_idempotencyKey
ON walletTransactions(idempotencyKey);
GO

CREATE INDEX IX_walletTransactions_originWalletId_transactionDateTime
ON walletTransactions(originWalletId, transactionDateTime DESC);
GO

CREATE INDEX IX_walletTransactions_destinationWalletId_transactionDateTime
ON walletTransactions(destinationWalletId, transactionDateTime DESC);
GO

CREATE INDEX IX_walletTransactions_referenceTypeId_referenceId
ON walletTransactions(referenceTypeId, referenceId);
GO

CREATE INDEX IX_walletTransactions_correlationId
ON walletTransactions(correlationId);
GO

/* ========================================================
   TABLE: penalties
======================================================== */
CREATE TABLE penalties (
    penaltyId BIGINT IDENTITY(1,1) PRIMARY KEY,
    penaltyTypeId INT,
    reportId BIGINT,
    walletTransactionId BIGINT,
    pointsAmount DECIMAL(16,2),
    reasonDescription VARCHAR(255),
    executedAt DATETIME2,
    correlationId VARCHAR(100),
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_penalties_penaltyTypes
        FOREIGN KEY(penaltyTypeId)
        REFERENCES penaltyTypes(penaltyTypeId),

    CONSTRAINT FK_penalties_reports
        FOREIGN KEY(reportId)
        REFERENCES reports(reportId),

    CONSTRAINT FK_penalties_walletTransactions
        FOREIGN KEY(walletTransactionId)
        REFERENCES walletTransactions(walletTransactionId),

    CONSTRAINT FK_penalties_people
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_penalties_reportId
ON penalties(reportId);
GO

CREATE INDEX IX_penalties_executedAt
ON penalties(executedAt DESC);
GO

/* ========================================================
   TABLE: moneyWalletTransactions
======================================================== */
CREATE TABLE moneyWalletTransactions (
    moneyWalletTransactionId BIGINT IDENTITY(1,1) PRIMARY KEY,
    originMoneyWalletId BIGINT,
    destinationMoneyWalletId BIGINT,
    transactionTypeId INT,
    amount DECIMAL(18,2)
        CHECK (amount > 0),
    currencyId INT,
    exchangeRateId INT,
    exchangeRateSnapshot DECIMAL(18,8),
    transactionDirection VARCHAR(20),
    referenceTypeId INT,
    referenceId BIGINT,
    processingStatusId INT,
    idempotencyKey VARCHAR(100),
    correlationId VARCHAR(100),
    processedAt DATETIME2,
    failedAt DATETIME2,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_moneyWalletTransactions_originWallet
        FOREIGN KEY(originMoneyWalletId)
        REFERENCES moneyWallets(moneyWalletId),

    CONSTRAINT FK_moneyWalletTransactions_destinationWallet
        FOREIGN KEY(destinationMoneyWalletId)
        REFERENCES moneyWallets(moneyWalletId),

    CONSTRAINT FK_moneyWalletTransactions_transactionTypes
        FOREIGN KEY(transactionTypeId)
        REFERENCES financialTransactionTypes(transactionTypeId),

    CONSTRAINT FK_moneyWalletTransactions_currencies
        FOREIGN KEY(currencyId)
        REFERENCES currencies(currencyId),

    CONSTRAINT FK_moneyWalletTransactions_exchangeRates
        FOREIGN KEY(exchangeRateId)
        REFERENCES exchangeRates(exchangeRateId),

    CONSTRAINT FK_moneyWalletTransactions_referenceTypes
        FOREIGN KEY(referenceTypeId)
        REFERENCES referenceTypes(referenceTypeId),

    CONSTRAINT FK_moneyWalletTransactions_processingStatuses
        FOREIGN KEY(processingStatusId)
        REFERENCES processingStatuses(processingStatusId)
);
GO

CREATE UNIQUE INDEX UX_moneyWalletTransactions_idempotencyKey
ON moneyWalletTransactions(idempotencyKey);
GO

CREATE INDEX IX_moneyWalletTransactions_originWalletId_processedAt
ON moneyWalletTransactions(originMoneyWalletId, processedAt DESC);
GO

CREATE INDEX IX_moneyWalletTransactions_destinationWalletId_processedAt
ON moneyWalletTransactions(destinationMoneyWalletId, processedAt DESC);
GO

/* ========================================================
   TABLE: walletHolds
======================================================== */
CREATE TABLE walletHolds (
    walletHoldId BIGINT IDENTITY(1,1) PRIMARY KEY,
    walletId INT,
    moneyWalletId BIGINT,
    holdType VARCHAR(40),
    lockedPointsAmount DECIMAL(16,2)
        CHECK (lockedPointsAmount >= 0),
    lockedMoneyAmount DECIMAL(18,2)
        CHECK (lockedMoneyAmount >= 0),
    currencyId INT,
    referenceTypeId INT,
    referenceId BIGINT,
    expiresAt DATETIME2,
    releasedAt DATETIME2,
    processingStatusId INT,
    correlationId VARCHAR(100),
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_walletHolds_wallets
        FOREIGN KEY(walletId)
        REFERENCES wallets(walletId),

    CONSTRAINT FK_walletHolds_moneyWallets
        FOREIGN KEY(moneyWalletId)
        REFERENCES moneyWallets(moneyWalletId),

    CONSTRAINT FK_walletHolds_currencies
        FOREIGN KEY(currencyId)
        REFERENCES currencies(currencyId),

    CONSTRAINT FK_walletHolds_referenceTypes
        FOREIGN KEY(referenceTypeId)
        REFERENCES referenceTypes(referenceTypeId),

    CONSTRAINT FK_walletHolds_processingStatuses
        FOREIGN KEY(processingStatusId)
        REFERENCES processingStatuses(processingStatusId)
);
GO

CREATE INDEX IX_walletHolds_walletId
ON walletHolds(walletId);
GO

CREATE INDEX IX_walletHolds_moneyWalletId
ON walletHolds(moneyWalletId);
GO

CREATE INDEX IX_walletHolds_referenceType_referenceId
ON walletHolds(referenceTypeId, referenceId);
GO

/* ========================================================
   TABLE: paymentAttempts
======================================================== */
CREATE TABLE paymentAttempts (
    paymentAttemptId BIGINT IDENTITY(1,1) PRIMARY KEY,
    personId INT,
    paymentMethodId INT,
    isPaymentLoaded BIT,
    amount DECIMAL(16,2)
        CHECK (amount >= 0),
    currencyId INT,
    exchangeRateId INT,
    exchangeRateSnapshot DECIMAL(18,8),
    amountUsd DECIMAL(16,2),
    processingStatusId INT,
    externalTransactionId VARCHAR(120),
    idempotencyKey VARCHAR(100),
    correlationId VARCHAR(100),
    attemptedAt DATETIME2,
    processedAt DATETIME2,
    failedAt DATETIME2,
    retryCount INT,
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_paymentAttempts_people
        FOREIGN KEY(personId)
        REFERENCES people(personId),

    CONSTRAINT FK_paymentAttempts_paymentMethods
        FOREIGN KEY(paymentMethodId)
        REFERENCES paymentMethods(paymentMethodId),

    CONSTRAINT FK_paymentAttempts_currencies
        FOREIGN KEY(currencyId)
        REFERENCES currencies(currencyId),

    CONSTRAINT FK_paymentAttempts_exchangeRates
        FOREIGN KEY(exchangeRateId)
        REFERENCES exchangeRates(exchangeRateId),

    CONSTRAINT FK_paymentAttempts_processingStatuses
        FOREIGN KEY(processingStatusId)
        REFERENCES processingStatuses(processingStatusId),

    CONSTRAINT FK_paymentAttempts_auditPeople
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_paymentAttempts_personId_attemptedAt
ON paymentAttempts(personId, attemptedAt DESC);
GO

/* ========================================================
   TABLE: payments
======================================================== */
CREATE TABLE payments (
    paymentId BIGINT IDENTITY(1,1) PRIMARY KEY,
    personId INT,
    paymentMethodId INT,
    amount DECIMAL(16,2)
        CHECK (amount >= 0),
    currencyId INT,
    exchangeRateId INT,
    exchangeRateSnapshot DECIMAL(18,8),
    amountUsd DECIMAL(16,2),
    processedAt DATETIME2,
    referenceTypeId INT,
    referenceId INT,
    processingStatusId INT,
    externalTransactionId VARCHAR(120),
    idempotencyKey VARCHAR(100),
    correlationId VARCHAR(100),
    batchId VARCHAR(100),
    processingNode VARCHAR(100),
    failedAt DATETIME2,
    retryCount INT,
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT UQ_payments_externalTransaction
        UNIQUE(externalTransactionId, paymentMethodId),

    CONSTRAINT FK_payments_people
        FOREIGN KEY(personId)
        REFERENCES people(personId),

    CONSTRAINT FK_payments_paymentMethods
        FOREIGN KEY(paymentMethodId)
        REFERENCES paymentMethods(paymentMethodId),

    CONSTRAINT FK_payments_currencies
        FOREIGN KEY(currencyId)
        REFERENCES currencies(currencyId),

    CONSTRAINT FK_payments_exchangeRates
        FOREIGN KEY(exchangeRateId)
        REFERENCES exchangeRates(exchangeRateId),

    CONSTRAINT FK_payments_referenceTypes
        FOREIGN KEY(referenceTypeId)
        REFERENCES referenceTypes(referenceTypeId),

    CONSTRAINT FK_payments_processingStatuses
        FOREIGN KEY(processingStatusId)
        REFERENCES processingStatuses(processingStatusId),

    CONSTRAINT FK_payments_auditPeople
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE UNIQUE INDEX UX_payments_idempotencyKey
ON payments(idempotencyKey);
GO

CREATE INDEX IX_payments_personId_processedAt
ON payments(personId, processedAt DESC);
GO

CREATE INDEX IX_payments_processingStatusId_processedAt
ON payments(processingStatusId, processedAt);
GO

CREATE INDEX IX_payments_externalTransactionId
ON payments(externalTransactionId);
GO

/* ========================================================
   TABLE: withdrawalRequests
======================================================== */
CREATE TABLE withdrawalRequests (
    withdrawalRequestId BIGINT IDENTITY(1,1) PRIMARY KEY,
    withdrawalRequestStatusId INT,
    personId INT,
    moneyWalletId BIGINT,
    walletHoldId BIGINT,
    paymentMethodId INT,
    amount DECIMAL(16,2)
        CHECK (amount >= 0),
    currencyId INT,
    exchangeRateId INT,
    exchangeRateSnapshot DECIMAL(18,8),
    amountUsd DECIMAL(16,2),
    requestedAt DATETIME2,
    processedAt DATETIME2,
    referenceTypeId INT,
    referenceId INT,
    processingStatusId INT,
    idempotencyKey VARCHAR(100),
    correlationId VARCHAR(100),
    batchId VARCHAR(100),
    processingNode VARCHAR(100),
    failedAt DATETIME2,
    retryCount INT,
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_withdrawalRequests_statuses
        FOREIGN KEY(withdrawalRequestStatusId)
        REFERENCES withdrawalRequestStatuses(withdrawalRequestStatusId),

    CONSTRAINT FK_withdrawalRequests_people
        FOREIGN KEY(personId)
        REFERENCES people(personId),

    CONSTRAINT FK_withdrawalRequests_moneyWallets
        FOREIGN KEY(moneyWalletId)
        REFERENCES moneyWallets(moneyWalletId),

    CONSTRAINT FK_withdrawalRequests_walletHolds
        FOREIGN KEY(walletHoldId)
        REFERENCES walletHolds(walletHoldId),

    CONSTRAINT FK_withdrawalRequests_paymentMethods
        FOREIGN KEY(paymentMethodId)
        REFERENCES paymentMethods(paymentMethodId),

    CONSTRAINT FK_withdrawalRequests_currencies
        FOREIGN KEY(currencyId)
        REFERENCES currencies(currencyId),

    CONSTRAINT FK_withdrawalRequests_exchangeRates
        FOREIGN KEY(exchangeRateId)
        REFERENCES exchangeRates(exchangeRateId),

    CONSTRAINT FK_withdrawalRequests_referenceTypes
        FOREIGN KEY(referenceTypeId)
        REFERENCES referenceTypes(referenceTypeId),

    CONSTRAINT FK_withdrawalRequests_processingStatuses
        FOREIGN KEY(processingStatusId)
        REFERENCES processingStatuses(processingStatusId),

    CONSTRAINT FK_withdrawalRequests_auditPeople
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE UNIQUE INDEX UX_withdrawalRequests_idempotencyKey
ON withdrawalRequests(idempotencyKey);
GO

CREATE INDEX IX_withdrawalRequests_personId_requestedAt
ON withdrawalRequests(personId, requestedAt DESC);
GO

CREATE INDEX IX_withdrawalRequests_status_requestedAt
ON withdrawalRequests(withdrawalRequestStatusId, requestedAt);
GO

/* ========================================================
   TABLE: withdrawalAttempts
======================================================== */
CREATE TABLE withdrawalAttempts (
    withdrawalAttemptId BIGINT IDENTITY(1,1) PRIMARY KEY,
    withdrawalRequestId BIGINT,
    paymentMethodId INT,
    amount DECIMAL(16,2),
    currencyId INT,
    exchangeRateId INT,
    exchangeRateSnapshot DECIMAL(18,8),
    amountUsd DECIMAL(16,2),
    isSuccessful BIT,
    response NVARCHAR(MAX),
    processingStatusId INT,
    externalTransactionId VARCHAR(120),
    correlationId VARCHAR(100),
    attemptedAt DATETIME2,
    processedAt DATETIME2,
    failedAt DATETIME2,
    retryCount INT,
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT UQ_withdrawalAttempts_externalTransaction
        UNIQUE(externalTransactionId, withdrawalRequestId),

    CONSTRAINT FK_withdrawalAttempts_requests
        FOREIGN KEY(withdrawalRequestId)
        REFERENCES withdrawalRequests(withdrawalRequestId),

    CONSTRAINT FK_withdrawalAttempts_paymentMethods
        FOREIGN KEY(paymentMethodId)
        REFERENCES paymentMethods(paymentMethodId),

    CONSTRAINT FK_withdrawalAttempts_currencies
        FOREIGN KEY(currencyId)
        REFERENCES currencies(currencyId),

    CONSTRAINT FK_withdrawalAttempts_exchangeRates
        FOREIGN KEY(exchangeRateId)
        REFERENCES exchangeRates(exchangeRateId),

    CONSTRAINT FK_withdrawalAttempts_processingStatuses
        FOREIGN KEY(processingStatusId)
        REFERENCES processingStatuses(processingStatusId),

    CONSTRAINT FK_withdrawalAttempts_people
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_withdrawalAttempts_withdrawalRequestId_attemptedAt
ON withdrawalAttempts(withdrawalRequestId, attemptedAt DESC);
GO

/* ========================================================
   TABLE: financialMovements
======================================================== */
CREATE TABLE financialMovements (
    movementId BIGINT IDENTITY(1,1) PRIMARY KEY,
    transactionTypeId INT,
    personId INT,
    sourceMoneyWalletId BIGINT,
    destinationMoneyWalletId BIGINT,
    movementDirection VARCHAR(20),
    amount DECIMAL(14,2)
        CHECK (amount >= 0),
    currencyId INT,
    exchangeRateId INT,
    exchangeRateSnapshot DECIMAL(18,8),
    amountUsd DECIMAL(14,2),
    referenceTypeId INT,
    referenceId INT,
    description VARCHAR(120),
    processingStatusId INT,
    idempotencyKey VARCHAR(100),
    correlationId VARCHAR(100),
    batchId VARCHAR(100),
    processingNode VARCHAR(100),
    processedAt DATETIME2,
    failedAt DATETIME2,
    retryCount INT,
    previousHash VARBINARY(512),
    currentHash VARBINARY(512),
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_financialMovements_transactionTypes
        FOREIGN KEY(transactionTypeId)
        REFERENCES financialTransactionTypes(transactionTypeId),

    CONSTRAINT FK_financialMovements_people
        FOREIGN KEY(personId)
        REFERENCES people(personId),

    CONSTRAINT FK_financialMovements_sourceWallet
        FOREIGN KEY(sourceMoneyWalletId)
        REFERENCES moneyWallets(moneyWalletId),

    CONSTRAINT FK_financialMovements_destinationWallet
        FOREIGN KEY(destinationMoneyWalletId)
        REFERENCES moneyWallets(moneyWalletId),

    CONSTRAINT FK_financialMovements_currencies
        FOREIGN KEY(currencyId)
        REFERENCES currencies(currencyId),

    CONSTRAINT FK_financialMovements_exchangeRates
        FOREIGN KEY(exchangeRateId)
        REFERENCES exchangeRates(exchangeRateId),

    CONSTRAINT FK_financialMovements_referenceTypes
        FOREIGN KEY(referenceTypeId)
        REFERENCES referenceTypes(referenceTypeId),

    CONSTRAINT FK_financialMovements_processingStatuses
        FOREIGN KEY(processingStatusId)
        REFERENCES processingStatuses(processingStatusId),

    CONSTRAINT FK_financialMovements_auditPeople
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_financialMovements_personId_processedAt
ON financialMovements(personId, processedAt DESC);
GO

CREATE INDEX IX_financialMovements_processingStatusId_processedAt
ON financialMovements(processingStatusId, processedAt);
GO

/* ========================================================
   TABLE: financialBalancesHistory
======================================================== */
CREATE TABLE financialBalancesHistory (
    balanceId BIGINT IDENTITY(1,1) PRIMARY KEY,
    totalBalanceUsd DECIMAL(16,2),
    calculatedAt DATETIME2,
    correlationId VARCHAR(100),
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_financialBalancesHistory_people
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_financialBalancesHistory_calculatedAt
ON financialBalancesHistory(calculatedAt DESC);
GO

/* ========================================================
   TABLE: commissions
======================================================== */
CREATE TABLE commissions (
    commissionId BIGINT IDENTITY(1,1) PRIMARY KEY,
    commissionTypeId INT,
    referenceTypeId INT,
    referenceId INT,
    sourceWalletTransactionId BIGINT,
    financialMovementId BIGINT,
    appliedAmount DECIMAL(16,2),
    percentage DECIMAL(5,2),
    commissionAmount DECIMAL(16,2),
    basePoolAmount DECIMAL(18,2),
    winnerPoolAmount DECIMAL(18,2),
    loserPoolAmount DECIMAL(18,2),
    exchangeRateSnapshot DECIMAL(18,8),
    batchId VARCHAR(100),
    correlationId VARCHAR(100),
    executedAt DATETIME2,
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_commissions_commissionTypes
        FOREIGN KEY(commissionTypeId)
        REFERENCES commissionTypes(commissionTypeId),

    CONSTRAINT FK_commissions_referenceTypes
        FOREIGN KEY(referenceTypeId)
        REFERENCES referenceTypes(referenceTypeId),

    CONSTRAINT FK_commissions_walletTransactions
        FOREIGN KEY(sourceWalletTransactionId)
        REFERENCES walletTransactions(walletTransactionId),

    CONSTRAINT FK_commissions_financialMovements
        FOREIGN KEY(financialMovementId)
        REFERENCES financialMovements(movementId),

    CONSTRAINT FK_commissions_people
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_commissions_sourceWalletTransactionId
ON commissions(sourceWalletTransactionId);
GO

CREATE INDEX IX_commissions_financialMovementId
ON commissions(financialMovementId);
GO

/* ========================================================
   TABLE: notifications
======================================================== */
CREATE TABLE notifications (
    notificationId BIGINT IDENTITY(1,1) PRIMARY KEY,
    notificationTypeId INT,
    personId INT,
    title VARCHAR(120),
    message VARCHAR(255),
    isRead BIT,
    readAt DATETIME2,
    expiresAt DATETIME2,
    referenceTypeId INT,
    referenceId INT,
    correlationId VARCHAR(100),
    auditpersonId INT,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_notifications_notificationTypes
        FOREIGN KEY(notificationTypeId)
        REFERENCES notificationTypes(notificationTypeId),

    CONSTRAINT FK_notifications_people
        FOREIGN KEY(personId)
        REFERENCES people(personId),

    CONSTRAINT FK_notifications_referenceTypes
        FOREIGN KEY(referenceTypeId)
        REFERENCES referenceTypes(referenceTypeId),

    CONSTRAINT FK_notifications_auditPeople
        FOREIGN KEY(auditpersonId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_notifications_personId_isRead_createdAt
ON notifications(personId, isRead, createdAt DESC);
GO

/* ========================================================
   TABLE: auditLogs
======================================================== */
CREATE TABLE auditLogs (
    logId BIGINT IDENTITY(1,1) PRIMARY KEY,
    tableName VARCHAR(60),
    recordId INT,
    actionType VARCHAR(30),
    personId INT,
    authSessionId INT,
    ipAddress VARCHAR(100),
    userAgent VARCHAR(255),
    requestSource VARCHAR(60),
    operationResult VARCHAR(60),
    correlationId VARCHAR(100),
    processingNode VARCHAR(100),
    actionTimestamp DATETIME2,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_auditLogs_people
        FOREIGN KEY(personId)
        REFERENCES people(personId),

    CONSTRAINT FK_auditLogs_authSessions
        FOREIGN KEY(authSessionId)
        REFERENCES authSessions(authSessionId)
);
GO

CREATE INDEX IX_auditLogs_tableName_recordId
ON auditLogs(tableName, recordId);
GO

CREATE INDEX IX_auditLogs_personId_actionTimestamp
ON auditLogs(personId, actionTimestamp DESC);
GO

CREATE INDEX IX_auditLogs_correlationId
ON auditLogs(correlationId);
GO

/* ========================================================
   TABLE: auditLogDetails
======================================================== */
CREATE TABLE auditLogDetails (
    auditLogDetailId BIGINT IDENTITY(1,1) PRIMARY KEY,
    logId BIGINT,
    columnName VARCHAR(60),
    oldValue VARCHAR(255),
    newValue VARCHAR(255),
    oldJson NVARCHAR(MAX),
    newJson NVARCHAR(MAX),
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_auditLogDetails_auditLogs
        FOREIGN KEY(logId)
        REFERENCES auditLogs(logId)
);
GO

CREATE INDEX IX_auditLogDetails_logId
ON auditLogDetails(logId);
GO

/* ========================================================
   TABLE: systemProcessingLogs
======================================================== */
CREATE TABLE systemProcessingLogs (
    systemProcessingLogId BIGINT IDENTITY(1,1) PRIMARY KEY,
    processName VARCHAR(120),
    processType VARCHAR(60),
    processingStatusId INT,
    correlationId VARCHAR(100),
    processingNode VARCHAR(100),
    executionTimeMs INT,
    errorMessage VARCHAR(255),
    startedAt DATETIME2,
    finishedAt DATETIME2,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_systemProcessingLogs_processingStatuses
        FOREIGN KEY(processingStatusId)
        REFERENCES processingStatuses(processingStatusId)
);
GO

CREATE INDEX IX_systemProcessingLogs_processingStatusId_startedAt
ON systemProcessingLogs(processingStatusId, startedAt DESC);
GO

CREATE INDEX IX_systemProcessingLogs_correlationId
ON systemProcessingLogs(correlationId);
GO

/* ========================================================
   TABLE: propositionEvents
======================================================== */
CREATE TABLE propositionEvents (
    propositionEventId BIGINT IDENTITY(1,1) PRIMARY KEY,
    propositionId BIGINT,
    propositionEventTypeId INT,
    personId INT,
    eventDescription VARCHAR(255),
    correlationId VARCHAR(100),
    occurredAt DATETIME2,
    createdAt DATETIME2,
    updatedAt DATETIME2,
    isDeleted BIT,

    CONSTRAINT FK_propositionEvents_propositions
        FOREIGN KEY(propositionId)
        REFERENCES propositions(propositionId),

    CONSTRAINT FK_propositionEvents_eventTypes
        FOREIGN KEY(propositionEventTypeId)
        REFERENCES propositionEventTypes(propositionEventTypeId),

    CONSTRAINT FK_propositionEvents_people
        FOREIGN KEY(personId)
        REFERENCES people(personId)
);
GO

CREATE INDEX IX_propositionEvents_propositionId_occurredAt
ON propositionEvents(propositionId, occurredAt DESC);
GO

CREATE INDEX IX_propositionEvents_eventTypeId
ON propositionEvents(propositionEventTypeId);
GO