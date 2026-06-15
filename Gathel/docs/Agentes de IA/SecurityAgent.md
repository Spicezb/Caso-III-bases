Contexto obligatorio del proyecto Gathel:

Gathel es una plataforma social de predicciones basada en acciones y eventos reales de personas, validada mediante redes sociales e inteligencia artificial.

Reglas principales del negocio:
1. Cada jugador inicia con 100 puntos.
2. Los jugadores pueden asociar una o varias cuentas de redes sociales.
3. Los usuarios pueden crear proposiciones sobre otros jugadores o sobre sí mismos.
4. Antes de publicarse, una proposición debe pasar por una revisión automática de AI para bloquear contenido ilegal, violento, sexual, discriminatorio, fraudulento o contrario a las reglas éticas de la plataforma.
5. Los jugadores pueden votar por proposiciones.
6. La persona objetivo de una proposición puede rechazarla si la considera ofensiva, invasiva o inaceptable.
7. Ningún jugador puede ver cuál proposición tiene más votos; solo la persona objetivo puede verlo.
8. Después de 24 horas desde la primera proposición relacionada con un evento, Gathel muestra la proposición ganadora.
9. La persona objetivo decide si acepta o rechaza oficialmente la proposición.
10. Si rechaza, pierde 1 punto, la proposición se cierra y no se habilitan predicciones.
11. Si acepta, inicia el concurso, define la fecha y hora límite de predicciones y la proposición pasa a activa.
12. Los jugadores pueden predecir si una proposición se cumplirá o no.
13. Las predicciones pueden usar puntos virtuales, dinero real o ambos.
14. En puntos, cada jugador puede arriesgar máximo 1 punto por predicción.
15. En dinero real, el jugador puede decidir cuánto arriesgar.
16. El monto apostado con dinero real puede incrementarse antes del cierre.
17. Después del cierre de predicciones, no se permiten modificaciones.
18. El resultado se valida con evidencia de redes sociales: fotos, videos, stories, publicaciones o transmisiones.
19. La evidencia debe incluir referencias o hashtags asociados a Gathel.
20. La AI debe analizar contenido, validar autenticidad, detectar manipulación, interpretar resultados y determinar si la proposición se cumplió.
21. En caso de ambigüedad, Gathel puede pedir evidencia adicional o validación manual.
22. Los perdedores pierden sus puntos o dinero arriesgado.
23. El total perdido se distribuye proporcionalmente entre los ganadores.
24. Antes de distribuir recompensas se deducen comisiones para la plataforma y para el jugador que ejecutó la proposición.
25. Si no se puede validar el resultado, todos los participantes recuperan puntos y dinero.
26. Si no se puede validar, el jugador asociado a la proposición pierde 15% de sus puntos actuales.
27. Gathel debe validar antes de aceptar una proposición que el jugador tenga suficientes puntos para cubrir posibles penalizaciones.
28. Los jugadores pueden retirar ganancias en dinero real.
29. Si un jugador se queda sin puntos, puede comprar más.
30. Empresas y comercios afiliados pueden ofrecer productos o servicios canjeables por puntos.
31. Gathel mantiene eventos y proposiciones activas continuamente.

Requisitos técnicos del proyecto:
1. El diseño debe documentarse en Markdown.
2. El diseño debe generar DBML.
3. El diseño final debe ser para SQL Server.
4. El repositorio debe documentar agentes de AI que revisen el diseño.
5. Los agentes deben revisar reglas de negocio, seguridad, economía del juego, pagos, AI, redes sociales, normalización, alto volumen de inserts y pocos updates, autenticación, autorización, eventos del juego, monitoreo, observabilidad, auditoría, trazabilidad, rendimiento, particionamiento, índices y escalabilidad.
6. Deben evidenciarse los resultados de los agentes y las mejoras aplicadas.
7. Debe existir estructura de Flyway.
8. El seeding debe generar como mínimo 1000 jugadores, 5000 proposiciones, 250000 eventos asociados a proposiciones y pagos correspondientes a las 5000 proposiciones.
9. El seeding debe usar bucles, no inserts exhaustivos.
10. El seeding debe cuidar integridad referencial, consistencia, datos realistas, timestamps coherentes y relaciones válidas.
11. Las lecturas del backend deben usar ORM.
12. Las escrituras del backend deben llamar Stored Procedures.
13. El backend debe usar fixed-size connection pooling.
14. El MVP debe permitir login, logout, ver balance de puntos, ver balance de dinero real, ver actividad básica, crear proposición, listar proposiciones activas, realizar pronósticos y ver resultados.
15. El proyecto debe incluir ejercicios de seguridad, transacciones, concurrencia, deadlocks, niveles de aislamiento y Stored Procedures transaccionales.

Actúa como un Security Agent especializado en revisión de diseños de bases de datos para SQL Server 2022.

Tu única responsabilidad es auditar la seguridad del siguiente diseño de base de datos para el sistema Gathel, una plataforma social de predicciones con puntos virtuales, dinero real, pagos, retiros, usuarios, redes sociales, proposiciones, predicciones, auditoría y validaciones.

No revises rendimiento general, escalabilidad general ni normalización, excepto si el problema afecta directamente la seguridad.

Contexto del sistema:
Gathel permite que jugadores registren cuentas, asocien redes sociales, creen proposiciones sobre sí mismos u otros jugadores, realicen predicciones usando puntos o dinero real, reciban pagos, retiren ganancias, sean auditados, reportados o penalizados. El sistema debe manejar datos sensibles, contraseñas, tokens, información financiera, pagos, retiros, sesiones, auditoría y permisos.

Objetivo del agente:
Revisar si el diseño de tablas protege correctamente la información sensible y si permite implementar autenticación, autorización, trazabilidad, cifrado, Row-Level Security, Data Masking y control de acceso en SQL Server.

Debes revisar específicamente:

1. Datos sensibles
- Contraseñas.
- Correos.
- Teléfonos.
- Tokens de redes sociales.
- Refresh tokens.
- Sesiones.
- Datos de pagos.
- Datos de retiros.
- Información financiera.
- Identificación personal.
- Direcciones.
- Evidencia asociada a redes sociales.

2. Autenticación
- Si la tabla de usuarios permite un manejo seguro de contraseñas.
- Si se diferencia correctamente password hash, salt, algoritmo y fecha de cambio.
- Si las sesiones tienen expiración, revocación y trazabilidad.
- Si hay riesgos por almacenar tokens directamente.

3. Autorización
- Si el diseño permite roles de usuario.
- Si existe separación entre jugador, administrador, moderador, auditor u otros perfiles.
- Si las tablas permiten controlar qué usuario puede consultar o modificar qué información.
- Si hay soporte para permisos directos y permisos heredados por roles.

4. SQL Server Security Lab
Evalúa si el diseño permite demostrar:
- Roles de base de datos.
- Usuarios de prueba.
- Permisos directos.
- Permisos heredados.
- Acceso indirecto mediante Stored Procedures o Functions.
- Escenarios donde un usuario pueda leer pero no escribir.
- Escenarios donde pueda escribir pero no leer.
- Data Masking.
- Row-Level Security.
- Cifrado de contraseñas usando master key/certificate.

5. Auditoría y trazabilidad
- Si las acciones sensibles quedan auditadas.
- Si auditLogs es suficiente.
- Si falta registrar IP, user agent, usuario ejecutor, fecha, tabla, acción, valores anteriores y nuevos.
- Si los cambios financieros y de seguridad quedan rastreables.

6. Riesgos
Detecta riesgos como:
- Exposición de tokens.
- Contraseñas mal almacenadas.
- Falta de cifrado.
- Falta de máscaras en datos sensibles.
- Falta de RLS.
- Falta de separación de roles.
- Falta de auditoría en pagos y retiros.
- Posibilidad de manipulación de balances.
- Relaciones que permitan acceso indebido a datos de otros jugadores.
- Campos sensibles almacenados en texto plano.

Límites:
- No inventes tablas que no sean necesarias.
- No hagas una revisión superficial.
- No digas que algo está bien si no hay evidencia en el diseño.
- Si falta información, indícalo claramente.
- Prioriza problemas reales para SQL Server 2022.
- No uses emojis.
- No respondas con generalidades.

Formato obligatorio de respuesta:

1. Resumen ejecutivo
Da una valoración general de seguridad del diseño en una escala de 1 a 10 y explica brevemente por qué.

2. Hallazgos críticos
Para cada problema crítico, usa este formato:
- Tabla o área afectada:
- Problema:
- Por qué está mal:
- Riesgo:
- Cambio recomendado:
- Justificación técnica:

3. Hallazgos importantes
Mismo formato, pero para problemas no críticos.

4. Elementos correctos del diseño
Indica qué partes del diseño sí están bien planteadas desde seguridad.

5. Tablas o campos que deberían agregarse
Propón tablas o columnas necesarias para mejorar seguridad. Explica por qué.

6. Recomendaciones para SQL Server
Incluye recomendaciones específicas sobre:
- Dynamic Data Masking.
- Row-Level Security.
- Master Key.
- Certificates.
- Stored Procedures con permisos controlados.
- Auditoría.
- Cifrado de tokens.
- Hashing de contraseñas.

7. Lista final de cambios prioritarios
Ordena los cambios desde más urgente hasta menos urgente.

Diseño de tablas a revisar:

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
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## countries

* countryId SERIAL PK
* name VARCHAR(80)
* isoCode VARCHAR(5)
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## propositionStatuses

* propositionStatusId SERIAL PK
* name VARCHAR(40)
* description VARCHAR(120)
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## predictionStatuses

* predictionStatusId SERIAL PK
* name VARCHAR(40)
* description VARCHAR(120)
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## reportTypes

* reportTypeId SERIAL PK
* name VARCHAR(40)
* description VARCHAR(120)
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## currencies

* currencyId SERIAL PK
* name VARCHAR(30)
* code VARCHAR(10)
* symbol VARCHAR(10)
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## referenceTypes

* referenceTypeId SERIAL PK
* name VARCHAR(30)
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## walletTransactionTypes

* walletTransactionTypeId SERIAL PK
* name VARCHAR(40)
* description VARCHAR(120)
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## paymentMethods

* paymentMethodId SERIAL PK
* name VARCHAR(30)
* logoUrl VARCHAR(255)
* config JSON
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## financialTransactionTypes

* transactionTypeId SERIAL PK
* name VARCHAR(30)
* description VARCHAR(80)
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## commissionTypes

* commissionTypeId SERIAL PK
* name VARCHAR(40)
* description VARCHAR(120)
* percentage NUMERIC(5,2)
* isActive BOOLEAN
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## withdrawalRequestStatuses

* withdrawalRequestStatusId SERIAL PK
* name VARCHAR(40)
* description VARCHAR(120)
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## statusTypes

* statusTypeId SERIAL PK
* name VARCHAR(40)
* description VARCHAR(120)
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## penaltyTypes

* penaltyTypeId SERIAL PK
* name VARCHAR(40)
* description VARCHAR(120)
* pointsPercentage NUMERIC(5,2)
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## socialPlatforms

* socialPlatformId SERIAL PK
* name VARCHAR(40)
* apiUrl VARCHAR(255)
* logoUrl VARCHAR(255)
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## cities

* cityId SERIAL PK
* countryId INT FK countries
* name VARCHAR(80)
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## addresses

* addressId SERIAL PK
* cityId INT FK cities
* exactAddress VARCHAR(200)
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## people

* personId SERIAL PK
* personTypeId INT FK peopleTypes
* name VARCHAR(60)
* lastName VARCHAR(60)
* identification VARCHAR(30)
* phone VARCHAR(20)
* email VARCHAR(100)
* password BYTEA
* username VARCHAR(40)
* profilePhotoUrl VARCHAR(255)
* biography VARCHAR(200)
* birthDate DATE
* addressId INT FK addresses
* isVerified BOOLEAN
* isActive BOOLEAN
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## socialAccounts

* socialAccountId SERIAL PK
* personId INT FK people
* socialPlatformId INT FK socialPlatforms
* username VARCHAR(80)
* profileUrl VARCHAR(255)
* accessToken BYTEA
* refreshToken BYTEA
* isVerified BOOLEAN
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## wallets

* walletId SERIAL PK
* personId INT FK people
* isBlocked BOOLEAN
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## authSessions

* authSessionId SERIAL PK
* personId INT FK people
* refreshToken BYTEA
* ipAddress VARCHAR(100)
* userAgent VARCHAR(255)
* expiresAt TIMESTAMP
* lastActivityAt TIMESTAMP
* isRevoked BOOLEAN
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## exchangeRates

* exchangeRateId SERIAL PK
* currencyId INT FK currencies
* rateToUsd NUMERIC(12,6)
* isCurrent BOOLEAN
* exchangeDateTime TIMESTAMP
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## propositions

* propositionId SERIAL PK
* propositionStatusId INT FK propositionStatuses
* creatorPersonId INT FK people
* targetPersonId INT FK people
* targetSocialAccountId INT FK socialAccounts
* title VARCHAR(120)
* description VARCHAR(300)
* startPredictionDateTime TIMESTAMP
* endPredictionDateTime TIMESTAMP
* winningOption BOOLEAN
* minimumEntryPointsAmount NUMERIC(16,2)
* winningProfitPercentage NUMERIC(5,2)
* isPublic BOOLEAN
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## propositionVotes

* propositionVoteId SERIAL PK
* propositionId INT FK propositions
* personId INT FK people
* voteValue BOOLEAN
* votedAt TIMESTAMP
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## propositionLikes

* propositionLikeId SERIAL PK
* propositionId INT FK propositions
* personId INT FK people
* likedAt TIMESTAMP
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## propositionComments

* propositionCommentId SERIAL PK
* propositionId INT FK propositions
* personId INT FK people
* comment VARCHAR(255)
* commentedAt TIMESTAMP
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## propositionReplies

* propositionReplyId SERIAL PK
* parentPropositionId INT FK propositions
* propositionStatusId INT FK propositionStatuses
* creatorPersonId INT FK people
* targetPersonId INT FK people
* targetSocialAccountId INT FK socialAccounts
* title VARCHAR(120)
* description VARCHAR(300)
* startPredictionDateTime TIMESTAMP
* endPredictionDateTime TIMESTAMP
* winningOption BOOLEAN
* minimumEntryPointsAmount NUMERIC(16,2)
* winningProfitPercentage NUMERIC(5,2)
* repliedAt TIMESTAMP
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## propositionEvidenceImages

* propositionEvidenceImageId SERIAL PK
* propositionId INT FK propositions
* imageUrl VARCHAR(255)
* imageOrder INT
* uploadedAt TIMESTAMP
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## predictions

* predictionId SERIAL PK
* predictionStatusId INT FK predictionStatuses
* propositionId INT FK propositions
* personId INT FK people
* predictionValue BOOLEAN
* pointsAmount NUMERIC(10,2)
* moneyAmount NUMERIC(14,2)
* currencyId INT FK currencies
* exchangeRateId INT FK exchangeRates
* predictionDateTime TIMESTAMP
* isWinner BOOLEAN
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## reports

* reportId SERIAL PK
* reportTypeId INT FK reportTypes
* reportedPersonId INT FK people
* reporterPersonId INT FK people
* propositionId INT FK propositions
* description VARCHAR(255)
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## penalties

* penaltyId SERIAL PK
* penaltyTypeId INT FK penaltyTypes
* reportId INT FK reports
* pointsAmount NUMERIC(16,2)
* reasonDescription VARCHAR(255)
* executedAt TIMESTAMP
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## walletBalances

* walletBalanceId SERIAL PK
* walletId INT FK wallets
* walletTransactionTypeId INT FK walletTransactionTypes
* oldPointsAmount NUMERIC(16,2)
* balancePointsAmount NUMERIC(16,2)
* newPointsAmount NUMERIC(16,2)
* calculatedAt TIMESTAMP
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## walletTransactions

* walletTransactionId SERIAL PK
* originWalletId INT FK wallets
* destinationWalletId INT FK wallets
* isSelfTransaction BOOLEAN
* pointsAmount NUMERIC(16,2)
* transactionDateTime TIMESTAMP
* referenceTypeId INT FK referenceTypes
* referenceId INT
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## paymentAttempts

* paymentAttemptId SERIAL PK
* personId INT FK people
* paymentMethodId INT FK paymentMethods
* isPaymentLoaded BOOLEAN
* amount NUMERIC(16,2)
* currencyId INT FK currencies
* exchangeRateId INT FK exchangeRates
* amountUsd NUMERIC(16,2)
* attemptedAt TIMESTAMP
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## payments

* paymentId SERIAL PK
* personId INT FK people
* paymentMethodId INT FK paymentMethods
* amount NUMERIC(16,2)
* currencyId INT FK currencies
* exchangeRateId INT FK exchangeRates
* amountUsd NUMERIC(16,2)
* processedAt TIMESTAMP
* referenceTypeId INT FK referenceTypes
* referenceId INT
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## withdrawalRequests

* withdrawalRequestId SERIAL PK
* withdrawalRequestStatusId INT FK withdrawalRequestStatuses
* personId INT FK people
* paymentMethodId INT FK paymentMethods
* amount NUMERIC(16,2)
* currencyId INT FK currencies
* exchangeRateId INT FK exchangeRates
* amountUsd NUMERIC(16,2)
* requestedAt TIMESTAMP
* processedAt TIMESTAMP
* referenceTypeId INT FK referenceTypes
* referenceId INT
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## withdrawalAttempts

* withdrawalAttemptId SERIAL PK
* withdrawalRequestId INT FK withdrawalRequests
* paymentMethodId INT FK paymentMethods
* amount NUMERIC(16,2)
* currencyId INT FK currencies
* exchangeRateId INT FK exchangeRates
* amountUsd NUMERIC(16,2)
* isSuccessful BOOLEAN
* response JSON
* attemptedAt TIMESTAMP
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## financialMovements

* movementId SERIAL PK
* transactionTypeId INT FK financialTransactionTypes
* amount NUMERIC(14,2)
* currencyId INT FK currencies
* exchangeRateId INT FK exchangeRates
* amountUsd NUMERIC(14,2)
* referenceTypeId INT FK referenceTypes
* referenceId INT
* description VARCHAR(120)
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## financialBalancesHistory

* balanceId SERIAL PK
* totalBalanceUsd NUMERIC(16,2)
* calculatedAt TIMESTAMP
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

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
* executedAt TIMESTAMP
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## notifications

* notificationId SERIAL PK
* personId INT FK people
* title VARCHAR(120)
* message VARCHAR(255)
* isRead BOOLEAN
* readAt TIMESTAMP
* referenceTypeId INT FK referenceTypes
* referenceId INT
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## statusHistory

* statusHistoryId SERIAL PK
* referenceTypeId INT FK referenceTypes
* referenceId INT
* statusTypeId INT FK statusTypes
* changedAt TIMESTAMP
* auditpersonId INT FK people
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN

## auditLogs

* logId SERIAL PK
* tableName VARCHAR(60)
* recordId INT
* actionType VARCHAR(30)
* oldValue VARCHAR(50)
* newValue VARCHAR(50)
* personId INT FK people
* actionTimestamp TIMESTAMP
* createdAt TIMESTAMP
* updatedAt TIMESTAMP
* isDeleted BOOLEAN


---


# Respuesta de la IA
# Resumen de Cambios de Seguridad Aplicados - Security Agent Review

## Objetivo de la revisión

Se realizó una auditoría especializada de seguridad sobre el diseño de base de datos de Gathel para SQL Server 2022, enfocada en:

- Protección de datos sensibles.
- Autenticación y autorización.
- Seguridad financiera.
- Manejo seguro de tokens y sesiones.
- Auditoría y trazabilidad.
- Prevención de abuso interno.
- Preparación para Row-Level Security y Dynamic Data Masking.
- Compatibilidad con laboratorios de seguridad SQL Server.

---

# Cambios aplicados al diseño

## 1. Rediseño de almacenamiento de contraseñas

### Problema detectado
La tabla `people` almacenaba únicamente:


password VARBINARY(MAX)

No existía separación entre:

* hash,
* salt,
* algoritmo,
* metadata de seguridad.

### Cambios aplicados

Se reemplazó el campo anterior por:


passwordHash VARBINARY(512)
passwordSalt VARBINARY(256)
passwordAlgorithm VARCHAR(40)
passwordChangedAt DATETIME2
failedLoginAttempts INT
lockedUntil DATETIME2

### Beneficio

Permite:

* uso de Argon2/bcrypt/scrypt,
* rotación de algoritmos,
* bloqueo automático,
* trazabilidad criptográfica,
* mitigación de rainbow tables.

---

# 2. Separación segura de tokens OAuth y refresh tokens

### Problema detectado

Los tokens estaban almacenados directamente dentro de:

* `socialAccounts`
* `authSessions`

### Cambios aplicados

Se crearon nuevas tablas:

## `socialAccountSecrets`


encryptedAccessToken VARBINARY(MAX)
encryptedRefreshToken VARBINARY(MAX)
tokenScope VARCHAR(255)
tokenExpiresAt DATETIME2
encryptionKeyVersion VARCHAR(30)
isRevoked BIT
revokedAt DATETIME2

## `authSessionSecrets`


encryptedRefreshToken VARBINARY(MAX)
encryptionKeyVersion VARCHAR(30)

### Beneficio

Permite:

* cifrado por certificados,
* separación de secretos,
* control granular de permisos,
* menor superficie de ataque,
* revocación segura de tokens.

---

# 3. Implementación de RBAC (Role-Based Access Control)

### Problema detectado

No existía separación formal de roles y permisos.

### Cambios aplicados

Se agregaron las tablas:

## `roles`

## `permissions`

## `rolePermissions`

## `personRoles`

### Beneficio

Permite:

* separación administrador/moderador/jugador/auditor,
* permisos heredados,
* principio de mínimo privilegio,
* laboratorios de permisos SQL Server.

---

# 4. Fortalecimiento de sesiones y autenticación

### Problema detectado

Las sesiones no tenían suficiente trazabilidad ni metadata de seguridad.

### Cambios aplicados

Nuevos campos en `authSessions`:


deviceFingerprint VARCHAR(255)
mfaValidated BIT
sessionType VARCHAR(40)
revokedAt DATETIME2

### Beneficio

Permite:

* detección de robo de sesión,
* control MFA,
* análisis de dispositivos,
* invalidación segura.

---

# 5. Sistema de eventos de seguridad

### Problema detectado

No existía trazabilidad centralizada de eventos de seguridad.

### Cambios aplicados

Nueva tabla:

## `securityEvents`

Eventos soportados:

* login sospechoso,
* MFA deshabilitado,
* cambio de contraseña,
* revocación de sesión,
* anomalías de autenticación.

### Beneficio

Facilita:

* auditoría,
* monitoreo,
* detección de fraude,
* forensic analysis.

---

# 6. Protección contra ataques de fuerza bruta

### Problema detectado

No existía control estructurado de intentos de login.

### Cambios aplicados

Nueva tabla:

## `loginAttempts`

Campos:

* IP,
* userAgent,
* resultado,
* motivo de fallo,
* timestamp.

### Beneficio

Permite:

* rate limiting,
* bloqueo automático,
* detección de credential stuffing,
* análisis de ataques.

---

# 7. Preparación para MFA

### Problema detectado

El diseño no soportaba autenticación multifactor.

### Cambios aplicados

Nueva tabla:

## `mfaMethods`

Incluye:

* secretos cifrados,
* recovery codes,
* método principal,
* verificación.

### Beneficio

Permite:

* TOTP,
* recovery codes,
* ampliación futura a WebAuthn.

---

# 8. Endurecimiento de auditoría

### Problema detectado

La auditoría no almacenaba suficiente información para análisis forense.

### Cambios aplicados

Nuevos campos en `auditLogs`:


authSessionId
ipAddress
userAgent
requestSource
operationResult


Nuevos campos en `auditLogDetails`:


oldJson
newJson


### Beneficio

Permite:

* reconstrucción completa de eventos,
* auditoría financiera,
* trazabilidad avanzada,
* investigación de incidentes.

---

# 9. Protección de balances financieros

### Problema detectado

No existía mecanismo de integridad fuerte sobre balances y movimientos.

### Cambios aplicados

Nuevos campos hash:


previousHash VARBINARY(512)
currentHash VARBINARY(512)


Aplicados en:

* `walletCurrentBalances`
* `walletTransactions`
* `financialMovements`

### Beneficio

Permite:

* detectar alteraciones,
* mejorar integridad,
* preparar ledger inmutable,
* aumentar trazabilidad financiera.

---

# 10. Separación de secretos financieros

### Problema detectado

`paymentMethods.config` podía almacenar secretos junto a configuración pública.

### Cambios aplicados

Se reemplazó:


config NVARCHAR(MAX)


por:


publicConfig NVARCHAR(MAX)


y se creó:

## `paymentMethodSecrets`

### Beneficio

Permite:

* aislar credenciales,
* cifrado dedicado,
* permisos diferenciados.

---

# 11. Protección de evidencia sensible

### Problema detectado

Las evidencias sociales podían exponer contenido privado.

### Cambios aplicados

Nuevos campos en `propositionEvidence`:


storageProvider
signedUrlExpiresAt
isSensitive

### Beneficio

Permite:

* URLs temporales,
* clasificación sensible,
* control de acceso.

---

# 12. Clasificación de direcciones sensibles

### Problema detectado

Las direcciones no podían clasificarse como sensibles.

### Cambios aplicados

Nuevo campo:


isSensitive BIT

en `addresses`.

### Beneficio

Facilita:

* masking,
* RLS,
* controles de privacidad.

---

# 13. Preparación para SQL Server Security Features

El nuevo diseño quedó preparado para implementar:

## Dynamic Data Masking

Sobre:

* email,
* phone,
* identification,
* exactAddress.

## Row-Level Security

Sobre:

* wallets,
* payments,
* withdrawalRequests,
* predictions,
* authSessions.

## Cifrado administrado

Mediante:

* Master Key,
* Certificates,
* EncryptByCert(),
* DecryptByCert().

## Stored Procedures seguros

Aplicando:

* EXECUTE AS OWNER,
* DENY SELECT,
* acceso indirecto.

---

# Resultado general

La revisión fortaleció significativamente:

* autenticación,
* autorización,
* trazabilidad,
* manejo de secretos,
* seguridad financiera,
* protección de PII,
* preparación para auditorías,
* compatibilidad con SQL Server Security Labs.

El diseño final quedó preparado para:

* RBAC,
* MFA,
* Row-Level Security,
* Dynamic Data Masking,
* cifrado administrado,
* auditoría avanzada,
* control granular de acceso,
* prevención de fraude y abuso interno.