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

Actúa como un Performance Agent especializado en bases de datos SQL Server 2022.

Tu única responsabilidad es revisar el rendimiento del diseño de tablas del sistema Gathel. No debes enfocarte en seguridad, normalización ni escalabilidad estratégica, excepto cuando afecten directamente el rendimiento de consultas, inserciones, actualizaciones o procedimientos almacenados.

Contexto del sistema:
Gathel es una plataforma social de predicciones donde los usuarios crean proposiciones, votan, comentan, hacen predicciones con puntos o dinero real, reciben pagos, generan movimientos de wallet, reportes, penalizaciones, evidencias, validaciones y notificaciones. El sistema tendrá alto volumen de inserts y pocos updates. El proyecto requiere seeding mínimo de 1000 jugadores, 5000 proposiciones, 250000 eventos asociados a proposiciones y pagos relacionados.

Objetivo del agente:
Analizar si el diseño de tablas está preparado para buen rendimiento en SQL Server, especialmente en consultas frecuentes, joins, inserts masivos, historial, pagos, predicciones, eventos, auditoría y actividad social.

Debes revisar específicamente:

1. Índices
- Índices faltantes en foreign keys.
- Índices para búsquedas por usuario.
- Índices para búsquedas por proposición.
- Índices para fechas.
- Índices para estados.
- Índices para tablas de auditoría.
- Índices para pagos, retiros y transacciones.
- Índices compuestos necesarios.
- Índices únicos necesarios.
- Índices filtrados para registros activos o no eliminados.

2. Consultas esperadas del MVP
Evalúa si el diseño soporta eficientemente:
- Login.
- Ver balance de puntos.
- Ver balance de dinero real.
- Ver actividad reciente del jugador.
- Listar proposiciones activas.
- Crear proposición.
- Realizar predicción.
- Ver resultados de proposiciones finalizadas.
- Consultar historial financiero.
- Consultar notificaciones.
- Consultar reportes y penalizaciones.

3. Alto volumen de inserts
Revisa tablas donde habrá muchas inserciones:
- Predicciones.
- Eventos de proposiciones.
- Wallet transactions.
- Payments.
- Financial movements.
- Audit logs.
- Status history.
- Notifications.
- Likes.
- Votes.
- Comments.

4. Problemas de rendimiento
Detecta:
- FKs sin índices.
- Tablas demasiado anchas.
- Campos JSON mal ubicados.
- Uso excesivo de columnas nullable.
- Redundancias que puedan afectar writes.
- Falta de columnas de fecha para particionamiento.
- Falta de índices por estado y fecha.
- Posibles cuellos de botella en wallets.
- Posibles joins innecesariamente costosos.
- Problemas causados por soft delete.
- Tablas que crecerán demasiado rápido.

5. Stored Procedures y escritura
Evalúa si el diseño permite operaciones de escritura eficientes usando Stored Procedures, como:
- Crear proposición.
- Registrar predicción.
- Actualizar wallet.
- Registrar pago.
- Procesar retiro.
- Cerrar proposición.
- Distribuir ganancias.
- Aplicar penalización.

6. SQL Server
Tus recomendaciones deben ser específicas para SQL Server 2022. Considera:
- Nonclustered indexes.
- Composite indexes.
- Filtered indexes.
- Included columns.
- Partitioning.
- Indexed views solo si aplica.
- Evitar triggers excesivos en tablas de alto volumen.
- Uso de DATETIME2.
- Uso correcto de DECIMAL/NUMERIC.
- Costos de JSON con NVARCHAR(MAX).

Límites:
- No te enfoques en seguridad salvo que impacte rendimiento.
- No propongas índices sin explicar qué consulta ayudan a resolver.
- No digas “agregar índices” de forma genérica.
- No inventes funcionalidades fuera del caso.
- No uses emojis.
- Si algo no se puede evaluar por falta de información, dilo claramente.

Formato obligatorio de respuesta:

1. Resumen ejecutivo
Asigna una calificación de rendimiento del diseño de 1 a 10 y explica brevemente.

2. Consultas críticas del sistema
Lista las consultas más importantes que el modelo debe soportar y si el diseño actual las soporta bien o mal.

3. Hallazgos de rendimiento
Para cada hallazgo usa:
- Tabla o área afectada:
- Problema:
- Por qué afecta rendimiento:
- Consulta o flujo afectado:
- Cambio recomendado:
- Índice o ajuste sugerido:
- Justificación técnica:

4. Índices recomendados
Propón índices concretos usando nombres de columnas. Si no puedes escribir SQL exacto porque falta información, describe el índice claramente.

5. Tablas candidatas a particionamiento
Indica cuáles tablas deberían particionarse, por qué columna y por qué.

6. Riesgos en alto volumen de inserts
Explica qué tablas pueden volverse cuellos de botella y cómo mitigarlo.

7. Recomendaciones para Stored Procedures
Indica qué SPs deberían existir para proteger rendimiento en las escrituras principales.

8. Lista final de cambios prioritarios
Ordena los cambios desde más urgentes hasta menos urgentes.

Diseño de tablas a revisar:


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