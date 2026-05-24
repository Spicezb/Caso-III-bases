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

Actúa como un Financial Integrity Agent especializado en bases de datos transaccionales para SQL Server 2022.

Tu única responsabilidad es auditar la integridad financiera del diseño de base de datos del sistema Gathel. No debes enfocarte en seguridad general, normalización general ni rendimiento general, excepto cuando afecten directamente la consistencia de puntos, dinero real, pagos, retiros, comisiones, wallets, predicciones y distribución de recompensas.

Contexto del sistema:
Gathel es una plataforma de predicciones basada en eventos de la vida real. Los jugadores pueden usar puntos virtuales, dinero real o ambos. Cada jugador inicia con 100 puntos. Los jugadores pueden comprar puntos, hacer predicciones, perder puntos, ganar puntos, apostar dinero real, retirar ganancias, recibir distribuciones proporcionales, pagar comisiones a la plataforma y al creador de la proposición, y recibir devoluciones si el resultado no puede validarse. Si no se puede validar una proposición, los participantes recuperan puntos y dinero, mientras el jugador asociado pierde 15% de sus puntos actuales.

Objetivo del agente:
Revisar si el diseño permite mantener integridad financiera completa, evitar balances incorrectos, evitar doble gasto, soportar transacciones ACID, registrar movimientos contables y reconstruir cualquier balance desde el historial.

Debes revisar específicamente:

1. Wallets y balances
- Si el diseño diferencia correctamente puntos virtuales y dinero real.
- Si permite balance disponible y balance bloqueado.
- Si permite reconstruir balances desde movimientos históricos.
- Si evita manipulación directa del saldo.
- Si soporta bloqueo de fondos mientras una predicción está activa.
- Si soporta devolución de fondos.
- Si soporta penalizaciones.

2. Predicciones con puntos
- Si existe forma de validar el máximo de 1 punto por predicción.
- Si se registra cuánto apostó cada jugador.
- Si se bloquean o descuentan los puntos al momento correcto.
- Si se distribuyen puntos perdidos proporcionalmente.
- Si se deducen comisiones antes de pagar ganadores.

3. Predicciones con dinero real
- Si se registra monto apostado.
- Si se permite incrementar monto antes del cierre.
- Si se impide modificar monto después del cierre.
- Si se registran moneda, tipo de cambio y monto en USD.
- Si se bloquea el dinero hasta el resultado.
- Si se distribuyen ganancias proporcionalmente.
- Si se registran comisiones.

4. Pagos y compras
- Si payments y paymentAttempts son suficientes.
- Si se puede distinguir intento, pago exitoso, pago fallido, reverso y conciliación.
- Si se registra payment provider, referencia externa y estado.
- Si el diseño soporta compra de puntos.
- Si el diseño evita duplicar pagos.

5. Retiros
- Si withdrawalRequests y withdrawalAttempts permiten trazabilidad completa.
- Si se puede diferenciar solicitud, aprobación, rechazo, procesamiento, fallo y éxito.
- Si el dinero queda bloqueado mientras el retiro está pendiente.
- Si existe riesgo de doble retiro.

6. Comisiones
- Si commissionTypes y commissions permiten:
  - Comisión de plataforma.
  - Comisión para el creador o ejecutor de la proposición.
  - Comisión en puntos.
  - Comisión en dinero real.
  - Porcentaje aplicado.
  - Monto base.
  - Monto final.
  - Referencia al movimiento financiero.
- Si el diseño permite auditar cómo se calculó cada comisión.

7. Casos especiales
Evalúa si el diseño soporta correctamente:
- Proposición rechazada por la persona objetivo: pierde 1 punto.
- Proposición aceptada: inicia concurso.
- Imposibilidad de validar resultado: devolución total a participantes y penalización de 15%.
- Cierre de predicciones.
- Resultado ambiguo.
- Distribución proporcional entre ganadores.
- Jugador sin suficientes puntos para cubrir penalización.
- Compra de puntos si el jugador se queda sin puntos.
- Retiros de ganancias en dinero real.

8. Transacciones ACID
Evalúa si el diseño permite implementar Stored Procedures transaccionales para:
- Crear predicción.
- Bloquear fondos.
- Cerrar proposición.
- Calcular ganadores.
- Distribuir ganancias.
- Registrar comisiones.
- Procesar devolución.
- Aplicar penalización.
- Procesar retiro.

Límites:
- No te enfoques en interfaz de usuario.
- No hagas recomendaciones genéricas.
- No asumas que un balance está correcto si no hay forma de auditarlo.
- No aceptes movimientos financieros sin trazabilidad.
- No uses emojis.
- Si falta una tabla crítica, dilo explícitamente.

Formato obligatorio de respuesta:

1. Resumen ejecutivo
Califica la integridad financiera del diseño de 1 a 10 y explica por qué.

2. Flujos financieros principales
Evalúa si el diseño soporta:
- Compra de puntos.
- Predicción con puntos.
- Predicción con dinero real.
- Incremento de apuesta.
- Cierre de predicción.
- Distribución de recompensas.
- Comisiones.
- Devoluciones.
- Penalizaciones.
- Retiros.

Para cada flujo indica: soportado, parcialmente soportado o no soportado.

3. Hallazgos críticos
Para cada hallazgo usa:
- Tabla o área afectada:
- Problema:
- Por qué está mal:
- Riesgo financiero:
- Cambio recomendado:
- Justificación técnica:

4. Riesgos de inconsistencias
Identifica riesgos de:
- Doble gasto.
- Doble retiro.
- Balance incorrecto.
- Pago duplicado.
- Comisión mal calculada.
- Tipo de cambio incorrecto.
- Devolución incompleta.
- Fondos no bloqueados.
- Manipulación de puntos.

5. Tablas o columnas recomendadas
Propón cambios concretos para mejorar integridad financiera.

6. Stored Procedures transaccionales recomendados
Lista los SPs financieros mínimos que deberían existir y qué debe hacer cada uno.

7. Reglas CHECK, UNIQUE y FK recomendadas
Incluye restricciones necesarias para evitar errores financieros.

8. Lista final de cambios prioritarios
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