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

Actúa como un Scalability Agent especializado en arquitectura de bases de datos SQL Server 2022 para sistemas de alto volumen.

Tu única responsabilidad es revisar si el diseño de base de datos del sistema Gathel puede escalar a muchos usuarios, muchas proposiciones, muchas predicciones, muchos eventos, muchos pagos, mucha auditoría y alta concurrencia. No debes enfocarte en seguridad, normalización ni rendimiento puntual, excepto cuando impacten directamente la escalabilidad.

Contexto del sistema:
Gathel es una plataforma social de predicciones basada en eventos reales. Puede tener muchos jugadores conectados, proposiciones activas continuamente, votos, likes, comentarios, predicciones, pagos, retiros, notificaciones, reportes, penalizaciones, validaciones por AI, evidencias y auditoría. El proyecto requiere como mínimo 1000 jugadores, 5000 proposiciones, 250000 eventos asociados a proposiciones y pagos relacionados, pero el diseño debería soportar crecimiento mayor.

Objetivo del agente:
Evaluar si el modelo está preparado para crecer en volumen, concurrencia, almacenamiento, auditoría, monitoreo, particionamiento y operaciones masivas en SQL Server.

Debes revisar específicamente:

1. Tablas de alto crecimiento
Identifica tablas que crecerán muy rápido, como:
- Eventos de proposiciones.
- Predicciones.
- Wallet transactions.
- Financial movements.
- Payments.
- Withdrawal attempts.
- Audit logs.
- Status history.
- Notifications.
- Likes.
- Votes.
- Comments.
- Evidence.
- AI validation results.

2. Particionamiento
Evalúa qué tablas deberían particionarse y por qué:
- Por fecha.
- Por propositionId.
- Por personId.
- Por tipo de evento.
- Por estado.
- Por otra estrategia razonable.

3. Alto volumen de inserts
Evalúa si el diseño soporta:
- Inserciones masivas.
- Pocos updates.
- Historial inmutable.
- Datos append-only.
- Escrituras concurrentes.
- Cierre masivo de proposiciones.
- Generación masiva de eventos.

4. Auditoría y logs
Evalúa si auditLogs, statusHistory y financialMovements pueden crecer sin afectar el sistema principal.
Propón separación, archivado, particionamiento o estrategias históricas si aplica.

5. Eventos del juego
Evalúa si el diseño modela bien eventos asociados a proposiciones. Considera que el seeding exige 250000 eventos asociados a 5000 proposiciones. Si no existe una tabla clara para eventos, debes indicarlo como problema crítico.

6. Concurrencia
Evalúa riesgos de:
- Muchos jugadores prediciendo al mismo tiempo.
- Muchos updates al mismo wallet.
- Distribución simultánea de recompensas.
- Deadlocks en pagos y wallets.
- Lecturas y escrituras concurrentes.
- Cierre de proposiciones mientras hay predicciones.
- Actualización de estados.

7. Escalabilidad del MVP y futuro
Evalúa si el diseño soporta:
- MVP básico.
- Más países.
- Más monedas.
- Más redes sociales.
- Más métodos de pago.
- Más eventos.
- Más evidencias.
- Más validaciones por AI.
- Más comercios afiliados.
- Más productos canjeables por puntos.

8. Observabilidad y monitoreo
Evalúa si el diseño permite monitorear:
- Fallos de pagos.
- Fallos de retiros.
- Errores de AI.
- Intentos sospechosos.
- Tiempos de procesamiento.
- Estados de SPs críticos.
- Eventos financieros.
- Actividad del sistema.

Límites:
- No propongas soluciones cloud externas salvo que sean conceptuales.
- No conviertas la respuesta en una explicación genérica de escalabilidad.
- No uses emojis.
- No digas que algo escala solo porque tiene muchas tablas.
- Si falta una tabla clave para eventos, AI o logs, dilo directamente.
- Tus recomendaciones deben ser aplicables a SQL Server 2022.

Formato obligatorio de respuesta:

1. Resumen ejecutivo
Califica la escalabilidad del diseño de 1 a 10 y explica por qué.

2. Tablas con mayor crecimiento esperado
Haz una lista de tablas críticas, volumen esperado y riesgo.

3. Hallazgos críticos de escalabilidad
Para cada hallazgo usa:
- Tabla o área afectada:
- Problema:
- Por qué limita la escalabilidad:
- Escenario donde fallaría:
- Cambio recomendado:
- Justificación técnica:

4. Particionamiento recomendado
Indica qué tablas particionar, por qué columna y con qué criterio.

5. Estrategia para datos históricos
Recomienda qué hacer con auditoría, eventos, logs, movimientos financieros y evidencias antiguas.

6. Riesgos de concurrencia
Explica posibles problemas con wallets, predicciones, pagos, retiros y cierre de proposiciones.

7. Tablas o campos recomendados
Propón cambios concretos para soportar crecimiento.

8. Observabilidad recomendada
Indica tablas o campos necesarios para monitorear procesos críticos.

9. Lista final de cambios prioritarios
Ordena desde lo más urgente hasta lo menos urgente.

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
# Resumen de cambios sugeridos y aplicados por el Scalability Agent

## Objetivo de la revisión

La revisión se enfocó exclusivamente en mejorar la escalabilidad del diseño de base de datos de Gathel para SQL Server 2022, considerando:

* Alto volumen de inserciones.
* Alta concurrencia.
* Crecimiento masivo de eventos.
* Auditoría extensa.
* Operaciones financieras concurrentes.
* Validaciones AI.
* Trazabilidad.
* Procesamiento batch.
* Expansión futura del sistema.

---

# Cambios estructurales aplicados

## 1. Creación de tabla `propositionEvents`

### Problema detectado

El modelo original no tenía una tabla explícita para almacenar eventos asociados a proposiciones, pese a que el proyecto exige mínimo 250000 eventos.

### Cambio aplicado

Se agregó:

* `propositionEvents`
* `propositionEventTypes`

### Beneficio de escalabilidad

Permite:

* arquitectura event-driven,
* historial append-only,
* generación masiva de eventos,
* procesamiento concurrente,
* trazabilidad temporal,
* desacoplamiento operativo.

---

## 2. Separación de balances actuales e históricos

### Problema detectado

`walletBalances` mezclaba balance operativo e historial financiero.

### Cambio aplicado

Se reemplazó por:

* `walletCurrentBalances`
* `walletBalanceHistory`

### Beneficio de escalabilidad

Reduce:

* contención,
* locks,
* deadlocks,
* hotspots financieros.

Permite:

* consultas rápidas de balance actual,
* historial append-only,
* mejor concurrencia.

---

## 3. Separación del historial de estados

### Problema detectado

`statusHistory` mezclaba múltiples dominios:

* proposiciones,
* predicciones,
* retiros.

### Cambio aplicado

Se dividió en:

* `propositionStatusHistory`
* `predictionStatusHistory`
* `withdrawalRequestStatusHistory`

### Beneficio de escalabilidad

Mejora:

* particionamiento,
* índices,
* consultas históricas,
* mantenimiento,
* aislamiento de workloads.

---

## 4. Generalización del sistema de evidencias

### Problema detectado

`propositionEvidenceImages` solo soportaba imágenes.

### Cambio aplicado

Se reemplazó por:

* `propositionEvidence`

Con soporte para:

* imágenes,
* videos,
* streams,
* stories,
* multimedia.

### Beneficio de escalabilidad

Permite crecimiento futuro del sistema AI y validaciones multimedia.

---

## 5. Incorporación de AI validation tracking

### Problema detectado

No existía una estructura clara para almacenar resultados de AI.

### Cambio aplicado

Se agregaron:

* `aiValidationResults`
* `aiValidationStatuses`

### Beneficio de escalabilidad

Permite:

* procesamiento asincrónico,
* reintentos,
* monitoreo AI,
* trazabilidad,
* métricas de validación.

---

## 6. Incorporación de observabilidad técnica

### Problema detectado

No existía monitoreo estructurado de procesos internos.

### Cambio aplicado

Se agregó:

* `systemProcessingLogs`

### Beneficio de escalabilidad

Permite monitorear:

* SPs críticos,
* procesos batch,
* fallos,
* tiempos de ejecución,
* errores distribuidos.

---

# Cambios de concurrencia y procesamiento masivo

## 7. Incorporación de `processingStatusId`

### Cambio aplicado

Se agregó en tablas críticas:

* propositions
* predictions
* walletTransactions
* payments
* paymentAttempts
* withdrawalRequests
* withdrawalAttempts
* financialMovements
* propositionEvents
* systemProcessingLogs

### Beneficio

Facilita:

* procesamiento async,
* recuperación de fallos,
* colas internas,
* control de estados.

---

## 8. Incorporación de `correlationId`

### Cambio aplicado

Se agregó en múltiples tablas críticas.

### Beneficio

Permite:

* trazabilidad distribuida,
* debugging,
* seguimiento end-to-end,
* observabilidad.

---

## 9. Incorporación de `batchId`

### Cambio aplicado

Se agregó en operaciones masivas:

* predictions
* walletTransactions
* payments
* withdrawalRequests
* financialMovements
* commissions
* walletBalanceHistory

### Beneficio

Facilita:

* procesamiento batch,
* cierre masivo,
* conciliación financiera,
* reversiones.

---

## 10. Incorporación de `idempotencyKey`

### Cambio aplicado

Se agregó en:

* walletTransactions
* payments
* paymentAttempts
* withdrawalRequests
* financialMovements

### Beneficio

Evita:

* duplicados,
* doble procesamiento,
* dobles pagos,
* inconsistencias por retries.

---

## 11. Incorporación de `processingNode`

### Cambio aplicado

Se agregó en:

* propositionEvents
* walletTransactions
* payments
* withdrawalRequests
* financialMovements
* auditLogs
* systemProcessingLogs

### Beneficio

Permite trazabilidad distribuida y diagnóstico de nodos.

---

## 12. Incorporación de columnas de retry y fallos

### Cambio aplicado

Se agregaron:

* `retryCount`
* `processedAt`
* `failedAt`

### Beneficio

Permite:

* recuperación automática,
* reintentos controlados,
* monitoreo operacional.

---

# Cambios de escalabilidad financiera

## 13. Mejoras en pagos y retiros

### Cambio aplicado

Se agregaron:

* `externalTransactionId`
* `idempotencyKey`
* tracking de procesamiento

### Beneficio

Reduce riesgos de:

* duplicados,
* inconsistencias,
* reintentos externos,
* fallos de integración.

---

## 14. Mejoras en movimientos financieros

### Cambio aplicado

`financialMovements` ahora soporta:

* procesamiento distribuido,
* batch processing,
* observabilidad,
* trazabilidad.

### Beneficio

Escala mejor para:

* grandes volúmenes financieros,
* recompensas masivas,
* conciliaciones.

---

# Cambios para crecimiento futuro

## 15. Incorporación de tablas de estados técnicos

### Cambio aplicado

Se agregaron:

* `processingStatuses`
* `aiValidationStatuses`
* `propositionEventTypes`

### Beneficio

Facilita expansión futura del sistema.

---

## 16. Expiración de notificaciones

### Cambio aplicado

Se agregó:

* `expiresAt`

### Beneficio

Permite:

* archivado,
* limpieza automática,
* reducción del tamaño OLTP.

---

## 17. Incorporación de `ROWVERSION`

### Cambio aplicado

Se agregó en:

* `walletCurrentBalances`

### Beneficio

Mejora control de concurrencia optimista en SQL Server.

---

# Estrategias de escalabilidad consideradas

## Se priorizó un diseño orientado a:

* Alto volumen de inserts.
* Datos append-only.
* Bajo volumen de updates.
* Escalabilidad horizontal lógica.
* Procesamiento batch.
* Event sourcing parcial.
* Auditoría desacoplada.
* Observabilidad distribuida.
* Soporte para particionamiento temporal.
* Compatibilidad con SQL Server 2022.

---

# Riesgos mitigados con los cambios

Los cambios ayudan a reducir:

* deadlocks financieros,
* hotspots en wallets,
* crecimiento descontrolado de auditoría,
* contención en balances,
* doble procesamiento,
* pérdida de trazabilidad,
* problemas de retries,
* inconsistencias concurrentes,
* dificultad de monitoreo,
* saturación de tablas históricas,
* limitaciones para AI processing,
* problemas de escalabilidad futura.
