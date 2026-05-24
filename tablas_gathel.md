# "Gathel, Gaming the Life"

# Info

* Database engine: Microsoft SQL Server 2022
* Database name: Gathel
* Context: El sistema de base de datos está diseñado para soportar las operaciones de una plataforma social de predicciones y apuestas digitales basada en eventos y acciones de la vida real de las personas, como Gathel. Su propósito es centralizar y gestionar la información relacionada con jugadores, proposiciones, predicciones, wallets virtuales, pagos en dinero real, validaciones, reportes, penalizaciones y actividad social dentro de la plataforma. Este sistema permite dar trazabilidad completa a las interacciones, movimientos financieros, estados de las proposiciones y resultados de predicciones, integrando procesos sociales, financieros, de auditoría y validación automática en una sola estructura de datos orientada a alta concurrencia, trazabilidad y escalabilidad.

---

# Tables

## peopleTypes

* peopleTypeId INT IDENTITY(1,1) PK
* name VARCHAR(30)
* description VARCHAR(100)
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_peopleTypes_isDeleted (isDeleted)

---

## roles

* roleId INT IDENTITY(1,1) PK
* name VARCHAR(50) UNIQUE
* description VARCHAR(150)
* isSystemRole BIT
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* UNIQUE INDEX UX_roles_name (name)

---

## permissions

* permissionId INT IDENTITY(1,1) PK
* name VARCHAR(80) UNIQUE
* description VARCHAR(200)
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* UNIQUE INDEX UX_permissions_name (name)

---

## rolePermissions

* rolePermissionId BIGINT IDENTITY(1,1) PK
* roleId INT FK roles
* permissionId INT FK permissions
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT
* UNIQUE(roleId, permissionId)

### Performance

* INDEX IX_rolePermissions_roleId (roleId)
* INDEX IX_rolePermissions_permissionId (permissionId)

---

## personRoles

* personRoleId BIGINT IDENTITY(1,1) PK
* personId INT FK people
* roleId INT FK roles
* assignedAt DATETIME2
* assignedByPersonId INT FK people
* expiresAt DATETIME2
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT
* UNIQUE(personId, roleId)

### Performance

* INDEX IX_personRoles_personId (personId)
* INDEX IX_personRoles_roleId (roleId)

---

## countries

* countryId INT IDENTITY(1,1) PK
* name VARCHAR(80)
* isoCode VARCHAR(5) UNIQUE
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_countries_isDeleted (isDeleted)

---

## propositionStatuses

* propositionStatusId INT IDENTITY(1,1) PK
* name VARCHAR(40)
* description VARCHAR(120)
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_propositionStatuses_auditpersonId (auditpersonId)

---

## predictionStatuses

* predictionStatusId INT IDENTITY(1,1) PK
* name VARCHAR(40)
* description VARCHAR(120)
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_predictionStatuses_auditpersonId (auditpersonId)

---

## reportTypes

* reportTypeId INT IDENTITY(1,1) PK
* name VARCHAR(40)
* description VARCHAR(120)
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_reportTypes_auditpersonId (auditpersonId)

---

## currencies

* currencyId INT IDENTITY(1,1) PK
* name VARCHAR(30)
* code VARCHAR(10)
* symbol VARCHAR(10)
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* UNIQUE INDEX UX_currencies_code (code)
* INDEX IX_currencies_auditpersonId (auditpersonId)

---

## referenceTypes

* referenceTypeId INT IDENTITY(1,1) PK
* name VARCHAR(30)
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_referenceTypes_auditpersonId (auditpersonId)

---

## walletTransactionTypes

* walletTransactionTypeId INT IDENTITY(1,1) PK
* name VARCHAR(40)
* description VARCHAR(120)
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_walletTransactionTypes_auditpersonId (auditpersonId)

---

## paymentMethods

* paymentMethodId INT IDENTITY(1,1) PK
* name VARCHAR(30)
* logoUrl VARCHAR(255)
* publicConfig NVARCHAR(MAX)
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_paymentMethods_auditpersonId (auditpersonId)

---

## paymentMethodSecrets

* paymentMethodSecretId BIGINT IDENTITY(1,1) PK
* paymentMethodId INT FK paymentMethods
* encryptedSecret VARBINARY(MAX)
* encryptionKeyVersion VARCHAR(30)
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_paymentMethodSecrets_paymentMethodId (paymentMethodId)

---

## financialTransactionTypes

* transactionTypeId INT IDENTITY(1,1) PK
* name VARCHAR(30)
* description VARCHAR(80)
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_financialTransactionTypes_auditpersonId (auditpersonId)

---

## commissionTypes

* commissionTypeId INT IDENTITY(1,1) PK
* name VARCHAR(40)
* description VARCHAR(120)
* percentage DECIMAL(5,2) CHECK (percentage BETWEEN 0 AND 100)
* isActive BIT
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_commissionTypes_isActive (isActive)

---

## withdrawalRequestStatuses

* withdrawalRequestStatusId INT IDENTITY(1,1) PK
* name VARCHAR(40)
* description VARCHAR(120)
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_withdrawalRequestStatuses_auditpersonId (auditpersonId)

---

## penaltyTypes

* penaltyTypeId INT IDENTITY(1,1) PK
* name VARCHAR(40)
* description VARCHAR(120)
* pointsPercentage DECIMAL(5,2) CHECK (pointsPercentage BETWEEN 0 AND 100)
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_penaltyTypes_auditpersonId (auditpersonId)

---

## socialPlatforms

* socialPlatformId INT IDENTITY(1,1) PK
* name VARCHAR(40)
* apiUrl VARCHAR(255)
* logoUrl VARCHAR(255)
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* UNIQUE INDEX UX_socialPlatforms_name (name)

---

## notificationTypes

* notificationTypeId INT IDENTITY(1,1) PK
* name VARCHAR(40)
* description VARCHAR(120)
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

---

## evidenceTypes

* evidenceTypeId INT IDENTITY(1,1) PK
* name VARCHAR(40)
* description VARCHAR(120)
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

---

## propositionResultTypes

* propositionResultTypeId INT IDENTITY(1,1) PK
* name VARCHAR(40)
* description VARCHAR(120)
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

---

## aiModerationStatuses

* aiModerationStatusId INT IDENTITY(1,1) PK
* name VARCHAR(40)
* description VARCHAR(120)
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

---

## propositionEventTypes

* propositionEventTypeId INT IDENTITY(1,1) PK
* name VARCHAR(40)
* description VARCHAR(120)
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

---

## processingStatuses

* processingStatusId INT IDENTITY(1,1) PK
* name VARCHAR(40)
* description VARCHAR(120)
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

---

## cities

* cityId INT IDENTITY(1,1) PK
* countryId INT FK countries
* name VARCHAR(80)
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT
* UNIQUE(countryId, name)

### Performance

* INDEX IX_cities_countryId (countryId)

---

## addresses

* addressId INT IDENTITY(1,1) PK
* cityId INT FK cities
* exactAddress VARCHAR(200)
* isSensitive BIT
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_addresses_cityId (cityId)

---

## people

* personId INT IDENTITY(1,1) PK
* personTypeId INT FK peopleTypes
* name VARCHAR(60)
* lastName VARCHAR(60)
* identification VARCHAR(30) UNIQUE
* phone VARCHAR(20)
* email VARCHAR(100) UNIQUE
* passwordHash VARBINARY(512)
* passwordSalt VARBINARY(256)
* passwordAlgorithm VARCHAR(40)
* passwordChangedAt DATETIME2
* failedLoginAttempts INT
* lockedUntil DATETIME2
* username VARCHAR(40) UNIQUE
* profilePhotoUrl VARCHAR(255)
* biography VARCHAR(200)
* birthDate DATE
* addressId INT FK addresses
* isVerified BIT
* isActive BIT
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* UNIQUE INDEX UX_people_email (email)
* UNIQUE INDEX UX_people_username (username)
* INDEX IX_people_personTypeId (personTypeId)
* INDEX IX_people_addressId (addressId)
* INDEX IX_people_isActive_isDeleted (isActive, isDeleted)

---

## socialAccounts

* socialAccountId INT IDENTITY(1,1) PK
* personId INT FK people
* socialPlatformId INT FK socialPlatforms
* username VARCHAR(80)
* profileUrl VARCHAR(255)
* isVerified BIT
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT
* UNIQUE(personId, socialPlatformId, username)

### Performance

* INDEX IX_socialAccounts_personId (personId)
* INDEX IX_socialAccounts_socialPlatformId (socialPlatformId)

---

## socialAccountSecrets

* socialAccountSecretId BIGINT IDENTITY(1,1) PK
* socialAccountId INT FK socialAccounts
* encryptedAccessToken VARBINARY(MAX)
* encryptedRefreshToken VARBINARY(MAX)
* tokenScope VARCHAR(255)
* tokenExpiresAt DATETIME2
* encryptionKeyVersion VARCHAR(30)
* isRevoked BIT
* revokedAt DATETIME2
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_socialAccountSecrets_socialAccountId (socialAccountId)

---

## wallets

* walletId INT IDENTITY(1,1) PK
* personId INT FK people UNIQUE
* availablePointsAmount DECIMAL(16,2) CHECK (availablePointsAmount >= 0)
* lockedPointsAmount DECIMAL(16,2) CHECK (lockedPointsAmount >= 0)
* isBlocked BIT
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* UNIQUE INDEX UX_wallets_personId (personId)

---

## moneyWallets

* moneyWalletId BIGINT IDENTITY(1,1) PK
* personId INT FK people
* currencyId INT FK currencies
* availableAmount DECIMAL(18,2) CHECK (availableAmount >= 0)
* lockedAmount DECIMAL(18,2) CHECK (lockedAmount >= 0)
* rowVersion ROWVERSION
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT
* UNIQUE(personId, currencyId)

### Performance

* UNIQUE INDEX UX_moneyWallets_person_currency (personId, currencyId)

---

## walletCurrentBalances

* walletCurrentBalanceId INT IDENTITY(1,1) PK
* walletId INT FK wallets UNIQUE
* currentPointsAmount DECIMAL(16,2)
* lockedPointsAmount DECIMAL(16,2)
* availablePointsAmount DECIMAL(16,2)
* lastTransactionDateTime DATETIME2
* rowVersion ROWVERSION
* previousHash VARBINARY(512)
* currentHash VARBINARY(512)
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* UNIQUE INDEX UX_walletCurrentBalances_walletId (walletId)

---

## authSessions

* authSessionId INT IDENTITY(1,1) PK
* personId INT FK people
* ipAddress VARCHAR(100)
* userAgent VARCHAR(255)
* deviceFingerprint VARCHAR(255)
* mfaValidated BIT
* sessionType VARCHAR(40)
* expiresAt DATETIME2
* lastActivityAt DATETIME2
* isRevoked BIT
* revokedAt DATETIME2
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_authSessions_personId_expiresAt (personId, expiresAt DESC)
* INDEX IX_authSessions_isRevoked_expiresAt (isRevoked, expiresAt)

---

## authSessionSecrets

* authSessionSecretId BIGINT IDENTITY(1,1) PK
* authSessionId INT FK authSessions
* encryptedRefreshToken VARBINARY(MAX)
* encryptionKeyVersion VARCHAR(30)
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_authSessionSecrets_authSessionId (authSessionId)

---

## loginAttempts

* loginAttemptId BIGINT IDENTITY(1,1) PK
* personId INT FK people
* attemptedEmail VARCHAR(100)
* ipAddress VARCHAR(100)
* userAgent VARCHAR(255)
* wasSuccessful BIT
* failureReason VARCHAR(120)
* attemptedAt DATETIME2
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_loginAttempts_personId_attemptedAt (personId, attemptedAt DESC)
* INDEX IX_loginAttempts_ipAddress_attemptedAt (ipAddress, attemptedAt DESC)

---

## securityEvents

* securityEventId BIGINT IDENTITY(1,1) PK
* personId INT FK people
* authSessionId INT FK authSessions
* eventType VARCHAR(60)
* eventDescription VARCHAR(255)
* ipAddress VARCHAR(100)
* userAgent VARCHAR(255)
* correlationId VARCHAR(100)
* occurredAt DATETIME2
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_securityEvents_personId_occurredAt (personId, occurredAt DESC)

---

## mfaMethods

* mfaMethodId BIGINT IDENTITY(1,1) PK
* personId INT FK people
* methodType VARCHAR(40)
* encryptedSecret VARBINARY(MAX)
* recoveryCodeHash VARBINARY(MAX)
* isPrimary BIT
* isActive BIT
* verifiedAt DATETIME2
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_mfaMethods_personId (personId)

---

## exchangeRates

* exchangeRateId INT IDENTITY(1,1) PK
* currencyId INT FK currencies
* rateToUsd DECIMAL(12,6) CHECK (rateToUsd > 0)
* isCurrent BIT
* exchangeDateTime DATETIME2
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_exchangeRates_currencyId_exchangeDateTime (currencyId, exchangeDateTime DESC)

---

## propositionEvents

* propositionEventId BIGINT IDENTITY(1,1) PK
* propositionId BIGINT FK propositions
* propositionEventTypeId INT FK propositionEventTypes
* personId INT FK people
* eventDescription VARCHAR(255)
* correlationId VARCHAR(100)
* occurredAt DATETIME2
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_propositionEvents_propositionId_occurredAt (propositionId, occurredAt DESC)
* INDEX IX_propositionEvents_eventTypeId (propositionEventTypeId)

---

## propositions

* propositionId BIGINT IDENTITY(1,1) PK
* parentPropositionId BIGINT FK propositions
* propositionStatusId INT FK propositionStatuses
* propositionResultTypeId INT FK propositionResultTypes
* aiModerationStatusId INT FK aiModerationStatuses
* creatorPersonId INT FK people
* targetPersonId INT FK people
* targetSocialAccountId INT FK socialAccounts
* title VARCHAR(120)
* description VARCHAR(300)
* startPredictionDateTime DATETIME2
* endPredictionDateTime DATETIME2
* winningOption BIT
* minimumEntryPointsAmount DECIMAL(16,2)
* winningProfitPercentage DECIMAL(5,2) CHECK (winningProfitPercentage BETWEEN 0 AND 100)
* resolvedByAI BIT
* resolvedAt DATETIME2
* isPublic BIT
* processingStatusId INT FK processingStatuses
* correlationId VARCHAR(100)
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_propositions_status_endDate_createdAt (propositionStatusId, endPredictionDateTime, createdAt DESC)
* INDEX IX_propositions_creatorPersonId_createdAt (creatorPersonId, createdAt DESC)
* INDEX IX_propositions_targetPersonId_createdAt (targetPersonId, createdAt DESC)
* INDEX IX_propositions_processingStatusId_createdAt (processingStatusId, createdAt)
* INDEX IX_propositions_correlationId (correlationId)

---

## propositionEvidence

* propositionEvidenceId BIGINT IDENTITY(1,1) PK
* propositionId BIGINT FK propositions
* evidenceTypeId INT FK evidenceTypes
* evidenceUrl VARCHAR(255)
* mimeType VARCHAR(100)
* storageProvider VARCHAR(60)
* signedUrlExpiresAt DATETIME2
* isSensitive BIT
* uploadedAt DATETIME2
* correlationId VARCHAR(100)
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_propositionEvidence_propositionId (propositionId)

---

## predictions

* predictionId BIGINT IDENTITY(1,1) PK
* predictionStatusId INT FK predictionStatuses
* propositionId BIGINT FK propositions
* personId INT FK people
* predictionValue BIT
* pointsAmount DECIMAL(10,2) CHECK (pointsAmount >= 0 AND pointsAmount <= 1)
* lockedPointsAmount DECIMAL(10,2) CHECK (lockedPointsAmount >= 0)
* moneyAmount DECIMAL(14,2) CHECK (moneyAmount >= 0)
* lockedMoneyAmount DECIMAL(14,2) CHECK (lockedMoneyAmount >= 0)
* currencyId INT FK currencies
* exchangeRateId INT FK exchangeRates
* exchangeRateSnapshot DECIMAL(18,8)
* financialState VARCHAR(40)
* predictionDateTime DATETIME2
* isWinner BIT
* processingStatusId INT FK processingStatuses
* correlationId VARCHAR(100)
* batchId VARCHAR(100)
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT
* UNIQUE(propositionId, personId)
* CHECK (NOT (pointsAmount = 0 AND moneyAmount = 0))

### Performance

* INDEX IX_predictions_propositionId_predictionStatusId_createdAt (propositionId, predictionStatusId, createdAt)
* INDEX IX_predictions_personId_createdAt (personId, createdAt DESC)
* INDEX IX_predictions_processingStatusId_createdAt (processingStatusId, createdAt)
* INDEX IX_predictions_batchId (batchId)
* INDEX IX_predictions_correlationId (correlationId)

---

## predictionFundingEvents

* predictionFundingEventId BIGINT IDENTITY(1,1) PK
* predictionId BIGINT FK predictions
* eventType VARCHAR(40)
* oldMoneyAmount DECIMAL(18,2)
* newMoneyAmount DECIMAL(18,2)
* deltaMoneyAmount DECIMAL(18,2)
* oldPointsAmount DECIMAL(16,2)
* newPointsAmount DECIMAL(16,2)
* deltaPointsAmount DECIMAL(16,2)
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_predictionFundingEvents_predictionId_createdAt (predictionId, createdAt DESC)

---

## reports

* reportId BIGINT IDENTITY(1,1) PK
* reportTypeId INT FK reportTypes
* reportedPersonId INT FK people
* reporterPersonId INT FK people
* propositionId BIGINT FK propositions
* description VARCHAR(255)
* correlationId VARCHAR(100)
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_reports_reportedPersonId_createdAt (reportedPersonId, createdAt DESC)
* INDEX IX_reports_reporterPersonId_createdAt (reporterPersonId, createdAt DESC)
* INDEX IX_reports_propositionId (propositionId)

---

## penalties

* penaltyId BIGINT IDENTITY(1,1) PK
* penaltyTypeId INT FK penaltyTypes
* reportId BIGINT FK reports
* walletTransactionId BIGINT FK walletTransactions
* pointsAmount DECIMAL(16,2)
* reasonDescription VARCHAR(255)
* executedAt DATETIME2
* correlationId VARCHAR(100)
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_penalties_reportId (reportId)
* INDEX IX_penalties_executedAt (executedAt DESC)

---

## walletBalanceHistory

* walletBalanceHistoryId BIGINT IDENTITY(1,1) PK
* walletId INT FK wallets
* walletTransactionTypeId INT FK walletTransactionTypes
* oldPointsAmount DECIMAL(16,2)
* lockedPointsAmount DECIMAL(16,2)
* availablePointsAmount DECIMAL(16,2)
* balancePointsAmount DECIMAL(16,2)
* newPointsAmount DECIMAL(16,2)
* calculatedAt DATETIME2
* correlationId VARCHAR(100)
* batchId VARCHAR(100)
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_walletBalanceHistory_walletId_calculatedAt (walletId, calculatedAt DESC)

---

## walletTransactions

* walletTransactionId BIGINT IDENTITY(1,1) PK
* originWalletId INT FK wallets
* destinationWalletId INT FK wallets
* isSelfTransaction BIT
* pointsAmount DECIMAL(16,2) CHECK (pointsAmount > 0)
* transactionDirection VARCHAR(20)
* transactionDateTime DATETIME2
* referenceTypeId INT FK referenceTypes
* referenceId INT
* processingStatusId INT FK processingStatuses
* idempotencyKey VARCHAR(100)
* correlationId VARCHAR(100)
* batchId VARCHAR(100)
* processingNode VARCHAR(100)
* processedAt DATETIME2
* failedAt DATETIME2
* retryCount INT
* previousHash VARBINARY(512)
* currentHash VARBINARY(512)
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* UNIQUE INDEX UX_walletTransactions_idempotencyKey (idempotencyKey)
* INDEX IX_walletTransactions_originWalletId_transactionDateTime (originWalletId, transactionDateTime DESC)
* INDEX IX_walletTransactions_destinationWalletId_transactionDateTime (destinationWalletId, transactionDateTime DESC)
* INDEX IX_walletTransactions_referenceTypeId_referenceId (referenceTypeId, referenceId)
* INDEX IX_walletTransactions_correlationId (correlationId)

---

## moneyWalletTransactions

* moneyWalletTransactionId BIGINT IDENTITY(1,1) PK
* originMoneyWalletId BIGINT FK moneyWallets
* destinationMoneyWalletId BIGINT FK moneyWallets
* transactionTypeId INT FK financialTransactionTypes
* amount DECIMAL(18,2) CHECK (amount > 0)
* currencyId INT FK currencies
* exchangeRateId INT FK exchangeRates
* exchangeRateSnapshot DECIMAL(18,8)
* transactionDirection VARCHAR(20)
* referenceTypeId INT FK referenceTypes
* referenceId BIGINT
* processingStatusId INT FK processingStatuses
* idempotencyKey VARCHAR(100)
* correlationId VARCHAR(100)
* processedAt DATETIME2
* failedAt DATETIME2
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* UNIQUE INDEX UX_moneyWalletTransactions_idempotencyKey (idempotencyKey)
* INDEX IX_moneyWalletTransactions_originWalletId_processedAt (originMoneyWalletId, processedAt DESC)
* INDEX IX_moneyWalletTransactions_destinationWalletId_processedAt (destinationMoneyWalletId, processedAt DESC)

---

## walletHolds

* walletHoldId BIGINT IDENTITY(1,1) PK
* walletId INT FK wallets
* moneyWalletId BIGINT FK moneyWallets
* holdType VARCHAR(40)
* lockedPointsAmount DECIMAL(16,2) CHECK (lockedPointsAmount >= 0)
* lockedMoneyAmount DECIMAL(18,2) CHECK (lockedMoneyAmount >= 0)
* currencyId INT FK currencies
* referenceTypeId INT FK referenceTypes
* referenceId BIGINT
* expiresAt DATETIME2
* releasedAt DATETIME2
* processingStatusId INT FK processingStatuses
* correlationId VARCHAR(100)
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_walletHolds_walletId (walletId)
* INDEX IX_walletHolds_moneyWalletId (moneyWalletId)
* INDEX IX_walletHolds_referenceType_referenceId (referenceTypeId, referenceId)

---

## paymentAttempts

* paymentAttemptId BIGINT IDENTITY(1,1) PK
* personId INT FK people
* paymentMethodId INT FK paymentMethods
* isPaymentLoaded BIT
* amount DECIMAL(16,2) CHECK (amount >= 0)
* currencyId INT FK currencies
* exchangeRateId INT FK exchangeRates
* exchangeRateSnapshot DECIMAL(18,8)
* amountUsd DECIMAL(16,2)
* processingStatusId INT FK processingStatuses
* externalTransactionId VARCHAR(120)
* idempotencyKey VARCHAR(100)
* correlationId VARCHAR(100)
* attemptedAt DATETIME2
* processedAt DATETIME2
* failedAt DATETIME2
* retryCount INT
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_paymentAttempts_personId_attemptedAt (personId, attemptedAt DESC)

---

## payments

* paymentId BIGINT IDENTITY(1,1) PK
* personId INT FK people
* paymentMethodId INT FK paymentMethods
* amount DECIMAL(16,2) CHECK (amount >= 0)
* currencyId INT FK currencies
* exchangeRateId INT FK exchangeRates
* exchangeRateSnapshot DECIMAL(18,8)
* amountUsd DECIMAL(16,2)
* processedAt DATETIME2
* referenceTypeId INT FK referenceTypes
* referenceId INT
* processingStatusId INT FK processingStatuses
* externalTransactionId VARCHAR(120)
* idempotencyKey VARCHAR(100)
* correlationId VARCHAR(100)
* batchId VARCHAR(100)
* processingNode VARCHAR(100)
* failedAt DATETIME2
* retryCount INT
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT
* UNIQUE(externalTransactionId, paymentMethodId)

### Performance

* UNIQUE INDEX UX_payments_idempotencyKey (idempotencyKey)
* INDEX IX_payments_personId_processedAt (personId, processedAt DESC)
* INDEX IX_payments_processingStatusId_processedAt (processingStatusId, processedAt)
* INDEX IX_payments_externalTransactionId (externalTransactionId)

---

## withdrawalRequests

* withdrawalRequestId BIGINT IDENTITY(1,1) PK
* withdrawalRequestStatusId INT FK withdrawalRequestStatuses
* personId INT FK people
* moneyWalletId BIGINT FK moneyWallets
* walletHoldId BIGINT FK walletHolds
* paymentMethodId INT FK paymentMethods
* amount DECIMAL(16,2) CHECK (amount >= 0)
* currencyId INT FK currencies
* exchangeRateId INT FK exchangeRates
* exchangeRateSnapshot DECIMAL(18,8)
* amountUsd DECIMAL(16,2)
* requestedAt DATETIME2
* processedAt DATETIME2
* referenceTypeId INT FK referenceTypes
* referenceId INT
* processingStatusId INT FK processingStatuses
* idempotencyKey VARCHAR(100)
* correlationId VARCHAR(100)
* batchId VARCHAR(100)
* processingNode VARCHAR(100)
* failedAt DATETIME2
* retryCount INT
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* UNIQUE INDEX UX_withdrawalRequests_idempotencyKey (idempotencyKey)
* INDEX IX_withdrawalRequests_personId_requestedAt (personId, requestedAt DESC)
* INDEX IX_withdrawalRequests_status_requestedAt (withdrawalRequestStatusId, requestedAt)

---

## withdrawalAttempts

* withdrawalAttemptId BIGINT IDENTITY(1,1) PK
* withdrawalRequestId BIGINT FK withdrawalRequests
* paymentMethodId INT FK paymentMethods
* amount DECIMAL(16,2)
* currencyId INT FK currencies
* exchangeRateId INT FK exchangeRates
* exchangeRateSnapshot DECIMAL(18,8)
* amountUsd DECIMAL(16,2)
* isSuccessful BIT
* response NVARCHAR(MAX)
* processingStatusId INT FK processingStatuses
* externalTransactionId VARCHAR(120)
* correlationId VARCHAR(100)
* attemptedAt DATETIME2
* processedAt DATETIME2
* failedAt DATETIME2
* retryCount INT
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT
* UNIQUE(externalTransactionId, withdrawalRequestId)

### Performance

* INDEX IX_withdrawalAttempts_withdrawalRequestId_attemptedAt (withdrawalRequestId, attemptedAt DESC)

---

## financialMovements

* movementId BIGINT IDENTITY(1,1) PK
* transactionTypeId INT FK financialTransactionTypes
* personId INT FK people
* sourceMoneyWalletId BIGINT FK moneyWallets
* destinationMoneyWalletId BIGINT FK moneyWallets
* movementDirection VARCHAR(20)
* amount DECIMAL(14,2) CHECK (amount >= 0)
* currencyId INT FK currencies
* exchangeRateId INT FK exchangeRates
* exchangeRateSnapshot DECIMAL(18,8)
* amountUsd DECIMAL(14,2)
* referenceTypeId INT FK referenceTypes
* referenceId INT
* description VARCHAR(120)
* processingStatusId INT FK processingStatuses
* idempotencyKey VARCHAR(100)
* correlationId VARCHAR(100)
* batchId VARCHAR(100)
* processingNode VARCHAR(100)
* processedAt DATETIME2
* failedAt DATETIME2
* retryCount INT
* previousHash VARBINARY(512)
* currentHash VARBINARY(512)
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_financialMovements_personId_processedAt (personId, processedAt DESC)
* INDEX IX_financialMovements_processingStatusId_processedAt (processingStatusId, processedAt)

---

## financialBalancesHistory

* balanceId BIGINT IDENTITY(1,1) PK
* totalBalanceUsd DECIMAL(16,2)
* calculatedAt DATETIME2
* correlationId VARCHAR(100)
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_financialBalancesHistory_calculatedAt (calculatedAt DESC)

---

## commissions

* commissionId BIGINT IDENTITY(1,1) PK
* commissionTypeId INT FK commissionTypes
* referenceTypeId INT FK referenceTypes
* referenceId INT
* sourceWalletTransactionId BIGINT FK walletTransactions
* financialMovementId BIGINT FK financialMovements
* appliedAmount DECIMAL(16,2)
* percentage DECIMAL(5,2)
* commissionAmount DECIMAL(16,2)
* basePoolAmount DECIMAL(18,2)
* winnerPoolAmount DECIMAL(18,2)
* loserPoolAmount DECIMAL(18,2)
* exchangeRateSnapshot DECIMAL(18,8)
* batchId VARCHAR(100)
* correlationId VARCHAR(100)
* executedAt DATETIME2
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_commissions_sourceWalletTransactionId (sourceWalletTransactionId)
* INDEX IX_commissions_financialMovementId (financialMovementId)

---

## notifications

* notificationId BIGINT IDENTITY(1,1) PK
* notificationTypeId INT FK notificationTypes
* personId INT FK people
* title VARCHAR(120)
* message VARCHAR(255)
* isRead BIT
* readAt DATETIME2
* expiresAt DATETIME2
* referenceTypeId INT FK referenceTypes
* referenceId INT
* correlationId VARCHAR(100)
* auditpersonId INT FK people
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_notifications_personId_isRead_createdAt (personId, isRead, createdAt DESC)

---

## auditLogs

* logId BIGINT IDENTITY(1,1) PK
* tableName VARCHAR(60)
* recordId INT
* actionType VARCHAR(30)
* personId INT FK people
* authSessionId INT FK authSessions
* ipAddress VARCHAR(100)
* userAgent VARCHAR(255)
* requestSource VARCHAR(60)
* operationResult VARCHAR(60)
* correlationId VARCHAR(100)
* processingNode VARCHAR(100)
* actionTimestamp DATETIME2
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_auditLogs_tableName_recordId (tableName, recordId)
* INDEX IX_auditLogs_personId_actionTimestamp (personId, actionTimestamp DESC)
* INDEX IX_auditLogs_correlationId (correlationId)

---

## auditLogDetails

* auditLogDetailId BIGINT IDENTITY(1,1) PK
* logId BIGINT FK auditLogs
* columnName VARCHAR(60)
* oldValue VARCHAR(255)
* newValue VARCHAR(255)
* oldJson NVARCHAR(MAX)
* newJson NVARCHAR(MAX)
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_auditLogDetails_logId (logId)

---

## systemProcessingLogs

* systemProcessingLogId BIGINT IDENTITY(1,1) PK
* processName VARCHAR(120)
* processType VARCHAR(60)
* processingStatusId INT FK processingStatuses
* correlationId VARCHAR(100)
* processingNode VARCHAR(100)
* executionTimeMs INT
* errorMessage VARCHAR(255)
* startedAt DATETIME2
* finishedAt DATETIME2
* createdAt DATETIME2
* updatedAt DATETIME2
* isDeleted BIT

### Performance

* INDEX IX_systemProcessingLogs_processingStatusId_startedAt (processingStatusId, startedAt DESC)
* INDEX IX_systemProcessingLogs_correlationId (correlationId)