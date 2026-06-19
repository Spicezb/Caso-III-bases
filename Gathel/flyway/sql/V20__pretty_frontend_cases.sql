USE GathelDB
go

/*
    Datos de demostración para que el frontend de Gathel se vea completo:
    - 3 usuarios reales.
    - Contraseña de todos: 12345678.
    - Balances de puntos variados.
    - Cuentas sociales.
    - Gathels en votación.
    - Proposiciones pendientes.
    - Proposiciones activas.
    - Proposiciones cerradas.
    - Votos.
    - Predicciones ganadas, perdidas y pendientes.
    - Notificaciones.

    Nota:
    Este script asume que la base ya tiene las tablas creadas.
*/

SET XACT_ABORT ON;

BEGIN TRANSACTION;

/* ============================================================
   1. CATÁLOGOS MÍNIMOS
============================================================ */

IF NOT EXISTS (SELECT 1 FROM dbo.peopleTypes WHERE name = 'Player')
BEGIN
    INSERT INTO dbo.peopleTypes (name, description, isDeleted)
    VALUES ('Player', 'Jugador regular de Gathel', 0);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.countries WHERE isoCode = 'CR')
BEGIN
    INSERT INTO dbo.countries (name, isoCode, isDeleted)
    VALUES ('Costa Rica', 'CR', 0);
END;

DECLARE @countryId INT =
(
    SELECT TOP 1 countryId
    FROM dbo.countries
    WHERE isoCode = 'CR'
      AND isDeleted = 0
);

IF NOT EXISTS (SELECT 1 FROM dbo.states WHERE name = 'Cartago' AND countryId = @countryId)
BEGIN
    INSERT INTO dbo.states (countryId, name, isDeleted)
    VALUES (@countryId, 'Cartago', 0);
END;

DECLARE @stateId INT =
(
    SELECT TOP 1 stateId
    FROM dbo.states
    WHERE name = 'Cartago'
      AND countryId = @countryId
      AND isDeleted = 0
);

IF NOT EXISTS (SELECT 1 FROM dbo.cities WHERE name = 'Cartago' AND stateId = @stateId)
BEGIN
    INSERT INTO dbo.cities (stateId, name, isDeleted)
    VALUES (@stateId, 'Cartago', 0);
END;

DECLARE @cityId INT =
(
    SELECT TOP 1 cityId
    FROM dbo.cities
    WHERE name = 'Cartago'
      AND stateId = @stateId
      AND isDeleted = 0
);

IF NOT EXISTS (SELECT 1 FROM dbo.addresses WHERE exactAddress = 'Residencia demo Gathel')
BEGIN
    INSERT INTO dbo.addresses (cityId, exactAddress, isDeleted)
    VALUES (@cityId, 'Residencia demo Gathel', 0);
END;

DECLARE @addressId INT =
(
    SELECT TOP 1 addressId
    FROM dbo.addresses
    WHERE exactAddress = 'Residencia demo Gathel'
      AND isDeleted = 0
);

IF NOT EXISTS (SELECT 1 FROM dbo.statusTypes WHERE name = 'Voting')
BEGIN
    INSERT INTO dbo.statusTypes (name, description, isDeleted)
    VALUES ('Voting', 'Proposición en etapa de votación', 0);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.statusTypes WHERE name = 'PendingApproval')
BEGIN
    INSERT INTO dbo.statusTypes (name, description, isDeleted)
    VALUES ('PendingApproval', 'Proposición ganadora pendiente de aceptación por la persona objetivo', 0);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.statusTypes WHERE name = 'Active')
BEGIN
    INSERT INTO dbo.statusTypes (name, description, isDeleted)
    VALUES ('Active', 'Proposición activa para recibir predicciones', 0);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.statusTypes WHERE name = 'Closed')
BEGIN
    INSERT INTO dbo.statusTypes (name, description, isDeleted)
    VALUES ('Closed', 'Proposición cerrada', 0);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.statusTypes WHERE name = 'Rejected')
BEGIN
    INSERT INTO dbo.statusTypes (name, description, isDeleted)
    VALUES ('Rejected', 'Proposición rechazada', 0);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.statusTypes WHERE name = 'Completed')
BEGIN
    INSERT INTO dbo.statusTypes (name, description, isDeleted)
    VALUES ('Completed', 'Proceso completado', 0);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.statusTypes WHERE name = 'Cancelled')
BEGIN
    INSERT INTO dbo.statusTypes (name, description, isDeleted)
    VALUES ('Cancelled', 'Proceso cancelado', 0);
END;

DECLARE @statusVoting INT =
(
    SELECT TOP 1 statusTypeId
    FROM dbo.statusTypes
    WHERE name = 'Voting'
      AND isDeleted = 0
);

DECLARE @statusPending INT =
(
    SELECT TOP 1 statusTypeId
    FROM dbo.statusTypes
    WHERE name = 'PendingApproval'
      AND isDeleted = 0
);

DECLARE @statusActive INT =
(
    SELECT TOP 1 statusTypeId
    FROM dbo.statusTypes
    WHERE name = 'Active'
      AND isDeleted = 0
);

DECLARE @statusClosed INT =
(
    SELECT TOP 1 statusTypeId
    FROM dbo.statusTypes
    WHERE name = 'Closed'
      AND isDeleted = 0
);

DECLARE @statusCompleted INT =
(
    SELECT TOP 1 statusTypeId
    FROM dbo.statusTypes
    WHERE name = 'Completed'
      AND isDeleted = 0
);

IF NOT EXISTS (SELECT 1 FROM dbo.currencies WHERE code = 'USD')
BEGIN
    INSERT INTO dbo.currencies (name, code, symbol, isDefaultCurrencie, isDeleted)
    VALUES ('Dólar estadounidense', 'USD', '$', 1, 0);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.currencies WHERE code = 'CRC')
BEGIN
    INSERT INTO dbo.currencies (name, code, symbol, isDefaultCurrencie, isDeleted)
    VALUES ('Colón costarricense', 'CRC', '₡', 0, 0);
END;

DECLARE @usdCurrencyId INT =
(
    SELECT TOP 1 currencyId
    FROM dbo.currencies
    WHERE code = 'USD'
      AND isDeleted = 0
);

IF NOT EXISTS (
    SELECT 1
    FROM dbo.exchangeRates
    WHERE currencyId = @usdCurrencyId
      AND isCurrent = 1
      AND isDeleted = 0
)
BEGIN
    INSERT INTO dbo.exchangeRates (currencyId, rate, isCurrent, exchangeDateTime, isDeleted)
    VALUES (@usdCurrencyId, 1.000000, 1, SYSDATETIME(), 0);
END;

DECLARE @usdExchangeRateId INT =
(
    SELECT TOP 1 exchangeRateId
    FROM dbo.exchangeRates
    WHERE currencyId = @usdCurrencyId
      AND isCurrent = 1
      AND isDeleted = 0
    ORDER BY exchangeRateId DESC
);

IF NOT EXISTS (SELECT 1 FROM dbo.socialPlatforms WHERE name = 'Instagram')
BEGIN
    INSERT INTO dbo.socialPlatforms (name, apiUrl, config, isDeleted)
    VALUES ('Instagram', 'https://api.instagram.com', '{"demo": true}', 0);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.socialPlatforms WHERE name = 'TikTok')
BEGIN
    INSERT INTO dbo.socialPlatforms (name, apiUrl, config, isDeleted)
    VALUES ('TikTok', 'https://open.tiktokapis.com', '{"demo": true}', 0);
END;

DECLARE @instagramId INT =
(
    SELECT TOP 1 socialPlatformId
    FROM dbo.socialPlatforms
    WHERE name = 'Instagram'
      AND isDeleted = 0
);

DECLARE @tiktokId INT =
(
    SELECT TOP 1 socialPlatformId
    FROM dbo.socialPlatforms
    WHERE name = 'TikTok'
      AND isDeleted = 0
);

IF NOT EXISTS (SELECT 1 FROM dbo.referenceTypes WHERE name = 'Proposition')
BEGIN
    INSERT INTO dbo.referenceTypes (name, isDeleted)
    VALUES ('Proposition', 0);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.referenceTypes WHERE name = 'Prediction')
BEGIN
    INSERT INTO dbo.referenceTypes (name, isDeleted)
    VALUES ('Prediction', 0);
END;

DECLARE @refPropositionId INT =
(
    SELECT TOP 1 referenceTypeId
    FROM dbo.referenceTypes
    WHERE name = 'Proposition'
      AND isDeleted = 0
);

DECLARE @refPredictionId INT =
(
    SELECT TOP 1 referenceTypeId
    FROM dbo.referenceTypes
    WHERE name = 'Prediction'
      AND isDeleted = 0
);

IF NOT EXISTS (SELECT 1 FROM dbo.notificationTypes WHERE name = 'proposicion_aceptada')
BEGIN
    INSERT INTO dbo.notificationTypes (name, description, isDeleted)
    VALUES ('proposicion_aceptada', 'Notificación cuando una proposición es aceptada', 0);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.notificationTypes WHERE name = 'proposicion_rechazada')
BEGIN
    INSERT INTO dbo.notificationTypes (name, description, isDeleted)
    VALUES ('proposicion_rechazada', 'Notificación cuando una proposición es rechazada', 0);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.notificationTypes WHERE name = 'nuevo_pronostico')
BEGIN
    INSERT INTO dbo.notificationTypes (name, description, isDeleted)
    VALUES ('nuevo_pronostico', 'Notificación cuando se registra un nuevo pronóstico', 0);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.notificationTypes WHERE name = 'resultado_validado_ganaste')
BEGIN
    INSERT INTO dbo.notificationTypes (name, description, isDeleted)
    VALUES ('resultado_validado_ganaste', 'Notificación de resultado ganador', 0);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.notificationTypes WHERE name = 'resultado_validado_perdiste')
BEGIN
    INSERT INTO dbo.notificationTypes (name, description, isDeleted)
    VALUES ('resultado_validado_perdiste', 'Notificación de resultado perdedor', 0);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.notificationTypes WHERE name = 'penalizacion')
BEGIN
    INSERT INTO dbo.notificationTypes (name, description, isDeleted)
    VALUES ('penalizacion', 'Notificación de penalización aplicada', 0);
END;

DECLARE @ntAccepted INT =
(
    SELECT TOP 1 notificationTypeId
    FROM dbo.notificationTypes
    WHERE name = 'proposicion_aceptada'
);

DECLARE @ntRejected INT =
(
    SELECT TOP 1 notificationTypeId
    FROM dbo.notificationTypes
    WHERE name = 'proposicion_rechazada'
);

DECLARE @ntNewPrediction INT =
(
    SELECT TOP 1 notificationTypeId
    FROM dbo.notificationTypes
    WHERE name = 'nuevo_pronostico'
);

DECLARE @ntWon INT =
(
    SELECT TOP 1 notificationTypeId
    FROM dbo.notificationTypes
    WHERE name = 'resultado_validado_ganaste'
);

DECLARE @ntLost INT =
(
    SELECT TOP 1 notificationTypeId
    FROM dbo.notificationTypes
    WHERE name = 'resultado_validado_perdiste'
);

DECLARE @ntPenalty INT =
(
    SELECT TOP 1 notificationTypeId
    FROM dbo.notificationTypes
    WHERE name = 'penalizacion'
);


/* ============================================================
   2. USUARIOS DEMO
============================================================ */

DECLARE @playerTypeId INT =
(
    SELECT TOP 1 peopleTypeId
    FROM dbo.peopleTypes
    WHERE name = 'Player'
      AND isDeleted = 0
);

DECLARE @password VARBINARY(MAX) = HASHBYTES('SHA2_256', '12345678');

IF NOT EXISTS (SELECT 1 FROM dbo.people WHERE email = 'elizabeth.rojas@gathel.demo')
BEGIN
    INSERT INTO dbo.people
    (
        peopleTypeId,
        name,
        lastName,
        identification,
        phone,
        email,
        passwordHash,
        username,
        biography,
        birthDate,
        addressId,
        isVerified,
        isActive,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @playerTypeId,
        'Elizabeth',
        'Rojas',
        'DEMO-ELI-001',
        '8888-1001',
        'elizabeth.rojas@gathel.demo',
        @password,
        'elizabeth_runs',
        'Corredora aficionada. Está entrenando para su primera maratón.',
        '2001-04-12',
        @addressId,
        1,
        1,
        DATEADD(DAY, -45, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (SELECT 1 FROM dbo.people WHERE email = 'john.miller@gathel.demo')
BEGIN
    INSERT INTO dbo.people
    (
        peopleTypeId,
        name,
        lastName,
        identification,
        phone,
        email,
        passwordHash,
        username,
        biography,
        birthDate,
        addressId,
        isVerified,
        isActive,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @playerTypeId,
        'John',
        'Miller',
        'DEMO-JOHN-001',
        '8888-1002',
        'john.miller@gathel.demo',
        @password,
        'johnbets',
        'Fan de los retos deportivos y las predicciones con puntos.',
        '2000-09-20',
        @addressId,
        1,
        1,
        DATEADD(DAY, -38, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (SELECT 1 FROM dbo.people WHERE email = 'karina.soto@gathel.demo')
BEGIN
    INSERT INTO dbo.people
    (
        peopleTypeId,
        name,
        lastName,
        identification,
        phone,
        email,
        passwordHash,
        username,
        biography,
        birthDate,
        addressId,
        isVerified,
        isActive,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @playerTypeId,
        'Karina',
        'Soto',
        'DEMO-KARI-001',
        '8888-1003',
        'karina.soto@gathel.demo',
        @password,
        'karinafit',
        'Creadora de contenido fitness. Le gusta proponer retos y seguir eventos reales.',
        '2002-01-18',
        @addressId,
        1,
        1,
        DATEADD(DAY, -31, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

DECLARE @elizabethId INT =
(
    SELECT personId
    FROM dbo.people
    WHERE email = 'elizabeth.rojas@gathel.demo'
);

DECLARE @johnId INT =
(
    SELECT personId
    FROM dbo.people
    WHERE email = 'john.miller@gathel.demo'
);

DECLARE @karinaId INT =
(
    SELECT personId
    FROM dbo.people
    WHERE email = 'karina.soto@gathel.demo'
);


/* ============================================================
   3. WALLETS Y BALANCES
============================================================ */

IF NOT EXISTS (SELECT 1 FROM dbo.wallets WHERE personId = @elizabethId AND isDeleted = 0)
BEGIN
    INSERT INTO dbo.wallets (personId, isBlocked, createdAt, updatedAt, isDeleted)
    VALUES (@elizabethId, 0, DATEADD(DAY, -45, SYSDATETIME()), SYSDATETIME(), 0);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.wallets WHERE personId = @johnId AND isDeleted = 0)
BEGIN
    INSERT INTO dbo.wallets (personId, isBlocked, createdAt, updatedAt, isDeleted)
    VALUES (@johnId, 0, DATEADD(DAY, -38, SYSDATETIME()), SYSDATETIME(), 0);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.wallets WHERE personId = @karinaId AND isDeleted = 0)
BEGIN
    INSERT INTO dbo.wallets (personId, isBlocked, createdAt, updatedAt, isDeleted)
    VALUES (@karinaId, 0, DATEADD(DAY, -31, SYSDATETIME()), SYSDATETIME(), 0);
END;

DECLARE @walletElizabeth INT =
(
    SELECT TOP 1 walletId
    FROM dbo.wallets
    WHERE personId = @elizabethId
      AND isDeleted = 0
);

DECLARE @walletJohn INT =
(
    SELECT TOP 1 walletId
    FROM dbo.wallets
    WHERE personId = @johnId
      AND isDeleted = 0
);

DECLARE @walletKarina INT =
(
    SELECT TOP 1 walletId
    FROM dbo.wallets
    WHERE personId = @karinaId
      AND isDeleted = 0
);

IF NOT EXISTS (SELECT 1 FROM dbo.walletBalances WHERE walletId = @walletElizabeth AND isDeleted = 0)
BEGIN
    INSERT INTO dbo.walletBalances
    (
        walletId,
        statusTypeId,
        oldPointsAmount,
        balancePointsAmount,
        newPointsAmount,
        calculatedAt,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @walletElizabeth,
        @statusActive,
        100,
        118,
        118,
        DATEADD(DAY, -2, SYSDATETIME()),
        DATEADD(DAY, -2, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (SELECT 1 FROM dbo.walletBalances WHERE walletId = @walletJohn AND isDeleted = 0)
BEGIN
    INSERT INTO dbo.walletBalances
    (
        walletId,
        statusTypeId,
        oldPointsAmount,
        balancePointsAmount,
        newPointsAmount,
        calculatedAt,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @walletJohn,
        @statusActive,
        100,
        142,
        142,
        DATEADD(DAY, -1, SYSDATETIME()),
        DATEADD(DAY, -1, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (SELECT 1 FROM dbo.walletBalances WHERE walletId = @walletKarina AND isDeleted = 0)
BEGIN
    INSERT INTO dbo.walletBalances
    (
        walletId,
        statusTypeId,
        oldPointsAmount,
        balancePointsAmount,
        newPointsAmount,
        calculatedAt,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @walletKarina,
        @statusActive,
        100,
        87,
        87,
        DATEADD(DAY, -3, SYSDATETIME()),
        DATEADD(DAY, -3, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;


/* ============================================================
   4. CUENTAS SOCIALES
============================================================ */

IF NOT EXISTS (
    SELECT 1
    FROM dbo.socialAccounts
    WHERE socialPlatformId = @instagramId
      AND username = 'elizabeth_runs'
)
BEGIN
    INSERT INTO dbo.socialAccounts
    (
        personId,
        socialPlatformId,
        username,
        profileUrl,
        accessToken,
        refreshToken,
        isVerified,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @elizabethId,
        @instagramId,
        'elizabeth_runs',
        'https://instagram.com/elizabeth_runs',
        0x01,
        0x02,
        1,
        DATEADD(DAY, -40, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.socialAccounts
    WHERE socialPlatformId = @instagramId
      AND username = 'johnbets'
)
BEGIN
    INSERT INTO dbo.socialAccounts
    (
        personId,
        socialPlatformId,
        username,
        profileUrl,
        accessToken,
        refreshToken,
        isVerified,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @johnId,
        @instagramId,
        'johnbets',
        'https://instagram.com/johnbets',
        0x01,
        0x02,
        1,
        DATEADD(DAY, -35, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.socialAccounts
    WHERE socialPlatformId = @tiktokId
      AND username = 'karinafit'
)
BEGIN
    INSERT INTO dbo.socialAccounts
    (
        personId,
        socialPlatformId,
        username,
        profileUrl,
        accessToken,
        refreshToken,
        isVerified,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @karinaId,
        @tiktokId,
        'karinafit',
        'https://tiktok.com/@karinafit',
        0x01,
        0x02,
        1,
        DATEADD(DAY, -30, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

DECLARE @socialElizabeth INT =
(
    SELECT TOP 1 socialAccountId
    FROM dbo.socialAccounts
    WHERE personId = @elizabethId
      AND isDeleted = 0
);

DECLARE @socialJohn INT =
(
    SELECT TOP 1 socialAccountId
    FROM dbo.socialAccounts
    WHERE personId = @johnId
      AND isDeleted = 0
);

DECLARE @socialKarina INT =
(
    SELECT TOP 1 socialAccountId
    FROM dbo.socialAccounts
    WHERE personId = @karinaId
      AND isDeleted = 0
);


/* ============================================================
   5. PROPOSICIONES EN VOTING
============================================================ */

DECLARE @marathonParentTitle VARCHAR(120) =
    'Elizabeth publicó que está entrenando para una maratón';

DECLARE @johnParentTitle VARCHAR(120) =
    'John anunció que va a participar en un torneo de ajedrez';

IF NOT EXISTS (SELECT 1 FROM dbo.propositions WHERE title = @marathonParentTitle)
BEGIN
    INSERT INTO dbo.propositions
    (
        parentproposition,
        statusTypesId,
        creatorPersonId,
        targetPersonId,
        targetSocialAccountId,
        title,
        description,
        startPredictionDateTime,
        endPredictionDateTime,
        winningOption,
        minimumEntryPointsAmount,
        winningProfitPercentage,
        isPublic,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        NULL,
        @statusVoting,
        @johnId,
        @elizabethId,
        @socialElizabeth,
        @marathonParentTitle,
        'Gathel padre basado en una publicación de Instagram sobre entrenamiento para maratón. La comunidad propone opciones candidatas y vota por la más interesante.',
        DATEADD(DAY, -1, SYSDATETIME()),
        DATEADD(DAY, 1, SYSDATETIME()),
        NULL,
        1,
        10,
        1,
        DATEADD(HOUR, -10, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (SELECT 1 FROM dbo.propositions WHERE title = @johnParentTitle)
BEGIN
    INSERT INTO dbo.propositions
    (
        parentproposition,
        statusTypesId,
        creatorPersonId,
        targetPersonId,
        targetSocialAccountId,
        title,
        description,
        startPredictionDateTime,
        endPredictionDateTime,
        winningOption,
        minimumEntryPointsAmount,
        winningProfitPercentage,
        isPublic,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        NULL,
        @statusVoting,
        @karinaId,
        @johnId,
        @socialJohn,
        @johnParentTitle,
        'Gathel padre para proponer resultados posibles sobre el torneo anunciado por John.',
        DATEADD(HOUR, -6, SYSDATETIME()),
        DATEADD(DAY, 1, SYSDATETIME()),
        NULL,
        1,
        10,
        1,
        DATEADD(HOUR, -6, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

DECLARE @marathonParentId INT =
(
    SELECT TOP 1 propositionId
    FROM dbo.propositions
    WHERE title = @marathonParentTitle
);

DECLARE @johnParentId INT =
(
    SELECT TOP 1 propositionId
    FROM dbo.propositions
    WHERE title = @johnParentTitle
);

IF NOT EXISTS (SELECT 1 FROM dbo.propositions WHERE title = 'Elizabeth no asistirá a la maratón')
BEGIN
    INSERT INTO dbo.propositions
    (
        parentproposition,
        statusTypesId,
        creatorPersonId,
        targetPersonId,
        targetSocialAccountId,
        title,
        description,
        startPredictionDateTime,
        endPredictionDateTime,
        winningOption,
        minimumEntryPointsAmount,
        winningProfitPercentage,
        isPublic,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @marathonParentId,
        @statusVoting,
        @johnId,
        @elizabethId,
        @socialElizabeth,
        'Elizabeth no asistirá a la maratón',
        'Propuesta candidata creada por John. Se vota para decidir si esta será la proposición principal del Gathel.',
        DATEADD(DAY, -1, SYSDATETIME()),
        DATEADD(DAY, 1, SYSDATETIME()),
        NULL,
        1,
        10,
        1,
        DATEADD(HOUR, -9, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (SELECT 1 FROM dbo.propositions WHERE title = 'Elizabeth terminará dentro de los primeros 30 lugares')
BEGIN
    INSERT INTO dbo.propositions
    (
        parentproposition,
        statusTypesId,
        creatorPersonId,
        targetPersonId,
        targetSocialAccountId,
        title,
        description,
        startPredictionDateTime,
        endPredictionDateTime,
        winningOption,
        minimumEntryPointsAmount,
        winningProfitPercentage,
        isPublic,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @marathonParentId,
        @statusVoting,
        @karinaId,
        @elizabethId,
        @socialElizabeth,
        'Elizabeth terminará dentro de los primeros 30 lugares',
        'Propuesta candidata añadida por Karina. La comunidad puede votar por esta opción.',
        DATEADD(DAY, -1, SYSDATETIME()),
        DATEADD(DAY, 1, SYSDATETIME()),
        NULL,
        1,
        10,
        1,
        DATEADD(HOUR, -8, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (SELECT 1 FROM dbo.propositions WHERE title = 'Elizabeth logrará al menos el décimo lugar')
BEGIN
    INSERT INTO dbo.propositions
    (
        parentproposition,
        statusTypesId,
        creatorPersonId,
        targetPersonId,
        targetSocialAccountId,
        title,
        description,
        startPredictionDateTime,
        endPredictionDateTime,
        winningOption,
        minimumEntryPointsAmount,
        winningProfitPercentage,
        isPublic,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @marathonParentId,
        @statusVoting,
        @elizabethId,
        @elizabethId,
        @socialElizabeth,
        'Elizabeth logrará al menos el décimo lugar',
        'Propuesta creada por Elizabeth sobre sí misma.',
        DATEADD(DAY, -1, SYSDATETIME()),
        DATEADD(DAY, 1, SYSDATETIME()),
        NULL,
        1,
        10,
        1,
        DATEADD(HOUR, -7, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (SELECT 1 FROM dbo.propositions WHERE title = 'John llegará a semifinales del torneo')
BEGIN
    INSERT INTO dbo.propositions
    (
        parentproposition,
        statusTypesId,
        creatorPersonId,
        targetPersonId,
        targetSocialAccountId,
        title,
        description,
        startPredictionDateTime,
        endPredictionDateTime,
        winningOption,
        minimumEntryPointsAmount,
        winningProfitPercentage,
        isPublic,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @johnParentId,
        @statusVoting,
        @karinaId,
        @johnId,
        @socialJohn,
        'John llegará a semifinales del torneo',
        'Candidata en votación sobre el desempeño de John.',
        DATEADD(HOUR, -6, SYSDATETIME()),
        DATEADD(DAY, 1, SYSDATETIME()),
        NULL,
        1,
        10,
        1,
        DATEADD(HOUR, -5, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (SELECT 1 FROM dbo.propositions WHERE title = 'John perderá en la primera ronda')
BEGIN
    INSERT INTO dbo.propositions
    (
        parentproposition,
        statusTypesId,
        creatorPersonId,
        targetPersonId,
        targetSocialAccountId,
        title,
        description,
        startPredictionDateTime,
        endPredictionDateTime,
        winningOption,
        minimumEntryPointsAmount,
        winningProfitPercentage,
        isPublic,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @johnParentId,
        @statusVoting,
        @elizabethId,
        @johnId,
        @socialJohn,
        'John perderá en la primera ronda',
        'Otra candidata para el Gathel del torneo de ajedrez.',
        DATEADD(HOUR, -6, SYSDATETIME()),
        DATEADD(DAY, 1, SYSDATETIME()),
        NULL,
        1,
        10,
        1,
        DATEADD(HOUR, -4, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;


/* ============================================================
   6. PROPOSICIÓN PENDING APPROVAL
============================================================ */

DECLARE @pendingParentTitle VARCHAR(120) =
    'Karina anunció que intentará subir contenido fitness durante 7 días';

IF NOT EXISTS (SELECT 1 FROM dbo.propositions WHERE title = @pendingParentTitle)
BEGIN
    INSERT INTO dbo.propositions
    (
        parentproposition,
        statusTypesId,
        creatorPersonId,
        targetPersonId,
        targetSocialAccountId,
        title,
        description,
        startPredictionDateTime,
        endPredictionDateTime,
        minimumEntryPointsAmount,
        winningProfitPercentage,
        isPublic,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        NULL,
        @statusClosed,
        @elizabethId,
        @karinaId,
        @socialKarina,
        @pendingParentTitle,
        'Gathel padre ya cerrado luego de la votación de candidatas.',
        DATEADD(DAY, -3, SYSDATETIME()),
        DATEADD(DAY, -2, SYSDATETIME()),
        1,
        10,
        1,
        DATEADD(DAY, -3, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

DECLARE @pendingParentId INT =
(
    SELECT TOP 1 propositionId
    FROM dbo.propositions
    WHERE title = @pendingParentTitle
);

IF NOT EXISTS (SELECT 1 FROM dbo.propositions WHERE title = 'Karina publicará contenido fitness todos los días de esta semana')
BEGIN
    INSERT INTO dbo.propositions
    (
        parentproposition,
        statusTypesId,
        creatorPersonId,
        targetPersonId,
        targetSocialAccountId,
        title,
        description,
        startPredictionDateTime,
        endPredictionDateTime,
        winningOption,
        minimumEntryPointsAmount,
        winningProfitPercentage,
        isPublic,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @pendingParentId,
        @statusPending,
        @johnId,
        @karinaId,
        @socialKarina,
        'Karina publicará contenido fitness todos los días de esta semana',
        'Esta fue la propuesta ganadora de la votación y está pendiente de aprobación por Karina.',
        DATEADD(MINUTE, -1, SYSDATETIME()),
        DATEADD(DAY, 2, SYSDATETIME()),
        NULL,
        1,
        10,
        1,
        DATEADD(DAY, -2, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;


/* ============================================================
   7. PROPOSICIONES ACTIVAS
============================================================ */

IF NOT EXISTS (SELECT 1 FROM dbo.propositions WHERE title = 'Elizabeth completará la maratón en menos de 5 horas')
BEGIN
    INSERT INTO dbo.propositions
    (
        parentproposition,
        statusTypesId,
        creatorPersonId,
        targetPersonId,
        targetSocialAccountId,
        title,
        description,
        startPredictionDateTime,
        endPredictionDateTime,
        winningOption,
        minimumEntryPointsAmount,
        winningProfitPercentage,
        isPublic,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @marathonParentId,
        @statusActive,
        @karinaId,
        @elizabethId,
        @socialElizabeth,
        'Elizabeth completará la maratón en menos de 5 horas',
        'Modo de predicción: ambos. Proposición activa aceptada por Elizabeth. Se puede pronosticar con puntos o dinero real.',
        DATEADD(HOUR, -48, SYSDATETIME()),
        DATEADD(DAY, 3, SYSDATETIME()),
        NULL,
        1,
        15,
        1,
        DATEADD(DAY, -2, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (SELECT 1 FROM dbo.propositions WHERE title = 'John ganará al menos dos partidas del torneo')
BEGIN
    INSERT INTO dbo.propositions
    (
        parentproposition,
        statusTypesId,
        creatorPersonId,
        targetPersonId,
        targetSocialAccountId,
        title,
        description,
        startPredictionDateTime,
        endPredictionDateTime,
        winningOption,
        minimumEntryPointsAmount,
        winningProfitPercentage,
        isPublic,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @johnParentId,
        @statusActive,
        @elizabethId,
        @johnId,
        @socialJohn,
        'John ganará al menos dos partidas del torneo',
        'Modo de predicción: dinero. Proposición activa para pronósticos con dinero real.',
        DATEADD(HOUR, -24, SYSDATETIME()),
        DATEADD(DAY, 2, SYSDATETIME()),
        NULL,
        NULL,
        20,
        1,
        DATEADD(DAY, -1, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

DECLARE @activeElizabethId INT =
(
    SELECT TOP 1 propositionId
    FROM dbo.propositions
    WHERE title = 'Elizabeth completará la maratón en menos de 5 horas'
);

DECLARE @activeJohnId INT =
(
    SELECT TOP 1 propositionId
    FROM dbo.propositions
    WHERE title = 'John ganará al menos dos partidas del torneo'
);


/* ============================================================
   8. PROPOSICIONES CERRADAS PARA RESULTADOS
============================================================ */

IF NOT EXISTS (SELECT 1 FROM dbo.propositions WHERE title = 'Karina subió al menos tres videos fitness en una semana')
BEGIN
    INSERT INTO dbo.propositions
    (
        parentproposition,
        statusTypesId,
        creatorPersonId,
        targetPersonId,
        targetSocialAccountId,
        title,
        description,
        startPredictionDateTime,
        endPredictionDateTime,
        winningOption,
        minimumEntryPointsAmount,
        winningProfitPercentage,
        isPublic,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        NULL,
        @statusClosed,
        @johnId,
        @karinaId,
        @socialKarina,
        'Karina subió al menos tres videos fitness en una semana',
        'Modo de predicción: puntos. Proposición cerrada con resultado validado.',
        DATEADD(DAY, -15, SYSDATETIME()),
        DATEADD(DAY, -7, SYSDATETIME()),
        1,
        1,
        10,
        1,
        DATEADD(DAY, -15, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (SELECT 1 FROM dbo.propositions WHERE title = 'Elizabeth corrió más de 10 km el domingo')
BEGIN
    INSERT INTO dbo.propositions
    (
        parentproposition,
        statusTypesId,
        creatorPersonId,
        targetPersonId,
        targetSocialAccountId,
        title,
        description,
        startPredictionDateTime,
        endPredictionDateTime,
        winningOption,
        minimumEntryPointsAmount,
        winningProfitPercentage,
        isPublic,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        NULL,
        @statusClosed,
        @johnId,
        @elizabethId,
        @socialElizabeth,
        'Elizabeth corrió más de 10 km el domingo',
        'Modo de predicción: dinero. Proposición cerrada con resultado validado.',
        DATEADD(DAY, -12, SYSDATETIME()),
        DATEADD(DAY, -5, SYSDATETIME()),
        0,
        NULL,
        15,
        1,
        DATEADD(DAY, -12, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

DECLARE @closedKarinaId INT =
(
    SELECT TOP 1 propositionId
    FROM dbo.propositions
    WHERE title = 'Karina subió al menos tres videos fitness en una semana'
);

DECLARE @closedElizabethId INT =
(
    SELECT TOP 1 propositionId
    FROM dbo.propositions
    WHERE title = 'Elizabeth corrió más de 10 km el domingo'
);


/* ============================================================
   9. VOTOS PARA QUE EXPLORAR SE VEA REAL
============================================================ */

DECLARE @candidateElizabethTop30 INT =
(
    SELECT TOP 1 propositionId
    FROM dbo.propositions
    WHERE title = 'Elizabeth terminará dentro de los primeros 30 lugares'
);

DECLARE @candidateElizabethNoShow INT =
(
    SELECT TOP 1 propositionId
    FROM dbo.propositions
    WHERE title = 'Elizabeth no asistirá a la maratón'
);

DECLARE @candidateJohnSemi INT =
(
    SELECT TOP 1 propositionId
    FROM dbo.propositions
    WHERE title = 'John llegará a semifinales del torneo'
);

IF NOT EXISTS (
    SELECT 1
    FROM dbo.propositionVotes
    WHERE propositionId = @candidateElizabethTop30
      AND personId = @johnId
)
BEGIN
    INSERT INTO dbo.propositionVotes
    (
        propositionId,
        personId,
        voteValue,
        votedAt,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @candidateElizabethTop30,
        @johnId,
        1,
        DATEADD(HOUR, -5, SYSDATETIME()),
        DATEADD(HOUR, -5, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.propositionVotes
    WHERE propositionId = @candidateElizabethTop30
      AND personId = @karinaId
)
BEGIN
    INSERT INTO dbo.propositionVotes
    (
        propositionId,
        personId,
        voteValue,
        votedAt,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @candidateElizabethTop30,
        @karinaId,
        1,
        DATEADD(HOUR, -4, SYSDATETIME()),
        DATEADD(HOUR, -4, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.propositionVotes
    WHERE propositionId = @candidateElizabethNoShow
      AND personId = @elizabethId
)
BEGIN
    INSERT INTO dbo.propositionVotes
    (
        propositionId,
        personId,
        voteValue,
        votedAt,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @candidateElizabethNoShow,
        @elizabethId,
        1,
        DATEADD(HOUR, -3, SYSDATETIME()),
        DATEADD(HOUR, -3, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.propositionVotes
    WHERE propositionId = @candidateJohnSemi
      AND personId = @elizabethId
)
BEGIN
    INSERT INTO dbo.propositionVotes
    (
        propositionId,
        personId,
        voteValue,
        votedAt,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @candidateJohnSemi,
        @elizabethId,
        1,
        DATEADD(HOUR, -2, SYSDATETIME()),
        DATEADD(HOUR, -2, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;


/* ============================================================
   10. PREDICCIONES PARA PERFIL Y RESULTADOS
============================================================ */

IF NOT EXISTS (
    SELECT 1
    FROM dbo.predictions
    WHERE propositionId = @activeElizabethId
      AND personId = @johnId
)
BEGIN
    INSERT INTO dbo.predictions
    (
        statusTypesId,
        propositionId,
        personId,
        predictionValue,
        pointsAmount,
        moneyAmount,
        currencyId,
        exchangeRateId,
        predictionDateTime,
        isWinner,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @statusActive,
        @activeElizabethId,
        @johnId,
        1,
        1,
        5,
        @usdCurrencyId,
        @usdExchangeRateId,
        DATEADD(HOUR, -8, SYSDATETIME()),
        0,
        DATEADD(HOUR, -8, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.predictions
    WHERE propositionId = @activeJohnId
      AND personId = @karinaId
)
BEGIN
    INSERT INTO dbo.predictions
    (
        statusTypesId,
        propositionId,
        personId,
        predictionValue,
        pointsAmount,
        moneyAmount,
        currencyId,
        exchangeRateId,
        predictionDateTime,
        isWinner,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @statusActive,
        @activeJohnId,
        @karinaId,
        1,
        0,
        12,
        @usdCurrencyId,
        @usdExchangeRateId,
        DATEADD(HOUR, -4, SYSDATETIME()),
        0,
        DATEADD(HOUR, -4, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.predictions
    WHERE propositionId = @closedKarinaId
      AND personId = @johnId
)
BEGIN
    INSERT INTO dbo.predictions
    (
        statusTypesId,
        propositionId,
        personId,
        predictionValue,
        pointsAmount,
        moneyAmount,
        currencyId,
        exchangeRateId,
        predictionDateTime,
        isWinner,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @statusCompleted,
        @closedKarinaId,
        @johnId,
        1,
        1,
        0,
        @usdCurrencyId,
        @usdExchangeRateId,
        DATEADD(DAY, -10, SYSDATETIME()),
        1,
        DATEADD(DAY, -10, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.predictions
    WHERE propositionId = @closedElizabethId
      AND personId = @karinaId
)
BEGIN
    INSERT INTO dbo.predictions
    (
        statusTypesId,
        propositionId,
        personId,
        predictionValue,
        pointsAmount,
        moneyAmount,
        currencyId,
        exchangeRateId,
        predictionDateTime,
        isWinner,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @statusCompleted,
        @closedElizabethId,
        @karinaId,
        1,
        0,
        8,
        @usdCurrencyId,
        @usdExchangeRateId,
        DATEADD(DAY, -8, SYSDATETIME()),
        0,
        DATEADD(DAY, -8, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.predictions
    WHERE propositionId = @closedKarinaId
      AND personId = @elizabethId
)
BEGIN
    INSERT INTO dbo.predictions
    (
        statusTypesId,
        propositionId,
        personId,
        predictionValue,
        pointsAmount,
        moneyAmount,
        currencyId,
        exchangeRateId,
        predictionDateTime,
        isWinner,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @statusCompleted,
        @closedKarinaId,
        @elizabethId,
        0,
        1,
        0,
        @usdCurrencyId,
        @usdExchangeRateId,
        DATEADD(DAY, -9, SYSDATETIME()),
        0,
        DATEADD(DAY, -9, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;


/* ============================================================
   11. NOTIFICACIONES
============================================================ */

IF NOT EXISTS (
    SELECT 1
    FROM dbo.notifications
    WHERE personId = @elizabethId
      AND title = 'Tenés una proposición activa'
)
BEGIN
    INSERT INTO dbo.notifications
    (
        notificationTypeId,
        personId,
        title,
        message,
        isRead,
        readAt,
        referenceTypeId,
        referenceId,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @ntAccepted,
        @elizabethId,
        'Tenés una proposición activa',
        'La proposición sobre completar la maratón en menos de 5 horas ya está activa para recibir pronósticos.',
        0,
        NULL,
        @refPropositionId,
        @activeElizabethId,
        DATEADD(HOUR, -10, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.notifications
    WHERE personId = @elizabethId
      AND title = 'Nuevo pronóstico recibido'
)
BEGIN
    INSERT INTO dbo.notifications
    (
        notificationTypeId,
        personId,
        title,
        message,
        isRead,
        readAt,
        referenceTypeId,
        referenceId,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @ntNewPrediction,
        @elizabethId,
        'Nuevo pronóstico recibido',
        'John hizo un pronóstico sobre tu proposición activa de la maratón.',
        0,
        NULL,
        @refPropositionId,
        @activeElizabethId,
        DATEADD(HOUR, -8, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.notifications
    WHERE personId = @johnId
      AND title = 'Ganaste una predicción'
)
BEGIN
    INSERT INTO dbo.notifications
    (
        notificationTypeId,
        personId,
        title,
        message,
        isRead,
        readAt,
        referenceTypeId,
        referenceId,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @ntWon,
        @johnId,
        'Ganaste una predicción',
        'Tu pronóstico sobre los videos fitness de Karina fue marcado como ganador.',
        0,
        NULL,
        @refPredictionId,
        @closedKarinaId,
        DATEADD(DAY, -2, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.notifications
    WHERE personId = @johnId
      AND title = 'Votaste en un Gathel'
)
BEGIN
    INSERT INTO dbo.notifications
    (
        notificationTypeId,
        personId,
        title,
        message,
        isRead,
        readAt,
        referenceTypeId,
        referenceId,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @ntNewPrediction,
        @johnId,
        'Votaste en un Gathel',
        'Tu voto por la propuesta de Elizabeth top 30 fue registrado correctamente.',
        1,
        DATEADD(HOUR, -4, SYSDATETIME()),
        @refPropositionId,
        @candidateElizabethTop30,
        DATEADD(HOUR, -5, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.notifications
    WHERE personId = @karinaId
      AND title = 'Tenés una proposición pendiente'
)
BEGIN
    INSERT INTO dbo.notifications
    (
        notificationTypeId,
        personId,
        title,
        message,
        isRead,
        readAt,
        referenceTypeId,
        referenceId,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @ntAccepted,
        @karinaId,
        'Tenés una proposición pendiente',
        'La propuesta sobre publicar contenido fitness todos los días ganó la votación y necesita tu aprobación.',
        0,
        NULL,
        @refPropositionId,
        (
            SELECT TOP 1 propositionId
            FROM dbo.propositions
            WHERE title = 'Karina publicará contenido fitness todos los días de esta semana'
        ),
        DATEADD(HOUR, -2, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.notifications
    WHERE personId = @karinaId
      AND title = 'Perdiste una predicción'
)
BEGIN
    INSERT INTO dbo.notifications
    (
        notificationTypeId,
        personId,
        title,
        message,
        isRead,
        readAt,
        referenceTypeId,
        referenceId,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @ntLost,
        @karinaId,
        'Perdiste una predicción',
        'Tu pronóstico sobre Elizabeth corriendo más de 10 km no coincidió con el resultado final.',
        1,
        DATEADD(DAY, -1, SYSDATETIME()),
        @refPredictionId,
        @closedElizabethId,
        DATEADD(DAY, -3, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (SELECT 1 FROM dbo.propositions WHERE title = 'Karina rechazó una propuesta invasiva sobre su rutina')
BEGIN
    INSERT INTO dbo.propositions
    (
        parentproposition,
        statusTypesId,
        creatorPersonId,
        targetPersonId,
        targetSocialAccountId,
        title,
        description,
        startPredictionDateTime,
        endPredictionDateTime,
        winningOption,
        minimumEntryPointsAmount,
        winningProfitPercentage,
        isPublic,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        NULL,
        (
            SELECT TOP 1 statusTypeId
            FROM dbo.statusTypes
            WHERE name = 'Rejected'
        ),
        @johnId,
        @karinaId,
        @socialKarina,
        'Karina rechazó una propuesta invasiva sobre su rutina',
        'Proposición rechazada por la persona objetivo. Se conserva como ejemplo de control de integridad y consentimiento.',
        DATEADD(DAY, -6, SYSDATETIME()),
        DATEADD(DAY, -5, SYSDATETIME()),
        NULL,
        1,
        10,
        1,
        DATEADD(DAY, -6, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.notifications
    WHERE personId = @karinaId
      AND title = 'Penalización aplicada'
)
BEGIN
    INSERT INTO dbo.notifications
    (
        notificationTypeId,
        personId,
        title,
        message,
        isRead,
        readAt,
        referenceTypeId,
        referenceId,
        createdAt,
        updatedAt,
        isDeleted
    )
    VALUES
    (
        @ntPenalty,
        @karinaId,
        'Penalización aplicada',
        'Se aplicó una penalización de 1 punto por rechazar una proposición ganadora.',
        0,
        NULL,
        @refPropositionId,
        @pendingParentId,
        DATEADD(DAY, -1, SYSDATETIME()),
        SYSDATETIME(),
        0
    );
END;

/* ============================================================
   12. CORRECCIÓN FINAL DE PUNTOS PARA FRONTEND

   Regla del MVP:
   - Si la predicción usa puntos, pointsAmount debe ser 1.
   - Si la predicción es solo de dinero, pointsAmount debe ser 0.
   - Si la predicción es mixta, pointsAmount debe ser 1 y moneyAmount > 0.

   Esto corrige datos ya existentes aunque los INSERT no se ejecuten
   por los IF NOT EXISTS.
============================================================ */

UPDATE dbo.propositions
SET minimumEntryPointsAmount = 1,
    updatedAt = SYSDATETIME()
WHERE title IN
(
    'Elizabeth publicó que está entrenando para una maratón',
    'John anunció que va a participar en un torneo de ajedrez',
    'Elizabeth no asistirá a la maratón',
    'Elizabeth terminará dentro de los primeros 30 lugares',
    'Elizabeth logrará al menos el décimo lugar',
    'John llegará a semifinales del torneo',
    'John perderá en la primera ronda',
    'Karina anunció que intentará subir contenido fitness durante 7 días',
    'Karina publicará contenido fitness todos los días de esta semana',
    'Elizabeth completará la maratón en menos de 5 horas',
    'Karina subió al menos tres videos fitness en una semana',
    'Karina rechazó una propuesta invasiva sobre su rutina'
);

UPDATE dbo.propositions
SET minimumEntryPointsAmount = NULL,
    updatedAt = SYSDATETIME()
WHERE title IN
(
    'John ganará al menos dos partidas del torneo',
    'Elizabeth corrió más de 10 km el domingo'
);

UPDATE dbo.predictions
SET pointsAmount = 1,
    updatedAt = SYSDATETIME()
WHERE propositionId IN
(
    SELECT propositionId
    FROM dbo.propositions
    WHERE title IN
    (
        'Elizabeth completará la maratón en menos de 5 horas',
        'Karina subió al menos tres videos fitness en una semana'
    )
)
AND moneyAmount = 0;

UPDATE dbo.predictions
SET pointsAmount = 1,
    updatedAt = SYSDATETIME()
WHERE propositionId IN
(
    SELECT propositionId
    FROM dbo.propositions
    WHERE title = 'Elizabeth completará la maratón en menos de 5 horas'
)
AND moneyAmount > 0;

UPDATE dbo.predictions
SET pointsAmount = 0,
    updatedAt = SYSDATETIME()
WHERE propositionId IN
(
    SELECT propositionId
    FROM dbo.propositions
    WHERE title IN
    (
        'John ganará al menos dos partidas del torneo',
        'Elizabeth corrió más de 10 km el domingo'
    )
);

/* ============================================================
   13. VERIFICACIÓN RÁPIDA
============================================================ */

SELECT
    'Usuarios demo' AS item,
    COUNT(*) AS total
FROM dbo.people
WHERE email IN
(
    'elizabeth.rojas@gathel.demo',
    'john.miller@gathel.demo',
    'karina.soto@gathel.demo'
)

UNION ALL

SELECT
    'Proposiciones demo',
    COUNT(*)
FROM dbo.propositions
WHERE creatorPersonId IN (@elizabethId, @johnId, @karinaId)
   OR targetPersonId IN (@elizabethId, @johnId, @karinaId)

UNION ALL

SELECT
    'Votos demo',
    COUNT(*)
FROM dbo.propositionVotes
WHERE personId IN (@elizabethId, @johnId, @karinaId)

UNION ALL

SELECT
    'Predicciones demo',
    COUNT(*)
FROM dbo.predictions
WHERE personId IN (@elizabethId, @johnId, @karinaId)

UNION ALL

SELECT
    'Notificaciones demo',
    COUNT(*)
FROM dbo.notifications
WHERE personId IN (@elizabethId, @johnId, @karinaId);

COMMIT TRANSACTION;
