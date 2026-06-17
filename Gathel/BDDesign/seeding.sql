/*=========================================================
  PEOPLE TYPES 
=========================================================*/

INSERT INTO peopleTypes(name, description)
VALUES
('Player', 'Regular player'),
('Admin', 'System administrator'),
('Moderator', 'Content moderator'),
('Auditor', 'System auditor');


/*=========================================================
  COUNTRIES
=========================================================*/

INSERT INTO countries(name, isoCode)
VALUES
('Costa Rica','CRI'),
('Mexico','MEX'),
('Colombia','COL'),
('Argentina','ARG'),
('Chile','CHL'),
('Peru','PER'),
('Spain','ESP'),
('United States','USA'),
('Canada','CAN'),
('Brazil','BRA');


/*=========================================================
  STATES
=========================================================*/

DECLARE @countryId INT = 1;
DECLARE @stateNumber INT;

WHILE @countryId <= 10
BEGIN

    SET @stateNumber = 1;

    WHILE @stateNumber <= 5
    BEGIN

        INSERT INTO states
        (
            countryId,
            name
        )
        VALUES
        (
            @countryId,
            CONCAT('State_', @countryId, '_', @stateNumber)
        );

        SET @stateNumber += 1;

    END

    SET @countryId += 1;

END;


/*=========================================================
  CITIES
=========================================================*/

DECLARE @stateId INT = 1;
DECLARE @cityNumber INT;

WHILE @stateId <= 50
BEGIN

    SET @cityNumber = 1;

    WHILE @cityNumber <= 5
    BEGIN

        INSERT INTO cities
        (
            stateId,
            name
        )
        VALUES
        (
            @stateId,
            CONCAT('City_', @stateId, '_', @cityNumber)
        );

        SET @cityNumber += 1;

    END

    SET @stateId += 1;

END;


/*=========================================================
  ADDRESSES
=========================================================*/

DECLARE @cityId INT = 1;
DECLARE @addressNumber INT;

WHILE @cityId <= 250
BEGIN

    SET @addressNumber = 1;

    WHILE @addressNumber <= 5
    BEGIN

        INSERT INTO addresses
        (
            cityId,
            exactAddress
        )
        VALUES
        (
            @cityId,
            CONCAT
            (
                'Street ',
                @addressNumber,
                ', Building ',
                ABS(CHECKSUM(NEWID())) % 1000 + 1
            )
        );

        SET @addressNumber += 1;

    END

    SET @cityId += 1;

END;


/*=========================================================
  CURRENCIES
=========================================================*/

INSERT INTO currencies
(
    name,
    code,
    symbol,
    isDefaultCurrencie
)
VALUES
('US Dollar','USD','$',1),
('Costa Rican Colon','CRC','₡',0),
('Euro','EUR','€',0),
('Mexican Peso','MXN','$',0),
('Brazilian Real','BRL','R$',0);


/*=========================================================
  EXCHANGE RATES
=========================================================*/

INSERT INTO exchangeRates
(
    currencyId,
    rate,
    isCurrent,
    exchangeDateTime
)
SELECT
    currencyId,
    CASE code
        WHEN 'USD' THEN 1.000000
        WHEN 'CRC' THEN 505.250000
        WHEN 'EUR' THEN 0.920000
        WHEN 'MXN' THEN 18.500000
        WHEN 'BRL' THEN 5.420000
    END,
    1,
    GETDATE()
FROM currencies;


/*=========================================================
  STATUS TYPES
=========================================================*/

INSERT INTO statusTypes
(
    name,
    description
)
VALUES
('Pending','Pending process'),
('Active','Currently active'),
('Completed','Completed successfully'),
('Cancelled','Cancelled process'),
('Rejected','Rejected process'),
('Suspended','Suspended entity'),
('Resolved','Resolved process');


/*=========================================================
  PLAYERS
=========================================================*/

DECLARE @counter INT = 1;

DECLARE @playerTypeId INT =
(
    SELECT peopleTypeId
    FROM peopleTypes
    WHERE name = 'Player'
);

DECLARE @maxAddressId INT =
(
    SELECT MAX(addressId)
    FROM addresses
);

DECLARE @birthDate DATE;
DECLARE @createdAt DATETIME2(3);

WHILE @counter <= 1000
BEGIN

    SET @birthDate =
    DATEADD
    (
        DAY,
        -(ABS(CHECKSUM(NEWID())) % 10000 + 7000),
        GETDATE()
    );

    SET @createdAt =
    DATEADD
    (
        DAY,
        ABS(CHECKSUM(NEWID())) % 1000,
        DATEADD(YEAR,18,@birthDate)
    );

    INSERT INTO people
    (
        peopleTypeId,
        name,
        lastName,
        identification,
        phone,
        email,
        username,
        biography,
        birthDate,
        addressId,
        isVerified,
        isActive,
        createdAt,
        updatedAt
    )
    VALUES
    (
        @playerTypeId,

        CONCAT('Player',@counter),

        CONCAT('LastName',@counter),

        CONCAT(
            'ID',
            RIGHT('000000'+CAST(@counter AS VARCHAR(6)),6)
        ),

        CONCAT(
            '8',
            RIGHT('0000000'+CAST(@counter AS VARCHAR(7)),7)
        ),

        CONCAT
        (
            'player',
            @counter,
            '@',
            CASE @counter % 4
                WHEN 0 THEN 'gmail.com'
                WHEN 1 THEN 'hotmail.com'
                WHEN 2 THEN 'outlook.com'
                ELSE 'yahoo.com'
            END
        ),

        CONCAT('player_',@counter),

        CONCAT('Biography for player ',@counter),

        @birthDate,

        ABS(CHECKSUM(NEWID())) % @maxAddressId + 1,

        CASE
            WHEN @counter % 5 = 0 THEN 0
            ELSE 1
        END,

        CASE
            WHEN @counter % 50 = 0 THEN 0
            ELSE 1
        END,

        @createdAt,

        @createdAt
    );

    SET @counter += 1;

END;


/*=========================================================
  ADMINS
=========================================================*/

SET @counter = 1;

WHILE @counter <= 5
BEGIN

    INSERT INTO people
    (
        peopleTypeId,
        name,
        lastName,
        identification,
        phone,
        email,
        username,
        isVerified,
        isActive
    )
    VALUES
    (
        2,
        CONCAT('Admin',@counter),
        'System',
        CONCAT('ADMIN',@counter),
        CONCAT('700000',@counter),
        CONCAT('admin',@counter,'@gathel.com'),
        CONCAT('admin_',@counter),
        1,
        1
    );

    SET @counter += 1;

END;


/*=========================================================
  MODERATORS
=========================================================*/

SET @counter = 1;

WHILE @counter <= 10
BEGIN

    INSERT INTO people
    (
        peopleTypeId,
        name,
        lastName,
        identification,
        phone,
        email,
        username,
        isVerified,
        isActive
    )
    VALUES
    (
        3,
        CONCAT('Moderator',@counter),
        'System',
        CONCAT('MOD',@counter),
        CONCAT('710000',@counter),
        CONCAT('moderator',@counter,'@gathel.com'),
        CONCAT('moderator_',@counter),
        1,
        1
    );

    SET @counter += 1;

END;


/*=========================================================
  AUDITORS
=========================================================*/

SET @counter = 1;

WHILE @counter <= 5
BEGIN

    INSERT INTO people
    (
        peopleTypeId,
        name,
        lastName,
        identification,
        phone,
        email,
        username,
        isVerified,
        isActive
    )
    VALUES
    (
        4,
        CONCAT('Auditor',@counter),
        'System',
        CONCAT('AUD',@counter),
        CONCAT('720000',@counter),
        CONCAT('auditor',@counter,'@gathel.com'),
        CONCAT('auditor_',@counter),
        1,
        1
    );

    SET @counter += 1;

END;


/*=========================================================
  WALLETS
=========================================================*/

INSERT INTO wallets
(
    personId,
    isBlocked,
    createdAt,
    updatedAt
)
SELECT
    personId,

    CASE
        WHEN isActive = 0 THEN 1
        ELSE 0
    END,

    createdAt,
    updatedAt
FROM people;

/*=========================================================
  REFERENCE TYPES
=========================================================*/

INSERT INTO referenceTypes
(
    name
)
VALUES
('Proposition'),
('Prediction'),
('WalletTransaction'),
('Transaction'),
('Report'),
('Penalty'),
('Notification'),
('Commission'),
('WalletReservation'),
('Payout');


/*=========================================================
  TRANSACTION TYPES
=========================================================*/

INSERT INTO transactionTypes
(
    name,
    description
)
VALUES
('Deposit','User deposits money into the platform'),
('Withdrawal','User withdraws money from the platform'),
('PredictionEntry','Entry payment for a prediction'),
('PredictionPayout','Winning payout for a prediction'),
('Commission','Commission charged by platform'),
('Penalty','Penalty deduction'),
('Refund','Refund of a previous transaction');

/*=========================================================
  REPORT TYPES
=========================================================*/

INSERT INTO reportTypes
(
    name,
    description
)
VALUES
('Spam','Spam or repetitive content'),
('OffensiveContent','Offensive or inappropriate content'),
('FalseInformation','Misleading or false information'),
('Harassment','Harassment against another user'),
('Fraud','Fraudulent activity'),
('Other','Other policy violation');

/*=========================================================
  PENALTY TYPES
=========================================================*/

INSERT INTO penaltyTypes
(
    name,
    description,
    pointsPercentage
)
VALUES
(
    'Warning',
    'Minor violation',
    5.00
),
(
    'MinorPenalty',
    'Small points deduction',
    10.00
),
(
    'ModeratePenalty',
    'Medium points deduction',
    25.00
),
(
    'MajorPenalty',
    'Severe points deduction',
    50.00
),
(
    'AccountSuspension',
    'Account temporarily suspended',
    100.00
);

/*=========================================================
  COMISSION TYPES
=========================================================*/

INSERT INTO commissionTypes
(
    name,
    description,
    percentage,
    isActive
)
VALUES
(
    'PredictionEntryFee',
    'Commission charged when entering a prediction',
    3.00,
    1
),
(
    'PredictionPayoutFee',
    'Commission deducted from winnings',
    5.00,
    1
),
(
    'DepositFee',
    'Commission charged on deposits',
    1.50,
    1
),
(
    'WithdrawalFee',
    'Commission charged on withdrawals',
    2.50,
    1
);

/*=========================================================
  NOTIFICATION TYPES
=========================================================*/

INSERT INTO notificationTypes
(
    name,
    description
)
VALUES
(
    'PredictionCreated',
    'A new prediction has been created'
),
(
    'PredictionClosed',
    'Prediction has been closed'
),
(
    'PredictionWon',
    'User won a prediction'
),
(
    'PredictionLost',
    'User lost a prediction'
),
(
    'TransactionCompleted',
    'Transaction processed successfully'
),
(
    'ReportReceived',
    'A report has been submitted'
),
(
    'PenaltyApplied',
    'A penalty has been applied'
),
(
    'AccountVerified',
    'Account verification completed'
);

/*=========================================================
  FILE TYPES
=========================================================*/

INSERT INTO fileTypes
(
    name,
    mimeType,
    description
)
VALUES
(
    'PNG',
    'image/png',
    'Portable Network Graphics'
),
(
    'JPG',
    'image/jpeg',
    'JPEG Image'
),
(
    'SVG',
    'image/svg+xml',
    'Scalable Vector Graphics'
),
(
    'PDF',
    'application/pdf',
    'Portable Document Format'
);

/*=========================================================
  FILE USAGE TYPES
=========================================================*/

INSERT INTO fileUsageTypes
(
    name,
    description
)
VALUES
(
    'PlatformLogo',
    'Logo for social platforms'
),
(
    'PaymentMethodLogo',
    'Logo for payment methods'
),
(
    'ProfilePicture',
    'User profile image'
),
(
    'PropositionImage',
    'Image attached to proposition'
),
(
    'Evidence',
    'Evidence attached to reports'
);

/*=========================================================
  SOCIAL FILES
=========================================================*/

DECLARE @pngTypeId INT =
(
    SELECT fileTypeId
    FROM fileTypes
    WHERE name = 'PNG'
);

INSERT INTO files
(
    fileTypeId,
    fileName,
    fileUrl,
    fileSize,
    uploadedByPersonId
)
VALUES
(@pngTypeId,'twitter.png','/logos/twitter.png',25000,1001),
(@pngTypeId,'instagram.png','/logos/instagram.png',28000,1001),
(@pngTypeId,'tiktok.png','/logos/tiktok.png',24000,1001),
(@pngTypeId,'youtube.png','/logos/youtube.png',26000,1001),
(@pngTypeId,'facebook.png','/logos/facebook.png',27000,1001);

/*=========================================================
  PAYMENT FILES
=========================================================*/

INSERT INTO files
(
    fileTypeId,
    fileName,
    fileUrl,
    fileSize,
    uploadedByPersonId
)
VALUES
(@pngTypeId,'creditcard.png','/logos/creditcard.png',22000,1001),
(@pngTypeId,'paypal.png','/logos/paypal.png',24000,1001),
(@pngTypeId,'banktransfer.png','/logos/banktransfer.png',21000,1001),
(@pngTypeId,'sinpe.png','/logos/sinpe.png',19000,1001);

/*=========================================================
  SOCIAL PLATFOMRS
=========================================================*/

INSERT INTO socialPlatforms
(
    name,
    apiUrl,
    logo,
    config
)
VALUES
(
    'Twitter',
    'https://api.twitter.com',
    (
        SELECT fileId
        FROM files
        WHERE fileName='twitter.png'
    ),
    '{"supportsFollowers":true,"supportsVerification":true}'
),
(
    'Instagram',
    'https://graph.instagram.com',
    (
        SELECT fileId
        FROM files
        WHERE fileName='instagram.png'
    ),
    '{"supportsFollowers":true,"supportsVerification":true}'
),
(
    'TikTok',
    'https://open.tiktokapis.com',
    (
        SELECT fileId
        FROM files
        WHERE fileName='tiktok.png'
    ),
    '{"supportsFollowers":true,"supportsVerification":true}'
),
(
    'YouTube',
    'https://www.googleapis.com/youtube/v3',
    (
        SELECT fileId
        FROM files
        WHERE fileName='youtube.png'
    ),
    '{"supportsSubscribers":true,"supportsVerification":true}'
),
(
    'Facebook',
    'https://graph.facebook.com',
    (
        SELECT fileId
        FROM files
        WHERE fileName='facebook.png'
    ),
    '{"supportsPages":true,"supportsVerification":true}'
);

/*=========================================================
  PAYMENT METHODS
=========================================================*/

INSERT INTO paymentMethods
(
    name,
    logo,
    config
)
VALUES
(
    'Credit Card',
    (
        SELECT fileId
        FROM files
        WHERE fileName='creditcard.png'
    ),
    '{"supportsRefunds":true,"currencies":["USD","CRC","EUR"]}'
),
(
    'PayPal',
    (
        SELECT fileId
        FROM files
        WHERE fileName='paypal.png'
    ),
    '{"supportsRefunds":true,"currencies":["USD","EUR"]}'
),
(
    'Bank Transfer',
    (
        SELECT fileId
        FROM files
        WHERE fileName='banktransfer.png'
    ),
    '{"supportsRefunds":false,"currencies":["USD","CRC","EUR","MXN"]}'
),
(
    'SINPE Movil',
    (
        SELECT fileId
        FROM files
        WHERE fileName='sinpe.png'
    ),
    '{"supportsRefunds":false,"currencies":["CRC"]}'
);



/*=========================================================
  SOCIAL ACCOUNTS
=========================================================*/

DECLARE @personId INT = 1;
DECLARE @accountsToCreate INT;
DECLARE @platformId INT;
DECLARE @createdAccounts INT;

WHILE @personId <= 1000
BEGIN

    --------------------------------------------------
    -- Cantidad de redes por jugador
    --------------------------------------------------

    SET @accountsToCreate =
    CASE
        WHEN @personId % 10 < 5 THEN 1
        WHEN @personId % 10 < 8 THEN 2
        ELSE 3
    END;

    SET @createdAccounts = 0;

    WHILE @createdAccounts < @accountsToCreate
    BEGIN

        SET @platformId =
            ABS(CHECKSUM(NEWID())) % 5 + 1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM socialAccounts
            WHERE personId = @personId
            AND socialPlatformId = @platformId
        )
        BEGIN

            INSERT INTO socialAccounts
            (
                personId,
                socialPlatformId,
                username,
                profileUrl,
                accessToken,
                refreshToken,
                isVerified,
                auditPersonId
            )
            VALUES
            (
                @personId,

                @platformId,

                CONCAT
                (
                    'player',
                    @personId,
                    '_',
                    @platformId
                ),

                CONCAT
                (
                    'https://platform',
                    @platformId,
                    '.com/player',
                    @personId
                ),

                CAST
                (
                    CONCAT
                    (
                        'ACCESS_',
                        @personId,
                        '_',
                        @platformId
                    )
                    AS VARBINARY(MAX)
                ),

                CAST
                (
                    CONCAT
                    (
                        'REFRESH_',
                        @personId,
                        '_',
                        @platformId
                    )
                    AS VARBINARY(MAX)
                ),

                CASE
                    WHEN @personId % 20 = 0
                    THEN 1
                    ELSE 0
                END,

                1001
            );

            SET @createdAccounts += 1;

        END;

    END;

    SET @personId += 1;

END;


/*=========================================================
  AUTH SESSIONS
=========================================================*/

DECLARE @personId INT = 1;
DECLARE @sessionCount INT;
DECLARE @sessionNumber INT;
DECLARE @sessionCreated DATETIME2(3);

WHILE @personId <= 1000
BEGIN

    SET @sessionCount =
    CASE
        WHEN @personId % 10 < 5 THEN 1
        WHEN @personId % 10 < 8 THEN 3
        ELSE 5
    END;

    SET @sessionNumber = 1;

    WHILE @sessionNumber <= @sessionCount
    BEGIN

        SET @sessionCreated =
        DATEADD
        (
            DAY,
            -(ABS(CHECKSUM(NEWID())) % 365),
            GETDATE()
        );

        INSERT INTO authSessions
        (
            personId,
            refreshToken,
            ipAddress,
            expiresAt,
            lastActivityAt,
            isRevoked,
            auditPersonId,
            createdAt,
            updatedAt
        )
        VALUES
        (
            @personId,

            CAST
            (
                CONCAT
                (
                    'SESSION_',
                    @personId,
                    '_',
                    @sessionNumber
                )
                AS VARBINARY(MAX)
            ),

            CONCAT
            (
                '192.168.',
                ABS(CHECKSUM(NEWID())) % 255,
                '.',
                ABS(CHECKSUM(NEWID())) % 255
            ),


            DATEADD
            (
                DAY,
                30,
                @sessionCreated
            ),

            DATEADD
            (
                DAY,
                ABS(CHECKSUM(NEWID())) % 30,
                @sessionCreated
            ),

            CASE
                WHEN @personId % 100 = 0
                THEN 1
                ELSE 0
            END,

            1001,

            @sessionCreated,

            @sessionCreated
        );

        SET @sessionNumber += 1;

    END;

    SET @personId += 1;

END;


/*=========================================================
  SECURITY EVENT TYPES
=========================================================*/

INSERT INTO securityEventTypes
(
    name,
    description
)
VALUES
(
    'SuccessfulLogin',
    'Successful login'
),
(
    'FailedLogin',
    'Failed login attempt'
),
(
    'PasswordChange',
    'Password changed'
),
(
    'AccountLocked',
    'Account temporarily locked'
),
(
    'TokenRevoked',
    'Session token revoked'
),
(
    'SuspiciousActivity',
    'Suspicious activity detected'
);


/*=========================================================
  SECURITY EVENTS
=========================================================*/

DECLARE @authSessionId INT = 1;
DECLARE @maxSessionId INT;

SET @maxSessionId =
(
    SELECT MAX(authSessionId)
    FROM authSessions
);

WHILE @authSessionId <= @maxSessionId
BEGIN

    ----------------------------------------------------
    -- Login exitoso
    ----------------------------------------------------

    INSERT INTO securityEvents
    (
        securityEventTypeId,
        personId,
        authSessionId,
        eventDateTime,
        details
    )
    SELECT
        1,
        personId,
        authSessionId,
        createdAt,
        'Login successful'
    FROM authSessions
    WHERE authSessionId = @authSessionId;

    ----------------------------------------------------
    -- Algunos failed logins
    ----------------------------------------------------

    IF @authSessionId % 10 = 0
    BEGIN

        INSERT INTO securityEvents
        (
            securityEventTypeId,
            personId,
            authSessionId,
            eventDateTime,
            details
        )
        SELECT
            2,
            personId,
            authSessionId,
            DATEADD(MINUTE,-5,createdAt),
            'Failed login before success'
        FROM authSessions
        WHERE authSessionId = @authSessionId;

    END;

    ----------------------------------------------------
    -- Casos sospechosos
    ----------------------------------------------------

    IF @authSessionId % 100 = 0
    BEGIN

        INSERT INTO securityEvents
        (
            securityEventTypeId,
            personId,
            authSessionId,
            eventDateTime,
            details
        )
        SELECT
            6,
            personId,
            authSessionId,
            DATEADD(MINUTE,10,createdAt),
            'Login from unusual device'
        FROM authSessions
        WHERE authSessionId = @authSessionId;

    END;

    SET @authSessionId += 1;

END;

DECLARE @seCounter INT = 1;

WHILE @seCounter <= 5000
BEGIN

    INSERT INTO securityEvents
    (
        securityEventTypeId,
        personId,
        authSessionId,
        eventDateTime,
        details
    )
    VALUES
    (
        ABS(CHECKSUM(NEWID())) % 6 + 1,
        ABS(CHECKSUM(NEWID())) % 1000 + 1,
        ABS(CHECKSUM(NEWID())) % 5000 + 1,
        DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 365), GETDATE()),
        'Automated security event'
    );

    SET @seCounter += 1;

END;


/*=========================================================
  PROPOSITIONS
=========================================================*/

DECLARE @propositionIdCounter INT = 1;

DECLARE @statusId INT;
DECLARE @creatorId INT;
DECLARE @targetPersonId INT;
DECLARE @targetSocialAccountId INT;

DECLARE @startDate DATETIME2(3);
DECLARE @endDate DATETIME2(3);

WHILE @propositionIdCounter <= 5000
BEGIN

    --------------------------------------------------
    -- Estado
    --------------------------------------------------

    SET @statusId =
    CASE
        WHEN @propositionIdCounter % 10 < 7 THEN 2
        WHEN @propositionIdCounter % 10 < 9 THEN 3
        ELSE 4
    END;

    --------------------------------------------------
    -- Creador
    --------------------------------------------------

    SET @creatorId =
        ABS(CHECKSUM(NEWID())) % 1000 + 1;

    --------------------------------------------------
    -- Fechas
    --------------------------------------------------

    IF @statusId = 2
    BEGIN

        SET @startDate =
            DATEADD
            (
                DAY,
                -(ABS(CHECKSUM(NEWID())) % 30),
                GETDATE()
            );

        SET @endDate =
            DATEADD
            (
                DAY,
                ABS(CHECKSUM(NEWID())) % 90 + 1,
                GETDATE()
            );

    END
    ELSE
    BEGIN

        SET @startDate =
            DATEADD
            (
                DAY,
                -(ABS(CHECKSUM(NEWID())) % 180 + 60),
                GETDATE()
            );

        SET @endDate =
            DATEADD
            (
                DAY,
                ABS(CHECKSUM(NEWID())) % 30 + 1,
                @startDate
            );

    END;

    --------------------------------------------------
    -- Target
    --------------------------------------------------

    SET @targetPersonId = NULL;
    SET @targetSocialAccountId = NULL;

    IF @propositionIdCounter % 10 < 6
    BEGIN

        SET @targetPersonId =
            ABS(CHECKSUM(NEWID())) % 1000 + 1;

    END
    ELSE
    BEGIN

        SET @targetSocialAccountId =
            ABS(CHECKSUM(NEWID())) % 1700 + 1;

    END;

    INSERT INTO propositions
    (
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
        isPublic
    )
    VALUES
    (
        @statusId,

        @creatorId,

        @targetPersonId,

        @targetSocialAccountId,

        CONCAT
        (
            'Prediction #',
            @propositionIdCounter
        ),

        CONCAT
        (
            'Generated proposition ',
            @propositionIdCounter
        ),

        @startDate,

        @endDate,

        CASE
            WHEN @statusId = 3
            THEN ABS(CHECKSUM(NEWID())) % 2
            ELSE NULL
        END,

        (ABS(CHECKSUM(NEWID())) % 901) + 100,

        (ABS(CHECKSUM(NEWID())) % 41) + 10,

        CASE
            WHEN @propositionIdCounter % 5 = 0
            THEN 0
            ELSE 1
        END
    );

    SET @propositionIdCounter += 1;

END;


/*=========================================================
  PROPOSITION VOTES
=========================================================*/

DECLARE @propositionId INT = 1;

DECLARE @votesToCreate INT;
DECLARE @currentVote INT;

DECLARE @personId INT;
DECLARE @voteValue BIT;

WHILE @propositionId <= 5000
BEGIN

    SET @votesToCreate =
    CASE
        WHEN @propositionId % 100 < 50
            THEN ABS(CHECKSUM(NEWID())) % 16

        WHEN @propositionId % 100 < 85
            THEN ABS(CHECKSUM(NEWID())) % 45 + 16

        WHEN @propositionId % 100 < 97
            THEN ABS(CHECKSUM(NEWID())) % 90 + 61

        ELSE
            ABS(CHECKSUM(NEWID())) % 350 + 151
    END;

    SET @currentVote = 1;

    WHILE @currentVote <= @votesToCreate
    BEGIN

        SET @personId =
            ABS(CHECKSUM(NEWID())) % 1000 + 1;

        SET @voteValue =
            ABS(CHECKSUM(NEWID())) % 2;

        IF NOT EXISTS
        (
            SELECT 1
            FROM propositionVotes
            WHERE propositionId = @propositionId
            AND personId = @personId
        )
        BEGIN

            INSERT INTO propositionVotes
            (
                propositionId,
                personId,
                voteValue
            )
            VALUES
            (
                @propositionId,
                @personId,
                @voteValue
            );

        END;

        SET @currentVote += 1;

    END;

    SET @propositionId += 1;

END;


/*=========================================================
  PROPOSITION LIKES
=========================================================*/

SET @propositionId = 1;

DECLARE @likesToCreate INT;
DECLARE @currentLike INT;

WHILE @propositionId <= 5000
BEGIN

    SET @likesToCreate =
    CASE
        WHEN @propositionId % 100 < 50
            THEN ABS(CHECKSUM(NEWID())) % 6

        WHEN @propositionId % 100 < 85
            THEN ABS(CHECKSUM(NEWID())) % 15 + 6

        WHEN @propositionId % 100 < 97
            THEN ABS(CHECKSUM(NEWID())) % 30 + 21

        ELSE
            ABS(CHECKSUM(NEWID())) % 150 + 51
    END;

    SET @currentLike = 1;

    WHILE @currentLike <= @likesToCreate
    BEGIN

        SET @personId =
            ABS(CHECKSUM(NEWID())) % 1000 + 1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM propositionLikes
            WHERE propositionId = @propositionId
            AND personId = @personId
        )
        BEGIN

            INSERT INTO propositionLikes
            (
                propositionId,
                personId
            )
            VALUES
            (
                @propositionId,
                @personId
            );

        END;

        SET @currentLike += 1;

    END;

    SET @propositionId += 1;

END;


/*=========================================================
  PROPOSITION COMMENTS
=========================================================*/

SET @propositionId = 1;

DECLARE @commentsToCreate INT;
DECLARE @currentComment INT;

DECLARE @createdAt DATETIME2(3);

WHILE @propositionId <= 5000
BEGIN

    SELECT
        @createdAt = createdAt
    FROM propositions
    WHERE propositionId = @propositionId;

    SET @commentsToCreate =
    CASE
        WHEN @propositionId % 100 < 50
            THEN ABS(CHECKSUM(NEWID())) % 4

        WHEN @propositionId % 100 < 85
            THEN ABS(CHECKSUM(NEWID())) % 12 + 4

        WHEN @propositionId % 100 < 97
            THEN ABS(CHECKSUM(NEWID())) % 25 + 16

        ELSE
            ABS(CHECKSUM(NEWID())) % 60 + 41
    END;

    SET @currentComment = 1;

    WHILE @currentComment <= @commentsToCreate
    BEGIN

        SET @personId =
            ABS(CHECKSUM(NEWID())) % 1000 + 1;

        INSERT INTO propositionComments
        (
            propositionId,
            personId,
            comment,
            commentedAt
        )
        VALUES
        (
            @propositionId,

            @personId,

            CONCAT
            (
                'Comment ',
                @currentComment,
                ' for proposition ',
                @propositionId
            ),

            DATEADD
            (
                HOUR,
                @currentComment,
                @createdAt
            )
        );

        SET @currentComment += 1;

    END;

    SET @propositionId += 1;

END;


/*=========================================================
  STATUS HISTORY
=========================================================*/

INSERT INTO statusHistory
(
    referenceTypeId,
    referenceId,
    statusTypeId,
    changedAt,
    auditPersonId
)
SELECT
    1,
    propositionId,
    statusTypesId,
    createdAt,
    creatorPersonId
FROM propositions;

DECLARE @shCounter INT = 1;

WHILE @shCounter <= 5000
BEGIN

    INSERT INTO statusHistory
    (
        referenceTypeId,
        referenceId,
        statusTypeId,
        changedAt,
        auditPersonId
    )
    VALUES
    (
        ABS(CHECKSUM(NEWID())) % 10 + 1,
        ABS(CHECKSUM(NEWID())) % 5000 + 1,
        ABS(CHECKSUM(NEWID())) % 7 + 1,
        DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 365), GETDATE()),
        1001
    );

    SET @shCounter += 1;

END;


/*=========================================================
  PREDICTIONS
=========================================================*/

DECLARE @propositionId INT = 1;

DECLARE @statusId INT;
DECLARE @winningOption BIT;

DECLARE @predictionsToCreate INT;
DECLARE @currentPrediction INT;

DECLARE @personId INT;

DECLARE @predictionValue BIT;

DECLARE @pointsAmount NUMERIC(10,2);

DECLARE @currencyId INT;
DECLARE @exchangeRateId INT;

WHILE @propositionId <= 5000
BEGIN

    SELECT
        @statusId = statusTypesId,
        @winningOption = winningOption
    FROM propositions
    WHERE propositionId = @propositionId;

    ---------------------------------------------------
    -- Popularidad
    ---------------------------------------------------

    SET @predictionsToCreate =
    CASE
        WHEN @propositionId % 100 < 50
            THEN ABS(CHECKSUM(NEWID())) % 21 + 5

        WHEN @propositionId % 100 < 85
            THEN ABS(CHECKSUM(NEWID())) % 35 + 26

        WHEN @propositionId % 100 < 97
            THEN ABS(CHECKSUM(NEWID())) % 60 + 61

        ELSE
            ABS(CHECKSUM(NEWID())) % 280 + 121
    END;

    SET @currentPrediction = 1;

    WHILE @currentPrediction <= @predictionsToCreate
    BEGIN

        SET @personId =
            ABS(CHECKSUM(NEWID())) % 1000 + 1;

        ---------------------------------------------------
        -- Un jugador no puede apostar dos veces
        ---------------------------------------------------

        IF NOT EXISTS
        (
            SELECT 1
            FROM predictions
            WHERE propositionId = @propositionId
            AND personId = @personId
        )
        BEGIN

            SET @predictionValue =
                ABS(CHECKSUM(NEWID())) % 2;

            SET @pointsAmount =
                (ABS(CHECKSUM(NEWID())) % 4901) + 100;

            SET @currencyId =
                ABS(CHECKSUM(NEWID())) % 5 + 1;

            SET @exchangeRateId =
                @currencyId;

            INSERT INTO predictions
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
                isWinner
            )
            VALUES
            (
                @statusId,

                @propositionId,

                @personId,

                @predictionValue,

                @pointsAmount,

                @pointsAmount / 10.0,

                @currencyId,

                @exchangeRateId,

                DATEADD
                (
                    HOUR,
                    ABS(CHECKSUM(NEWID())) % 240,
                    (
                        SELECT startPredictionDateTime
                        FROM propositions
                        WHERE propositionId = @propositionId
                    )
                ),

                CASE
                    WHEN @statusId = 3
                         AND @predictionValue = @winningOption
                    THEN 1
                    ELSE 0
                END
            );

        END;

        SET @currentPrediction += 1;

    END;

    SET @propositionId += 1;

END;



/*=========================================================
  WALLET RESERVATIONS
=========================================================*/

INSERT INTO walletReservations
(
    walletId,
    predictionId,
    reservedPointsAmount,
    reservedMoneyAmount,
    statusTypeId,
    reservedAt,
    releasedAt
)
SELECT
    w.walletId,

    p.predictionId,

    p.pointsAmount,

    p.moneyAmount,

    CASE
        WHEN pr.statusTypesId = 2 THEN 2
        WHEN pr.statusTypesId = 3 THEN 3
        ELSE 4
    END,

    p.predictionDateTime,

    CASE
        WHEN pr.statusTypesId IN (3,4)
        THEN pr.endPredictionDateTime
        ELSE NULL
    END

FROM predictions p

INNER JOIN wallets w
    ON w.personId = p.personId

INNER JOIN propositions pr
    ON pr.propositionId = p.propositionId;


/*=========================================================
  TRANSACTION ATTEMPTS
=========================================================*/

DECLARE @personId INT = 1;

DECLARE @attemptsToCreate INT;
DECLARE @currentAttempt INT;

DECLARE @transactionTypeId INT;
DECLARE @currencyId INT;
DECLARE @amount NUMERIC(16,2);

WHILE @personId <= 1000
BEGIN

    SET @attemptsToCreate =
    CASE
        WHEN @personId % 100 < 60
            THEN ABS(CHECKSUM(NEWID())) % 5 + 1

        WHEN @personId % 100 < 85
            THEN ABS(CHECKSUM(NEWID())) % 10 + 6

        WHEN @personId % 100 < 95
            THEN ABS(CHECKSUM(NEWID())) % 15 + 16

        ELSE
            ABS(CHECKSUM(NEWID())) % 50 + 31
    END;

    SET @currentAttempt = 1;

    WHILE @currentAttempt <= @attemptsToCreate
    BEGIN

        SET @transactionTypeId =
        CASE
            WHEN ABS(CHECKSUM(NEWID())) % 100 < 70
            THEN 1 -- Deposit
            ELSE 2 -- Withdrawal
        END;

        SET @currencyId =
            ABS(CHECKSUM(NEWID())) % 5 + 1;

        SET @amount =
            (ABS(CHECKSUM(NEWID())) % 9901) + 100;

        INSERT INTO transactionAttempts
        (
            transactionTypeId,
            personId,
            paymentMethodId,
            istransactionLoaded,
            amount,
            currencyId,
            exchangeRateId,
            exchangedAmount,
            attemptedAt
        )
        VALUES
        (
            @transactionTypeId,

            @personId,

            ABS(CHECKSUM(NEWID())) % 4 + 1,

            CASE
                WHEN ABS(CHECKSUM(NEWID())) % 100 < 95
                THEN 1
                ELSE 0
            END,

            @amount,

            @currencyId,

            @currencyId,

            @amount,

            DATEADD
            (
                DAY,
                -(ABS(CHECKSUM(NEWID())) % 365),
                GETDATE()
            )
        );

        SET @currentAttempt += 1;

    END;

    SET @personId += 1;

END;


/*=========================================================
  TRANSACTIONS
=========================================================*/

INSERT INTO transactions
(
    transactionAttemptId,
    personId,
    transactionTypeId,
    paymentMethodId,
    amount,
    currencyId,
    exchangeRateId,
    exchangedAmount,
    processedAt
)
SELECT
    ta.transactionAttemptId,
    ta.personId,
    ta.transactionTypeId,
    ta.paymentMethodId,
    ta.amount,
    ta.currencyId,
    ta.exchangeRateId,
    ta.exchangedAmount,

    DATEADD
    (
        MINUTE,
        ABS(CHECKSUM(NEWID())) % 120,
        ta.attemptedAt
    )

FROM transactionAttempts ta
WHERE ta.istransactionLoaded = 1;


/*=========================================================
  FINANCIAL MOVEMENTS
=========================================================*/

INSERT INTO financialMovements
(
    transactionTypeId,
    amount,
    currencyId,
    exchangeRateId,
    exchangedAmount,
    referenceTypeId,
    referenceId,
    description
)
SELECT
    t.transactionTypeId,

    t.amount,

    t.currencyId,

    t.exchangeRateId,

    t.exchangedAmount,

    4, -- Transaction

    t.transactionId,

    CONCAT
    (
        'Movement generated by transaction ',
        t.transactionId
    )

FROM transactions t;


INSERT INTO financialMovements
(
    transactionTypeId,
    amount,
    currencyId,
    exchangeRateId,
    exchangedAmount,
    referenceTypeId,
    referenceId,
    description
)
SELECT
    ABS(CHECKSUM(NEWID())) % 7 + 1,
    (ABS(CHECKSUM(NEWID())) % 10000) + 100,
    ABS(CHECKSUM(NEWID())) % 5 + 1,
    ABS(CHECKSUM(NEWID())) % 5 + 1,
    (ABS(CHECKSUM(NEWID())) % 10000) + 100,
    4,
    walletTransactionId,
    'Expanded financial movement'
FROM walletTransactions;


/*=========================================================
  COMMISSIONS
=========================================================*/

INSERT INTO commissions
(
    commissionTypeId,
    referenceTypeId,
    referenceId,
    appliedAmount,
    percentage,
    commissionAmount,
    executedAt
)
SELECT
    2,

    2, -- Prediction

    p.predictionId,

    p.pointsAmount,

    5.00,

    ROUND
    (
        p.pointsAmount * 0.05,
        2
    ),

    DATEADD
    (
        HOUR,
        1,
        pr.endPredictionDateTime
    )

FROM predictions p

INNER JOIN propositions pr
    ON pr.propositionId = p.propositionId

WHERE p.isWinner = 1;


/*=========================================================
  WALLET TRANSACTIONS 
=========================================================*/

INSERT INTO walletTransactions -- WINNER PAYOUTS
(
    originWalletId,
    destinationWalletId,
    isSelfTransaction,
    pointsAmount,
    transactionDateTime,
    referenceTypeId,
    referenceId
)
SELECT
    1001,

    w.walletId,

    0,

    ROUND
    (
        p.pointsAmount *
        (
            1 +
            (pr.winningProfitPercentage / 100.0)
        ),
        2
    ),

    DATEADD
    (
        HOUR,
        2,
        pr.endPredictionDateTime
    ),

    2,

    p.predictionId

FROM predictions p

INNER JOIN propositions pr
    ON pr.propositionId = p.propositionId

INNER JOIN wallets w
    ON w.personId = p.personId

WHERE p.isWinner = 1;

DECLARE @wtCounter INT = 1;

WHILE @wtCounter <= 5000
BEGIN

    INSERT INTO walletTransactions
    (
        originWalletId,
        destinationWalletId,
        isSelfTransaction,
        pointsAmount,
        transactionDateTime,
        referenceTypeId,
        referenceId
    )
    VALUES
    (
        CASE WHEN @wtCounter % 2 = 0 THEN 1001 ELSE ABS(CHECKSUM(NEWID())) % 1000 + 1 END,
        ABS(CHECKSUM(NEWID())) % 1000 + 1,

        CASE WHEN @wtCounter % 5 = 0 THEN 1 ELSE 0 END,

        (ABS(CHECKSUM(NEWID())) % 5000) + 100,

        DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 365), GETDATE()),

        ABS(CHECKSUM(NEWID())) % 10 + 1,

        ABS(CHECKSUM(NEWID())) % 5000 + 1
    );

    SET @wtCounter += 1;

END;

/*=========================================================
  PREDICTION PAYOUTS
=========================================================*/

INSERT INTO predictionPayouts
(
    predictionId,
    walletTransactionId,
    moneyPayoutAmount,
    pointsPayoutAmount,
    commissionAmount,
    executedAt
)
SELECT
    p.predictionId,

    wt.walletTransactionId,

    ROUND
    (
        ISNULL(p.moneyAmount,0) *
        (
            1 +
            (pr.winningProfitPercentage / 100.0)
        ),
        2
    ),

    ROUND
    (
        p.pointsAmount *
        (
            1 +
            (pr.winningProfitPercentage / 100.0)
        ),
        2
    ),

    ROUND
    (
        p.pointsAmount * 0.05,
        2
    ),

    wt.transactionDateTime

FROM predictions p

INNER JOIN propositions pr
    ON pr.propositionId = p.propositionId

INNER JOIN walletTransactions wt
    ON wt.referenceId = p.predictionId
   AND wt.referenceTypeId = 2

WHERE p.isWinner = 1;


/*=========================================================
  WALLET BALANCES
=========================================================*/

INSERT INTO walletBalances
(
    walletId,
    statusTypeId,
    oldPointsAmount,
    balancePointsAmount,
    newPointsAmount,
    calculatedAt
)
SELECT
    w.walletId,

    3,

    0,

    ISNULL
    (
        (
            SELECT SUM(pp.pointsPayoutAmount)
            FROM predictionPayouts pp
            INNER JOIN predictions p
                ON p.predictionId = pp.predictionId
            WHERE p.personId = w.personId
        ),
        0
    )
    -
    ISNULL
    (
        (
            SELECT SUM(pointsAmount)
            FROM predictions p
            WHERE p.personId = w.personId
        ),
        0
    ),

    ISNULL
    (
        (
            SELECT SUM(pp.pointsPayoutAmount)
            FROM predictionPayouts pp
            INNER JOIN predictions p
                ON p.predictionId = pp.predictionId
            WHERE p.personId = w.personId
        ),
        0
    )
    -
    ISNULL
    (
        (
            SELECT SUM(pointsAmount)
            FROM predictions p
            WHERE p.personId = w.personId
        ),
        0
    ),

    GETDATE()

FROM wallets w;

DECLARE @wbCounter INT = 1;

WHILE @wbCounter <= 2000
BEGIN

    INSERT INTO walletBalances
    (
        walletId,
        statusTypeId,
        oldPointsAmount,
        balancePointsAmount,
        newPointsAmount,
        calculatedAt
    )
    VALUES
    (
        ABS(CHECKSUM(NEWID())) % 1000 + 1,

        ABS(CHECKSUM(NEWID())) % 7 + 1,

        (ABS(CHECKSUM(NEWID())) % 5000),

        (ABS(CHECKSUM(NEWID())) % 10000),

        (ABS(CHECKSUM(NEWID())) % 15000),

        DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 365), GETDATE())
    );

    SET @wbCounter += 1;

END;

/*=========================================================
  FINANCIAL BALANCES HISTORY
=========================================================*/

INSERT INTO financialBalancesHistory
(
    totalBalance,
    calculatedAt
)
SELECT
    SUM(amount),

    GETDATE()

FROM financialMovements;

DECLARE @propositionId INT = 1;
DECLARE @reportsToCreate INT;
DECLARE @currentReport INT;

DECLARE @reportTypeId INT;
DECLARE @personId INT;

WHILE @propositionId <= 5000
BEGIN

    SET @reportsToCreate =
        CASE
            WHEN @propositionId % 100 < 60 THEN ABS(CHECKSUM(NEWID())) % 2
            WHEN @propositionId % 100 < 85 THEN ABS(CHECKSUM(NEWID())) % 5
            ELSE ABS(CHECKSUM(NEWID())) % 12 + 3
        END;

    SET @currentReport = 1;

    WHILE @currentReport <= @reportsToCreate
    BEGIN

        SET @personId = ABS(CHECKSUM(NEWID())) % 1000 + 1;

        SET @reportTypeId = ABS(CHECKSUM(NEWID())) % 6 + 1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM reports
            WHERE referenceTypeId = 1
              AND referenceId = @propositionId
              AND personId = @personId
        )
        BEGIN

            INSERT INTO reports
            (
                referenceTypeId,
                referenceId,
                personId,
                reportTypeId,
                description,
                createdAt
            )
            VALUES
            (
                1, -- Proposition
                @propositionId,
                @personId,
                @reportTypeId,
                CONCAT('Report for proposition ', @propositionId),
                DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 30), GETDATE())
            );

        END;

        SET @currentReport += 1;

    END;

    SET @propositionId += 1;

END;


/*=========================================================
  PENALTIES
=========================================================*/

INSERT INTO penalties
(
    personId,
    penaltyTypeId,
    referenceTypeId,
    referenceId,
    pointsPercentage,
    appliedAt
)
SELECT
    r.personId,
    1 + (ABS(CHECKSUM(NEWID())) % 5),
    r.referenceTypeId,
    r.referenceId,
    pt.pointsPercentage,
    r.createdAt
FROM reports r
INNER JOIN penaltyTypes pt
    ON pt.penaltyTypeId =
       (1 + (ABS(CHECKSUM(NEWID())) % 5))
WHERE r.reportId % 7 = 0;

/*=========================================================
  NOTIFICATIONS
=========================================================*/

INSERT INTO notifications
(
    personId,
    notificationTypeId,
    title,
    message,
    isRead,
    createdAt
)
SELECT
    p.personId,
    CASE
        WHEN p.isWinner = 1 THEN 3 -- PredictionWon
        ELSE 4 -- PredictionLost
    END,
    CASE
        WHEN p.isWinner = 1 THEN 'You won a prediction'
        ELSE 'You lost a prediction'
    END,
    CONCAT('Result for proposition ', p.propositionId),
    0,
    GETDATE()
FROM predictions p;


INSERT INTO notifications
(
    personId,
    notificationTypeId,
    title,
    message,
    isRead,
    createdAt
)
SELECT
    ta.personId,
    5, -- TransactionCompleted
    'Transaction completed',
    CONCAT('Transaction of ', ta.amount, ' processed successfully'),
    0,
    ta.attemptedAt
FROM transactionAttempts ta
WHERE ta.istransactionLoaded = 1;


INSERT INTO notifications
(
    personId,
    notificationTypeId,
    title,
    message,
    isRead,
    createdAt
)
SELECT
    r.personId,
    6, -- ReportReceived
    'Report received',
    CONCAT('Your report on reference ', r.referenceId, ' was submitted'),
    0,
    r.createdAt
FROM reports r;

DECLARE @nCounter INT = 1;

WHILE @nCounter <= 5000
BEGIN

    INSERT INTO notifications
    (
        notificationTypeId,
        personId,
        title,
        message,
        isRead,
        readAt,
        referenceTypeId,
        referenceId,
        auditPersonId
    )
    VALUES
    (
        ABS(CHECKSUM(NEWID())) % 8 + 1,
        ABS(CHECKSUM(NEWID())) % 1000 + 1,
        'System Notification',
        CONCAT('Event generated #', @nCounter),
        CASE WHEN @nCounter % 3 = 0 THEN 1 ELSE 0 END,
        GETDATE(),
        ABS(CHECKSUM(NEWID())) % 10 + 1,
        ABS(CHECKSUM(NEWID())) % 5000 + 1,
        1001
    );

    SET @nCounter += 1;

END;


/*=========================================================
  AUDIT LOGS
=========================================================*/

DECLARE @auditCounter INT = 1;

WHILE @auditCounter <= 5000
BEGIN

    INSERT INTO auditLogs
    (
        tableName,
        recordId,
        actionType,
        oldValue,
        newValue,
        personId,
        actionTimestamp
    )
    VALUES
    (
        CASE ABS(CHECKSUM(NEWID())) % 5
            WHEN 0 THEN 'people'
            WHEN 1 THEN 'propositions'
            WHEN 2 THEN 'transactions'
            WHEN 3 THEN 'predictions'
            ELSE 'wallets'
        END,

        ABS(CHECKSUM(NEWID())) % 1000 + 1,

        CASE ABS(CHECKSUM(NEWID())) % 3
            WHEN 0 THEN 'INSERT'
            WHEN 1 THEN 'UPDATE'
            ELSE 'DELETE'
        END,

        NULL,

        CONCAT('value_', @auditCounter),

        ABS(CHECKSUM(NEWID())) % 1000 + 1,

        DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 365), GETDATE())
    );

    SET @auditCounter += 1;

END;

/*=========================================================
  AI VALIDATION RESULTS
=========================================================*/

INSERT INTO aiValidationResults
(
    propositionId,
    statusTypeId,
    aiComments,
    auditPersonId
)
SELECT
    p.propositionId,

    CASE
        WHEN p.statusTypesId = 2 THEN 2   -- Active
        WHEN p.statusTypesId = 3 THEN 3   -- Completed
        WHEN p.statusTypesId = 4 THEN 5   -- Rejected
        ELSE 1                            -- Pending
    END,

    CASE
        WHEN p.statusTypesId = 2
            THEN 'AI validation in progress'

        WHEN p.statusTypesId = 3
            THEN 'AI validation approved'

        WHEN p.statusTypesId = 4
            THEN 'AI validation rejected'

        ELSE
            'AI validation pending'
    END,

    1001

FROM propositions p;


/*=========================================================
  FILE REFERENCES
=========================================================*/

DECLARE @fileRefCounter INT = 1;

WHILE @fileRefCounter <= 2000
BEGIN

    INSERT INTO fileReferences
    (
        fileId,
        referenceTypeId,
        referenceId,
        fileUsageTypeId,
        auditPersonId
    )
    VALUES
    (
        ABS(CHECKSUM(NEWID())) % 9 + 1,

        ABS(CHECKSUM(NEWID())) % 10 + 1,

        ABS(CHECKSUM(NEWID())) % 1000 + 1,

        ABS(CHECKSUM(NEWID())) % 5 + 1,

        1001
    );

    SET @fileRefCounter += 1;

END;

/*=========================================================
  COMMISSIONS
=========================================================*/

DECLARE @cCounter INT = 1;

WHILE @cCounter <= 3000
BEGIN

    INSERT INTO commissions
    (
        commissionTypeId,
        referenceTypeId,
        referenceId,
        appliedAmount,
        percentage,
        commissionAmount,
        executedAt
    )
    VALUES
    (
        ABS(CHECKSUM(NEWID())) % 4 + 1,

        ABS(CHECKSUM(NEWID())) % 10 + 1,

        ABS(CHECKSUM(NEWID())) % 5000 + 1,

        (ABS(CHECKSUM(NEWID())) % 10000) + 100,

        CASE ABS(CHECKSUM(NEWID())) % 4
            WHEN 0 THEN 1.5
            WHEN 1 THEN 2.5
            WHEN 2 THEN 3.0
            ELSE 5.0
        END,

        (ABS(CHECKSUM(NEWID())) % 500) + 10,

        DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 365), GETDATE())
    );

    SET @cCounter += 1;

END;


/*=========================================================
  EXCHANGE RATES HISTORY
=========================================================*/

DECLARE @erCounter INT = 1;

WHILE @erCounter <= 100
BEGIN

    INSERT INTO exchangeRates
    (
        currencyId,
        rate,
        isCurrent,
        exchangeDateTime,
        auditPersonId
    )
    VALUES
    (
        ABS(CHECKSUM(NEWID())) % 5 + 1,

        (ABS(CHECKSUM(NEWID())) % 500) / 10.0,

        CASE WHEN @erCounter = 100 THEN 1 ELSE 0 END,

        DATEADD(DAY, -@erCounter, GETDATE()),

        1001
    );

    SET @erCounter += 1;

END;