# "Gathel, Gaming the Life"

# Info
- Database engine: Microsoft SQL Server 2022
- Database name: Gathel
- Context: El sistema de base de datos está diseñado para soportar las operaciones de una plataforma social de predicciones y apuestas digitales basada en eventos y acciones de la vida real de las personas, como Gathel. Su propósito es centralizar y gestionar la información relacionada con jugadores, proposiciones, predicciones, wallets virtuales, pagos en dinero real, validaciones, reportes, penalizaciones y actividad social dentro de la plataforma. Este sistema permite dar trazabilidad completa a las interacciones, movimientos financieros, estados de las proposiciones y resultados de predicciones, integrando procesos sociales, financieros, de auditoría y validación automática en una sola estructura de datos orientada a alta concurrencia, trazabilidad y escalabilidad.

---

# Tables

## peopleTypes

* peopleTypeId SERIAL PK
* name VARCHAR(30)
* description VARCHAR(100)
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## countries

* countryId SERIAL PK
* name VARCHAR(80)
* isoCode VARCHAR(5)
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## reportTypes

* reportTypeId SERIAL PK
* name VARCHAR(40) UNIQUE
* description VARCHAR(120)
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## currencies

* currencyId SERIAL PK
* name VARCHAR(30)
* code VARCHAR(10) UNIQUE
* symbol VARCHAR(10)
* auditpersonId INT FK people
* isDefaultCurrencie BOOLEAN (DEFAULT 0)
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## referenceTypes

* referenceTypeId SERIAL PK
* name VARCHAR(30)
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## paymentMethods

* paymentMethodId SERIAL PK
* name VARCHAR(30)
* logo INT FK files
* config JSON
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## commissionTypes

* commissionTypeId SERIAL PK
* name VARCHAR(40)
* description VARCHAR(120)
* percentage NUMERIC(5,2)
* isActive BOOLEAN (DEFAULT 1)
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## statusTypes 

* statusTypeId SERIAL PK
* name VARCHAR(40)
* description VARCHAR(120)
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## penaltyTypes

* penaltyTypeId SERIAL PK
* name VARCHAR(40) UNIQUE
* description VARCHAR(120)
* pointsPercentage NUMERIC(5,2)
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## socialPlatforms

* socialPlatformId SERIAL PK
* name VARCHAR(40)
* apiUrl VARCHAR(255)
* logo INT FK files
* config JSON
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## states

* stateId SERIAL PK
* countryId INT FK countries
* name VARCHAR(80)
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## cities

* cityId SERIAL PK
* stateId INT FK states
* name VARCHAR(80)
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## addresses

* addressId SERIAL PK
* cityId INT FK cities
* exactAddress VARCHAR(200)
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## people

* personId SERIAL PK
* peopleTypeId INT FK peopleTypes
* name VARCHAR(60)
* lastName VARCHAR(60)
* identification VARCHAR(30)
* phone VARCHAR(20)
* email VARCHAR(100)
* passwordHash BYTEA
* username VARCHAR(40)
* biography VARCHAR(200)
* birthDate DATE
* addressId INT FK addresses
* isVerified BOOLEAN (DEFAULT 0)
* isActive BOOLEAN (DEFAULT 0)
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

UNIQUE(email)
UNIQUE(username)
UNIQUE(identification)

## socialAccounts

* socialAccountId SERIAL PK
* personId INT FK people
* socialPlatformId INT FK socialPlatforms
* username VARCHAR(80)
* profileUrl VARCHAR(255)
* accessToken BYTEA
* refreshToken BYTEA
* isVerified BOOLEAN (DEFAULT 0)
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

UNIQUE(socialPlatformId, username)

## wallets

* walletId SERIAL PK
* personId INT FK people
* isBlocked BOOLEAN (DEFAULT 0)
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## authSessions

* authSessionId SERIAL PK
* personId INT FK people
* refreshToken BYTEA
* ipAddress VARCHAR(100)
* expiresAt timestamp (DEFAULT GETDATE())
* lastActivityAt timestamp (DEFAULT GETDATE())
* isRevoked BOOLEAN (DEFAULT 0)
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## exchangeRates

* exchangeRateId SERIAL PK
* currencyId INT FK currencies
* rate NUMERIC(12,6)
* isCurrent BOOLEAN (DEFAULT 0)
* exchangeDateTime timestamp (DEFAULT GETDATE())
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## propositions

* propositionId SERIAL PK
* parentproposition INT FK propositions (Default NULL)
* statusTypesId INT FK statusTypes
* creatorPersonId INT FK people
* targetPersonId INT FK people
* targetSocialAccountId INT FK socialAccounts
* title VARCHAR(120)
* description VARCHAR(300)
* startPredictionDateTime timestamp (DEFAULT GETDATE())
* endPredictionDateTime timestamp (DEFAULT GETDATE())
* winningOption BOOLEAN
* minimumEntryPointsAmount NUMERIC(16,2)
* winningProfitPercentage NUMERIC(5,2)
* isPublic BOOLEAN (DEFAULT 1)
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## propositionVotes

* propositionVoteId SERIAL PK
* propositionId INT FK propositions
* personId INT FK people
* voteValue BOOLEAN
* votedAt timestamp (DEFAULT GETDATE())
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

UNIQUE(propositionId, personId)

## propositionLikes

* propositionLikeId SERIAL PK
* propositionId INT FK propositions
* personId INT FK people
* likedAt timestamp (DEFAULT GETDATE())
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

UNIQUE(propositionId, personId)

## propositionComments

* propositionCommentId SERIAL PK
* propositionId INT FK propositions
* personId INT FK people
* comment VARCHAR(255)
* commentedAt timestamp (DEFAULT GETDATE())
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## fileTypes

* fileTypeId SERIAL PK
* name VARCHAR(20)
* mimeType VARCHAR(100)
* description VARCHAR(120)
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## files

* fileId SERIAL PK
* fileTypeId INT FK fileTypes
* fileName VARCHAR(255)
* fileUrl VARCHAR(255)
* fileSize BIGINT
* uploadedByPersonId INT FK people
* uploadedAt timestamp (DEFAULT GETDATE())
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## fileUsageTypes

* fileUsageTypeId SERIAL PK
* name VARCHAR(40)
* description VARCHAR(120)
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## fileReferences

* fileReferenceId SERIAL PK
* fileId INT FK files
* referenceTypeId INT FK referenceTypes
* referenceId INT
* fileUsageTypeId INT FK fileUsageTypes
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## predictions

* predictionId SERIAL PK
* statusTypesId INT FK statusTypes
* propositionId INT FK propositions
* personId INT FK people
* predictionValue BOOLEAN
* pointsAmount NUMERIC(10,2)
* moneyAmount NUMERIC(14,2)
* currencyId INT FK currencies
* exchangeRateId INT FK exchangeRates
* predictionDateTime timestamp (DEFAULT GETDATE())
* isWinner BOOLEAN (DEFAULT 0)
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## reports

* reportId SERIAL PK
* reportTypeId INT FK reportTypes
* reportedPersonId INT FK people
* reporterPersonId INT FK people
* propositionId INT FK propositions
* description VARCHAR(255)
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## penalties

* penaltyId SERIAL PK
* penaltyTypeId INT FK penaltyTypes
* reportId INT FK reports
* pointsAmount NUMERIC(16,2)
* reasonDescription VARCHAR(255)
* executedAt timestamp (DEFAULT GETDATE())
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## walletBalances

* walletBalanceId SERIAL PK
* walletId INT FK wallets
* statusTypeId INT FK statusTypes
* oldPointsAmount NUMERIC(16,2)
* balancePointsAmount NUMERIC(16,2)
* newPointsAmount NUMERIC(16,2)
* calculatedAt timestamp (DEFAULT GETDATE())
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## walletTransactions

* walletTransactionId SERIAL PK
* originWalletId INT FK wallets
* destinationWalletId INT FK wallets
* isSelfTransaction BOOLEAN (DEFAULT 0)
* pointsAmount NUMERIC(16,2)
* transactionDateTime timestamp (DEFAULT GETDATE())
* referenceTypeId INT FK referenceTypes
* referenceId INT
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## transactionTypes

* transactionTypeId SERIAL PK
* name VARCHAR(40)
* description VARCHAR(120)
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## transactionAttempts

* transactionAttemptId SERIAL PK
* transactionTypeId INT FK transactionTypes
* personId INT FK people
* paymentMethodId INT FK paymentMethods
* istransactionLoaded BOOLEAN (DEFAULT 0)
* amount NUMERIC(16,2)
* currencyId INT FK currencies
* exchangeRateId INT FK exchangeRates
* exchangedAmount NUMERIC(16,2)
* attemptedAt timestamp (DEFAULT GETDATE())
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## transactions

* transactionId SERIAL PK
* transactionAttemptId FK transactionAttempts
* personId INT FK people
* transactionTypeId INT FK transactionTypes
* paymentMethodId INT FK paymentMethods
* amount NUMERIC(16,2)
* currencyId INT FK currencies
* exchangeRateId INT FK exchangeRates
* exchangedAmount NUMERIC(16,2)
* processedAt timestamp (DEFAULT GETDATE())
* referenceTypeId INT FK referenceTypes
* referenceId INT
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## financialMovements

* movementId SERIAL PK
* transactionTypeId INT FK transactionTypes
* amount NUMERIC(14,2)
* currencyId INT FK currencies
* exchangeRateId INT FK exchangeRates
* exchangedAmount NUMERIC(14,2)
* referenceTypeId INT FK referenceTypes
* referenceId INT
* description VARCHAR(120)
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## financialBalancesHistory

* balanceId SERIAL PK
* totalBalance NUMERIC(16,2)
* calculatedAt timestamp (DEFAULT GETDATE())
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## commissions

* commissionId SERIAL PK
* commissionTypeId INT FK commissionTypes
* referenceTypeId INT FK referenceTypes
* referenceId INT
* sourceWalletTransactionId INT FK walletTransactions
* financialMovementId INT FK financialMovements
* appliedAmount NUMERIC(16,2)
* percentage NUMERIC(5,2)
* commissionAmount NUMERIC(16,2)
* executedAt timestamp (DEFAULT GETDATE())
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## notificationTypes

* notificationTypeId SERIAL PK
* name VARCHAR(40) UNIQUE
* description VARCHAR(120)
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## notifications

* notificationId SERIAL PK
* notificationTypeId INT FK notificationTypes
* personId INT FK people
* title VARCHAR(120)
* message VARCHAR(255)
* isRead BOOLEAN
* readAt timestamp (DEFAULT GETDATE())
* referenceTypeId INT FK referenceTypes
* referenceId INT
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## statusHistory

* statusHistoryId SERIAL PK
* referenceTypeId INT FK referenceTypes
* referenceId INT
* statusTypeId INT FK statusTypes
* changedAt timestamp (DEFAULT GETDATE())
* auditpersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## auditLogs

* logId SERIAL PK
* referenceTypeId INT FK referenceTypes 
* referenceId INT
* actionType VARCHAR(30)
* oldValue VARCHAR(500)
* newValue VARCHAR(500)
* personId INT FK people
* actiontimestamp (DEFAULT GETDATE()) timestamp (DEFAULT GETDATE())
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## predictionPayouts 

* predictionPayoutId SERIAL PK 
* predictionId FK predictions
* walletTransactionId FK walletTransactions
* moneyPayoutAmount NUMERIC(8,2)
* pointsPayoutAmount NUMERIC(8,2)
* commissionAmount NUMERIC(8,2)
* executedAt TIMESTAMP (DEFAULT GETDATE())
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isdeleted BOOLEAN (DEFAULT 0)

## walletReservations

* walletReservationId SERIAL PK
* walletId INT FK wallets
* predictionId INT FK predictions
* reservedPointsAmount NUMERIC(16,2)
* reservedMoneyAmount NUMERIC(16,2)
* statusTypeId INT FK statusTypes
* reservedAt timestamp (DEFAULT GETDATE())
* releasedAt timestamp DEFAULT NULL
* auditPersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isDeleted BOOLEAN (DEFAULT 0)

## aiValidationResults

* validationId SERIAL PK
* propositionId INT FK propositions
* statusTypeId INT FK statusTypes
* aiComments VARCHAR(500)
* auditPersonId INT FK people
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isDeleted BOOLEAN (DEFAULT 0)

## securityEventTypes

* securityEventTypeId SERIAL PK
* name VARCHAR(50) UNIQUE
* description VARCHAR(200)
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isDeleted BOOLEAN (DEFAULT 0)

## securityEvents

* securityEventId SERIAL PK
* securityEventTypeId INT FK securityEventTypes
* personId INT FK people 
* authSessionId INT FK authSessions
* eventDateTime timestamp (DEFAULT GETDATE())
* details VARCHAR(500)
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isDeleted BOOLEAN (DEFAULT 0)

## permissionTypes

* permissionTypeId SERIAL PK
* name VARCHAR(20)
* description VARCHAR(100)
* createdAt timestamp (DEFAULT CURRENT_TIMESTAMP)
* updatedAt timestamp (DEFAULT CURRENT_TIMESTAMP)
* isDeleted BOOLEAN (DEFAULT FALSE)

## permissions

* permissionId SERIAL PK
* permissionTypeId INT FK permissionTypes UNIQUE
* referenceTypeId INT FK referenceTypes UNIQUE
* createdAt timestamp (DEFAULT CURRENT_TIMESTAMP)
* updatedAt timestamp (DEFAULT CURRENT_TIMESTAMP)
* isDeleted BOOLEAN (DEFAULT FALSE)

## rolePermissions

* rolePermissionId SERIAL PK
* peopleTypeId INT FK peopleTypes UNIQUE
* permissionId INT FK permissions UNIQUE
* createdAt timestamp (DEFAULT CURRENT_TIMESTAMP)
* updatedAt timestamp (DEFAULT CURRENT_TIMESTAMP)
* isDeleted BOOLEAN (DEFAULT FALSE)

## peoplePermissions

* peoplePermissionId SERIAL PK
* peopleId INT FK people UNIQUE
* permissionId INT FK permissions UNIQUE
* createdAt timestamp (DEFAULT CURRENT_TIMESTAMP)
* updatedAt timestamp (DEFAULT CURRENT_TIMESTAMP)
* isDeleted BOOLEAN (DEFAULT FALSE)

## followRequests

* followRequestId SERIAL PK
* senderPersonId INT FK people UNIQUE
* receiverPersonId INT FK people UNIQUE
* statusTypeId INT FK statusTypes
* requestDate timestamp (DEFAULT GETDATE())
* responseDate timestamp NULL
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isDeleted BOOLEAN (DEFAULT 0)

## follows

* followId SERIAL PK
* followerPersonId INT FK people UNIQUE
* followedPersonId INT FK people UNIQUE
* followDate timestamp (DEFAULT GETDATE())
* createdAt timestamp (DEFAULT GETDATE())
* updatedAt timestamp (DEFAULT GETDATE())
* isDeleted BOOLEAN (DEFAULT 0)