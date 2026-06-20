USE GathelDB;
GO

CREATE OR ALTER PROCEDURE spCreatePeopleType
(
    @Name VARCHAR(30),
    @Description VARCHAR(100) = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Name)), '') IS NULL
        THROW 50001, 'People type name is required.', 1;

    -- Evitar tipos duplicados
    IF EXISTS
    (
        SELECT 1
        FROM peopleTypes
        WHERE name = @Name
          AND isDeleted = 0
    )
        THROW 50002, 'People type already exists.', 1;

    INSERT INTO peopleTypes
    (
        name,
        description
    )
    VALUES
    (
        @Name,
        @Description
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateCountry
(
    @Name VARCHAR(80),
    @IsoCode VARCHAR(5)
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Name)), '') IS NULL
        THROW 50003, 'Country name is required.', 1;

    IF NULLIF(LTRIM(RTRIM(@IsoCode)), '') IS NULL
        THROW 50004, 'Country ISO code is required.', 1;

    -- Aunque el DDL no tiene UNIQUE, el ISO debe ser único por negocio
    IF EXISTS
    (
        SELECT 1
        FROM countries
        WHERE isoCode = @IsoCode
          AND isDeleted = 0
    )
        THROW 50005, 'Country ISO code already exists.', 1;

    INSERT INTO countries
    (
        name,
        isoCode
    )
    VALUES
    (
        @Name,
        @IsoCode
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateReportType
(
    @Name VARCHAR(40),
    @Description VARCHAR(120) = NULL,
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Name)), '') IS NULL
        THROW 50006, 'Report type name is required.', 1;

    -- La tabla tiene UNIQUE sobre name
    IF EXISTS
    (
        SELECT 1
        FROM reportTypes
        WHERE name = @Name
          AND isDeleted = 0
    )
        THROW 50007, 'Report type already exists.', 1;

    -- Validar auditor únicamente cuando se envía
    IF @AuditPersonId IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @AuditPersonId
          AND isDeleted = 0
    )
        THROW 50008, 'Audit person does not exist.', 1;

    INSERT INTO reportTypes
    (
        name,
        description,
        auditPersonId
    )
    VALUES
    (
        @Name,
        @Description,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateCurrency
(
    @Name VARCHAR(30),
    @Code VARCHAR(10),
    @Symbol VARCHAR(10) = NULL,
    @AuditPersonId INT = NULL,
    @IsDefaultCurrencie BIT = 0
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Name)), '') IS NULL
        THROW 50009, 'Currency name is required.', 1;

    IF NULLIF(LTRIM(RTRIM(@Code)), '') IS NULL
        THROW 50010, 'Currency code is required.', 1;

    -- La tabla tiene UNIQUE sobre code
    IF EXISTS
    (
        SELECT 1
        FROM currencies
        WHERE code = @Code
          AND isDeleted = 0
    )
        THROW 50011, 'Currency code already exists.', 1;

    IF @AuditPersonId IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @AuditPersonId
          AND isDeleted = 0
    )
        THROW 50012, 'Audit person does not exist.', 1;

    -- Solo puede existir una moneda por defecto
    IF @IsDefaultCurrencie = 1
    AND EXISTS
    (
        SELECT 1
        FROM currencies
        WHERE isDefaultCurrencie = 1
          AND isDeleted = 0
    )
        THROW 50013, 'A default currency already exists.', 1;

    INSERT INTO currencies
    (
        name,
        code,
        symbol,
        auditPersonId,
        isDefaultCurrencie
    )
    VALUES
    (
        @Name,
        @Code,
        @Symbol,
        @AuditPersonId,
        @IsDefaultCurrencie
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateReferenceType
(
    @Name VARCHAR(30),
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Name)), '') IS NULL
        THROW 50014, 'Reference type name is required.', 1;

    -- Evitar tipos de referencia duplicados
    IF EXISTS
    (
        SELECT 1
        FROM referenceTypes
        WHERE name = @Name
          AND isDeleted = 0
    )
        THROW 50015, 'Reference type already exists.', 1;

    IF @AuditPersonId IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @AuditPersonId
          AND isDeleted = 0
    )
        THROW 50016, 'Audit person does not exist.', 1;

    INSERT INTO referenceTypes
    (
        name,
        auditPersonId
    )
    VALUES
    (
        @Name,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreatePaymentMethod
(
    @Name VARCHAR(30),
    @Logo INT = NULL,
    @Config NVARCHAR(MAX) = NULL,
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Name)), '') IS NULL
        THROW 50017, 'Payment method name is required.', 1;

    -- Evitar métodos duplicados
    IF EXISTS
    (
        SELECT 1
        FROM paymentMethods
        WHERE name = @Name
          AND isDeleted = 0
    )
        THROW 50018, 'Payment method already exists.', 1;

    -- Logo apunta a files.fileId
    IF @Logo IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM files
        WHERE fileId = @Logo
          AND isDeleted = 0
    )
        THROW 50019, 'Logo file does not exist.', 1;

    IF @AuditPersonId IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @AuditPersonId
          AND isDeleted = 0
    )
        THROW 50020, 'Audit person does not exist.', 1;

    INSERT INTO paymentMethods
    (
        name,
        logo,
        config,
        auditPersonId
    )
    VALUES
    (
        @Name,
        @Logo,
        @Config,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateCommissionType
(
    @Name VARCHAR(40),
    @Description VARCHAR(120) = NULL,
    @Percentage NUMERIC(5,2),
    @IsActive BIT = 1,
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Name)), '') IS NULL
        THROW 50021, 'Commission type name is required.', 1;

    -- Evitar tipos de comisión duplicados
    IF EXISTS
    (
        SELECT 1
        FROM commissionTypes
        WHERE name = @Name
          AND isDeleted = 0
    )
        THROW 50022, 'Commission type already exists.', 1;

    -- Un porcentaje válido debe estar entre 0 y 100
    IF @Percentage < 0 OR @Percentage > 100
        THROW 50023, 'Percentage must be between 0 and 100.', 1;

    IF @AuditPersonId IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @AuditPersonId
          AND isDeleted = 0
    )
        THROW 50024, 'Audit person does not exist.', 1;

    INSERT INTO commissionTypes
    (
        name,
        description,
        percentage,
        isActive,
        auditPersonId
    )
    VALUES
    (
        @Name,
        @Description,
        @Percentage,
        @IsActive,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateStatusType
(
    @Name VARCHAR(40),
    @Description VARCHAR(120) = NULL,
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Name)), '') IS NULL
        THROW 50025, 'Status type name is required.', 1;

    -- Los estados deberían ser únicos por negocio
    IF EXISTS
    (
        SELECT 1
        FROM statusTypes
        WHERE name = @Name
          AND isDeleted = 0
    )
        THROW 50026, 'Status type already exists.', 1;

    IF @AuditPersonId IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @AuditPersonId
          AND isDeleted = 0
    )
        THROW 50027, 'Audit person does not exist.', 1;

    INSERT INTO statusTypes
    (
        name,
        description,
        auditPersonId
    )
    VALUES
    (
        @Name,
        @Description,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreatePenaltyType
(
    @Name VARCHAR(40),
    @Description VARCHAR(120) = NULL,
    @PointsPercentage NUMERIC(5,2),
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Name)), '') IS NULL
        THROW 50028, 'Penalty type name is required.', 1;

    -- La tabla tiene UNIQUE sobre name
    IF EXISTS
    (
        SELECT 1
        FROM penaltyTypes
        WHERE name = @Name
          AND isDeleted = 0
    )
        THROW 50029, 'Penalty type already exists.', 1;

    -- El porcentaje de penalización debe ser válido
    IF @PointsPercentage < 0 OR @PointsPercentage > 100
        THROW 50030, 'Points percentage must be between 0 and 100.', 1;

    IF @AuditPersonId IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @AuditPersonId
          AND isDeleted = 0
    )
        THROW 50031, 'Audit person does not exist.', 1;

    INSERT INTO penaltyTypes
    (
        name,
        description,
        pointsPercentage,
        auditPersonId
    )
    VALUES
    (
        @Name,
        @Description,
        @PointsPercentage,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateSocialPlatform
(
    @Name VARCHAR(40),
    @ApiUrl VARCHAR(255) = NULL,
    @Logo INT = NULL,
    @Config NVARCHAR(MAX) = NULL,
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Name)), '') IS NULL
        THROW 50032, 'Social platform name is required.', 1;

    -- Evitar plataformas duplicadas
    IF EXISTS
    (
        SELECT 1
        FROM socialPlatforms
        WHERE name = @Name
          AND isDeleted = 0
    )
        THROW 50033, 'Social platform already exists.', 1;

    -- Logo apunta a files.fileId
    IF @Logo IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM files
        WHERE fileId = @Logo
          AND isDeleted = 0
    )
        THROW 50034, 'Logo file does not exist.', 1;

    IF @AuditPersonId IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @AuditPersonId
          AND isDeleted = 0
    )
        THROW 50035, 'Audit person does not exist.', 1;

    INSERT INTO socialPlatforms
    (
        name,
        apiUrl,
        logo,
        config,
        auditPersonId
    )
    VALUES
    (
        @Name,
        @ApiUrl,
        @Logo,
        @Config,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateFileType
(
    @Name VARCHAR(20),
    @MimeType VARCHAR(100),
    @Description VARCHAR(120) = NULL,
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Name)), '') IS NULL
        THROW 50036, 'File type name is required.', 1;

    IF NULLIF(LTRIM(RTRIM(@MimeType)), '') IS NULL
        THROW 50037, 'Mime type is required.', 1;

    -- Evitar tipos de archivo duplicados
    IF EXISTS
    (
        SELECT 1
        FROM fileTypes
        WHERE name = @Name
          AND isDeleted = 0
    )
        THROW 50038, 'File type already exists.', 1;

    IF @AuditPersonId IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @AuditPersonId
          AND isDeleted = 0
    )
        THROW 50039, 'Audit person does not exist.', 1;

    INSERT INTO fileTypes
    (
        name,
        mimeType,
        description,
        auditPersonId
    )
    VALUES
    (
        @Name,
        @MimeType,
        @Description,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateFileUsageType
(
    @Name VARCHAR(40),
    @Description VARCHAR(120) = NULL,
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Name)), '') IS NULL
        THROW 50040, 'File usage type name is required.', 1;

    -- Evitar tipos de uso duplicados
    IF EXISTS
    (
        SELECT 1
        FROM fileUsageTypes
        WHERE name = @Name
          AND isDeleted = 0
    )
        THROW 50041, 'File usage type already exists.', 1;

    IF @AuditPersonId IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @AuditPersonId
          AND isDeleted = 0
    )
        THROW 50042, 'Audit person does not exist.', 1;

    INSERT INTO fileUsageTypes
    (
        name,
        description,
        auditPersonId
    )
    VALUES
    (
        @Name,
        @Description,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateNotificationType
(
    @Name VARCHAR(40),
    @Description VARCHAR(120) = NULL,
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Name)), '') IS NULL
        THROW 50043, 'Notification type name is required.', 1;

    -- La tabla tiene UNIQUE sobre name
    IF EXISTS
    (
        SELECT 1
        FROM notificationTypes
        WHERE name = @Name
          AND isDeleted = 0
    )
        THROW 50044, 'Notification type already exists.', 1;

    IF @AuditPersonId IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @AuditPersonId
          AND isDeleted = 0
    )
        THROW 50045, 'Audit person does not exist.', 1;

    INSERT INTO notificationTypes
    (
        name,
        description,
        auditPersonId
    )
    VALUES
    (
        @Name,
        @Description,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateSecurityEventType
(
    @Name VARCHAR(50),
    @Description VARCHAR(200) = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Name)), '') IS NULL
        THROW 50046, 'Security event type name is required.', 1;

    -- La tabla tiene UNIQUE sobre name
    IF EXISTS
    (
        SELECT 1
        FROM securityEventTypes
        WHERE name = @Name
          AND isDeleted = 0
    )
        THROW 50047, 'Security event type already exists.', 1;

    INSERT INTO securityEventTypes
    (
        name,
        description
    )
    VALUES
    (
        @Name,
        @Description
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreatePermissionType
(
    @Name VARCHAR(20),
    @Description VARCHAR(100) = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Name)), '') IS NULL
        THROW 50048, 'Permission type name is required.', 1;

    -- Evitar tipos de permiso duplicados
    IF EXISTS
    (
        SELECT 1
        FROM permissionTypes
        WHERE name = @Name
          AND isDeleted = 0
    )
        THROW 50049, 'Permission type already exists.', 1;

    INSERT INTO permissionTypes
    (
        name,
        description
    )
    VALUES
    (
        @Name,
        @Description
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateTransactionType
(
    @Name VARCHAR(40),
    @Description VARCHAR(120) = NULL,
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Name)), '') IS NULL
        THROW 50050, 'Transaction type name is required.', 1;

    -- Evitar tipos de transacción duplicados
    IF EXISTS
    (
        SELECT 1
        FROM transactionTypes
        WHERE name = @Name
          AND isDeleted = 0
    )
        THROW 50051, 'Transaction type already exists.', 1;

    IF @AuditPersonId IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @AuditPersonId
          AND isDeleted = 0
    )
        THROW 50052, 'Audit person does not exist.', 1;

    INSERT INTO transactionTypes
    (
        name,
        description,
        auditPersonId
    )
    VALUES
    (
        @Name,
        @Description,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateState
(
    @CountryId INT,
    @Name VARCHAR(80)
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Name)), '') IS NULL
        THROW 50053, 'State name is required.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM countries
        WHERE countryId = @CountryId
          AND isDeleted = 0
    )
        THROW 50054, 'Country does not exist.', 1;

    -- Evitar estados duplicados dentro del mismo país
    IF EXISTS
    (
        SELECT 1
        FROM states
        WHERE countryId = @CountryId
          AND name = @Name
          AND isDeleted = 0
    )
        THROW 50055, 'State already exists for this country.', 1;

    INSERT INTO states
    (
        countryId,
        name
    )
    VALUES
    (
        @CountryId,
        @Name
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateCity
(
    @StateId INT,
    @Name VARCHAR(80)
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Name)), '') IS NULL
        THROW 50056, 'City name is required.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM states
        WHERE stateId = @StateId
          AND isDeleted = 0
    )
        THROW 50057, 'State does not exist.', 1;

    -- Evitar ciudades duplicadas dentro del mismo estado
    IF EXISTS
    (
        SELECT 1
        FROM cities
        WHERE stateId = @StateId
          AND name = @Name
          AND isDeleted = 0
    )
        THROW 50058, 'City already exists for this state.', 1;

    INSERT INTO cities
    (
        stateId,
        name
    )
    VALUES
    (
        @StateId,
        @Name
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateAddress
(
    @CityId INT,
    @ExactAddress VARCHAR(200)
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@ExactAddress)), '') IS NULL
        THROW 50059, 'Address is required.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM cities
        WHERE cityId = @CityId
          AND isDeleted = 0
    )
        THROW 50060, 'City does not exist.', 1;

    INSERT INTO addresses
    (
        cityId,
        exactAddress
    )
    VALUES
    (
        @CityId,
        @ExactAddress
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreatePermission
(
    @PermissionTypeId INT,
    @ReferenceTypeId INT
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM permissionTypes
        WHERE permissionTypeId = @PermissionTypeId
          AND isDeleted = 0
    )
        THROW 50061, 'Permission type does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM referenceTypes
        WHERE referenceTypeId = @ReferenceTypeId
          AND isDeleted = 0
    )
        THROW 50062, 'Reference type does not exist.', 1;

    -- La tabla tiene UNIQUE(permissionTypeId, referenceTypeId)
    IF EXISTS
    (
        SELECT 1
        FROM permissions
        WHERE permissionTypeId = @PermissionTypeId
          AND referenceTypeId = @ReferenceTypeId
          AND isDeleted = 0
    )
        THROW 50063, 'Permission already exists.', 1;

    INSERT INTO permissions
    (
        permissionTypeId,
        referenceTypeId
    )
    VALUES
    (
        @PermissionTypeId,
        @ReferenceTypeId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateRolePermission
(
    @PeopleTypeId INT,
    @PermissionId INT
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM peopleTypes
        WHERE peopleTypeId = @PeopleTypeId
          AND isDeleted = 0
    )
        THROW 50064, 'People type does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM permissions
        WHERE permissionId = @PermissionId
          AND isDeleted = 0
    )
        THROW 50065, 'Permission does not exist.', 1;

    -- La tabla tiene UNIQUE(peopleTypeId, permissionId)
    IF EXISTS
    (
        SELECT 1
        FROM rolePermissions
        WHERE peopleTypeId = @PeopleTypeId
          AND permissionId = @PermissionId
          AND isDeleted = 0
    )
        THROW 50066, 'Role permission already exists.', 1;

    INSERT INTO rolePermissions
    (
        peopleTypeId,
        permissionId
    )
    VALUES
    (
        @PeopleTypeId,
        @PermissionId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreatePeoplePermission
(
    @PersonId INT,
    @PermissionId INT
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @PersonId
          AND isDeleted = 0
    )
        THROW 50067, 'Person does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM permissions
        WHERE permissionId = @PermissionId
          AND isDeleted = 0
    )
        THROW 50068, 'Permission does not exist.', 1;

    -- La tabla tiene UNIQUE(personId, permissionId)
    IF EXISTS
    (
        SELECT 1
        FROM peoplePermissions
        WHERE personId = @PersonId
          AND permissionId = @PermissionId
          AND isDeleted = 0
    )
        THROW 50069, 'Person permission already exists.', 1;

    INSERT INTO peoplePermissions
    (
        personId,
        permissionId
    )
    VALUES
    (
        @PersonId,
        @PermissionId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateSocialAccount
(
    @PersonId INT,
    @SocialPlatformId INT,
    @Username VARCHAR(80),
    @ProfileUrl VARCHAR(255) = NULL,
    @AccessToken VARBINARY(MAX) = NULL,
    @RefreshToken VARBINARY(MAX) = NULL,
    @IsVerified BIT = 0,
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Username)), '') IS NULL
        THROW 50070, 'Username is required.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @PersonId
          AND isDeleted = 0
    )
        THROW 50071, 'Person does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM socialPlatforms
        WHERE socialPlatformId = @SocialPlatformId
          AND isDeleted = 0
    )
        THROW 50072, 'Social platform does not exist.', 1;

    -- La tabla tiene UNIQUE(socialPlatformId, username)
    IF EXISTS
    (
        SELECT 1
        FROM socialAccounts
        WHERE socialPlatformId = @SocialPlatformId
          AND username = @Username
          AND isDeleted = 0
    )
        THROW 50073, 'Username already exists for this platform.', 1;

    IF @AuditPersonId IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @AuditPersonId
          AND isDeleted = 0
    )
        THROW 50074, 'Audit person does not exist.', 1;

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
        @PersonId,
        @SocialPlatformId,
        @Username,
        @ProfileUrl,
        @AccessToken,
        @RefreshToken,
        @IsVerified,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateWallet
(
    @PersonId INT,
    @IsBlocked BIT = 0,
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @PersonId
          AND isDeleted = 0
    )
        THROW 50075, 'Person does not exist.', 1;

    -- Por negocio un usuario debería tener una sola wallet activa
    IF EXISTS
    (
        SELECT 1
        FROM wallets
        WHERE personId = @PersonId
          AND isDeleted = 0
    )
        THROW 50076, 'Person already has a wallet.', 1;

    IF @AuditPersonId IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @AuditPersonId
          AND isDeleted = 0
    )
        THROW 50077, 'Audit person does not exist.', 1;

    INSERT INTO wallets
    (
        personId,
        isBlocked,
        auditPersonId
    )
    VALUES
    (
        @PersonId,
        @IsBlocked,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateAuthSession
(
    @PersonId INT,
    @RefreshToken VARBINARY(MAX),
    @IpAddress VARCHAR(100),
    @ExpiresAt DATETIME2(3),
    @LastActivityAt DATETIME2(3) = NULL,
    @IsRevoked BIT = 0,
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @PersonId
          AND isDeleted = 0
    )
        THROW 50078, 'Person does not exist.', 1;

    IF NULLIF(LTRIM(RTRIM(@IpAddress)), '') IS NULL
        THROW 50079, 'IP address is required.', 1;

    IF @AuditPersonId IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @AuditPersonId
          AND isDeleted = 0
    )
        THROW 50080, 'Audit person does not exist.', 1;

    INSERT INTO authSessions
    (
        personId,
        refreshToken,
        ipAddress,
        expiresAt,
        lastActivityAt,
        isRevoked,
        auditPersonId
    )
    VALUES
    (
        @PersonId,
        @RefreshToken,
        @IpAddress,
        @ExpiresAt,
        ISNULL(@LastActivityAt, GETDATE()),
        @IsRevoked,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateFile
(
    @FileTypeId INT,
    @FileName VARCHAR(255),
    @FileUrl VARCHAR(255),
    @FileSize BIGINT,
    @UploadedByPersonId INT,
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@FileName)), '') IS NULL
        THROW 50081, 'File name is required.', 1;

    IF NULLIF(LTRIM(RTRIM(@FileUrl)), '') IS NULL
        THROW 50082, 'File URL is required.', 1;

    IF @FileSize < 0
        THROW 50083, 'File size cannot be negative.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM fileTypes
        WHERE fileTypeId = @FileTypeId
          AND isDeleted = 0
    )
        THROW 50084, 'File type does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @UploadedByPersonId
          AND isDeleted = 0
    )
        THROW 50085, 'Uploader does not exist.', 1;

    IF @AuditPersonId IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @AuditPersonId
          AND isDeleted = 0
    )
        THROW 50086, 'Audit person does not exist.', 1;

    INSERT INTO files
    (
        fileTypeId,
        fileName,
        fileUrl,
        fileSize,
        uploadedByPersonId,
        auditPersonId
    )
    VALUES
    (
        @FileTypeId,
        @FileName,
        @FileUrl,
        @FileSize,
        @UploadedByPersonId,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateFileReference
(
    @FileId INT,
    @ReferenceTypeId INT,
    @ReferenceId INT,
    @FileUsageTypeId INT,
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM files
        WHERE fileId = @FileId
          AND isDeleted = 0
    )
        THROW 50087, 'File does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM referenceTypes
        WHERE referenceTypeId = @ReferenceTypeId
          AND isDeleted = 0
    )
        THROW 50088, 'Reference type does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM fileUsageTypes
        WHERE fileUsageTypeId = @FileUsageTypeId
          AND isDeleted = 0
    )
        THROW 50089, 'File usage type does not exist.', 1;

    IF @AuditPersonId IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @AuditPersonId
          AND isDeleted = 0
    )
        THROW 50090, 'Audit person does not exist.', 1;

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
        @FileId,
        @ReferenceTypeId,
        @ReferenceId,
        @FileUsageTypeId,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreatePropositionLike
(
    @PropositionId INT,
    @PersonId INT,
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM propositions
        WHERE propositionId = @PropositionId
          AND isDeleted = 0
    )
        THROW 50094, 'Proposition does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @PersonId
          AND isDeleted = 0
    )
        THROW 50095, 'Person does not exist.', 1;

    -- La tabla tiene UNIQUE(propositionId, personId)
    IF EXISTS
    (
        SELECT 1
        FROM propositionLikes
        WHERE propositionId = @PropositionId
          AND personId = @PersonId
          AND isDeleted = 0
    )
        THROW 50096, 'Like already exists.', 1;

    INSERT INTO propositionLikes
    (
        propositionId,
        personId,
        auditPersonId
    )
    VALUES
    (
        @PropositionId,
        @PersonId,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreatePropositionComment
(
    @PropositionId INT,
    @PersonId INT,
    @Comment VARCHAR(255),
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Comment)), '') IS NULL
        THROW 50097, 'Comment is required.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM propositions
        WHERE propositionId = @PropositionId
          AND isDeleted = 0
    )
        THROW 50098, 'Proposition does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @PersonId
          AND isDeleted = 0
    )
        THROW 50099, 'Person does not exist.', 1;

    INSERT INTO propositionComments
    (
        propositionId,
        personId,
        comment,
        auditPersonId
    )
    VALUES
    (
        @PropositionId,
        @PersonId,
        @Comment,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateReport
(
    @ReportTypeId INT,
    @ReportedPersonId INT,
    @ReporterPersonId INT,
    @PropositionId INT = NULL,
    @Description VARCHAR(255),
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Description)), '') IS NULL
        THROW 50100, 'Description is required.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM reportTypes
        WHERE reportTypeId = @ReportTypeId
          AND isDeleted = 0
    )
        THROW 50101, 'Report type does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @ReportedPersonId
          AND isDeleted = 0
    )
        THROW 50102, 'Reported person does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @ReporterPersonId
          AND isDeleted = 0
    )
        THROW 50103, 'Reporter person does not exist.', 1;

    IF @PropositionId IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM propositions
        WHERE propositionId = @PropositionId
          AND isDeleted = 0
    )
        THROW 50104, 'Proposition does not exist.', 1;

    INSERT INTO reports
    (
        reportTypeId,
        reportedPersonId,
        reporterPersonId,
        propositionId,
        description,
        auditPersonId
    )
    VALUES
    (
        @ReportTypeId,
        @ReportedPersonId,
        @ReporterPersonId,
        @PropositionId,
        @Description,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreatePenalty
(
    @PenaltyTypeId INT,
    @ReportId INT,
    @PointsAmount NUMERIC(16,2),
    @ReasonDescription VARCHAR(255),
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF @PointsAmount < 0
        THROW 50105, 'Points amount cannot be negative.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM penaltyTypes
        WHERE penaltyTypeId = @PenaltyTypeId
          AND isDeleted = 0
    )
        THROW 50106, 'Penalty type does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM reports
        WHERE reportId = @ReportId
          AND isDeleted = 0
    )
        THROW 50107, 'Report does not exist.', 1;

    INSERT INTO penalties
    (
        penaltyTypeId,
        reportId,
        pointsAmount,
        reasonDescription,
        auditPersonId
    )
    VALUES
    (
        @PenaltyTypeId,
        @ReportId,
        @PointsAmount,
        @ReasonDescription,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateExchangeRate
(
    @CurrencyId INT,
    @Rate NUMERIC(12,6),
    @IsCurrent BIT = 0,
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF @Rate <= 0
        THROW 50108, 'Exchange rate must be greater than zero.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM currencies
        WHERE currencyId = @CurrencyId
          AND isDeleted = 0
    )
        THROW 50109, 'Currency does not exist.', 1;

    -- Solo una tasa actual por moneda
    IF @IsCurrent = 1
    BEGIN

        UPDATE exchangeRates
        SET isCurrent = 0
        WHERE currencyId = @CurrencyId
          AND isCurrent = 1;

    END;

    INSERT INTO exchangeRates
    (
        currencyId,
        rate,
        isCurrent,
        auditPersonId
    )
    VALUES
    (
        @CurrencyId,
        @Rate,
        @IsCurrent,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateWalletBalance
(
    @WalletId INT,
    @StatusTypeId INT,
    @OldPointsAmount NUMERIC(16,2),
    @BalancePointsAmount NUMERIC(16,2),
    @NewPointsAmount NUMERIC(16,2),
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM wallets
        WHERE walletId = @WalletId
          AND isDeleted = 0
    )
        THROW 50110, 'Wallet does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM statusTypes
        WHERE statusTypeId = @StatusTypeId
          AND isDeleted = 0
    )
        THROW 50111, 'Status type does not exist.', 1;

    INSERT INTO walletBalances
    (
        walletId,
        statusTypeId,
        oldPointsAmount,
        balancePointsAmount,
        newPointsAmount,
        auditPersonId
    )
    VALUES
    (
        @WalletId,
        @StatusTypeId,
        @OldPointsAmount,
        @BalancePointsAmount,
        @NewPointsAmount,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateWalletTransaction
(
    @OriginWalletId INT,
    @DestinationWalletId INT,
    @IsSelfTransaction BIT = 0,
    @PointsAmount NUMERIC(16,2),
    @ReferenceTypeId INT,
    @ReferenceId INT,
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF @PointsAmount <= 0
        THROW 50112, 'Points amount must be greater than zero.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM wallets
        WHERE walletId = @OriginWalletId
          AND isDeleted = 0
    )
        THROW 50113, 'Origin wallet does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM wallets
        WHERE walletId = @DestinationWalletId
          AND isDeleted = 0
    )
        THROW 50114, 'Destination wallet does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM referenceTypes
        WHERE referenceTypeId = @ReferenceTypeId
          AND isDeleted = 0
    )
        THROW 50115, 'Reference type does not exist.', 1;

    INSERT INTO walletTransactions
    (
        originWalletId,
        destinationWalletId,
        isSelfTransaction,
        pointsAmount,
        referenceTypeId,
        referenceId,
        auditPersonId
    )
    VALUES
    (
        @OriginWalletId,
        @DestinationWalletId,
        @IsSelfTransaction,
        @PointsAmount,
        @ReferenceTypeId,
        @ReferenceId,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateNotification
(
    @NotificationTypeId INT,
    @PersonId INT,
    @Title VARCHAR(120),
    @Message VARCHAR(255),
    @IsRead BIT = 0,
    @ReadAt DATETIME2(3) = NULL,
    @ReferenceTypeId INT = NULL,
    @ReferenceId INT = NULL,
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@Title)), '') IS NULL
        THROW 50116, 'Title is required.', 1;

    IF NULLIF(LTRIM(RTRIM(@Message)), '') IS NULL
        THROW 50117, 'Message is required.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM notificationTypes
        WHERE notificationTypeId = @NotificationTypeId
          AND isDeleted = 0
    )
        THROW 50118, 'Notification type does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @PersonId
          AND isDeleted = 0
    )
        THROW 50119, 'Person does not exist.', 1;

    IF @ReferenceTypeId IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM referenceTypes
        WHERE referenceTypeId = @ReferenceTypeId
          AND isDeleted = 0
    )
        THROW 50120, 'Reference type does not exist.', 1;

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
        @NotificationTypeId,
        @PersonId,
        @Title,
        @Message,
        @IsRead,
        @ReadAt,
        @ReferenceTypeId,
        @ReferenceId,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateSecurityEvent
(
    @SecurityEventTypeId INT,
    @PersonId INT,
    @AuthSessionId INT,
    @Details VARCHAR(500) = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM securityEventTypes
        WHERE securityEventTypeId = @SecurityEventTypeId
          AND isDeleted = 0
    )
        THROW 50121, 'Security event type does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @PersonId
          AND isDeleted = 0
    )
        THROW 50122, 'Person does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM authSessions
        WHERE authSessionId = @AuthSessionId
          AND isDeleted = 0
    )
        THROW 50123, 'Auth session does not exist.', 1;

    INSERT INTO securityEvents
    (
        securityEventTypeId,
        personId,
        authSessionId,
        details
    )
    VALUES
    (
        @SecurityEventTypeId,
        @PersonId,
        @AuthSessionId,
        @Details
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateTransactionAttempt
(
    @TransactionTypeId INT,
    @PersonId INT,
    @PaymentMethodId INT,
    @IsTransactionLoaded BIT = 0,
    @Amount NUMERIC(16,2),
    @CurrencyId INT,
    @ExchangeRateId INT,
    @ExchangedAmount NUMERIC(16,2),
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF @Amount <= 0
        THROW 50124, 'Amount must be greater than zero.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM transactionTypes
        WHERE transactionTypeId = @TransactionTypeId
          AND isDeleted = 0
    )
        THROW 50125, 'Transaction type does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @PersonId
          AND isDeleted = 0
    )
        THROW 50126, 'Person does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM paymentMethods
        WHERE paymentMethodId = @PaymentMethodId
          AND isDeleted = 0
    )
        THROW 50127, 'Payment method does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM currencies
        WHERE currencyId = @CurrencyId
          AND isDeleted = 0
    )
        THROW 50128, 'Currency does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM exchangeRates
        WHERE exchangeRateId = @ExchangeRateId
          AND isDeleted = 0
    )
        THROW 50129, 'Exchange rate does not exist.', 1;

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
        auditPersonId
    )
    VALUES
    (
        @TransactionTypeId,
        @PersonId,
        @PaymentMethodId,
        @IsTransactionLoaded,
        @Amount,
        @CurrencyId,
        @ExchangeRateId,
        @ExchangedAmount,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateTransaction
(
    @TransactionAttemptId INT,
    @PersonId INT,
    @TransactionTypeId INT,
    @PaymentMethodId INT,
    @Amount NUMERIC(16,2),
    @CurrencyId INT,
    @ExchangeRateId INT,
    @ExchangedAmount NUMERIC(16,2),
    @ReferenceTypeId INT,
    @ReferenceId INT,
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF @Amount <= 0
        THROW 50130, 'Amount must be greater than zero.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM transactionAttempts
        WHERE transactionAttemptId = @TransactionAttemptId
          AND isDeleted = 0
    )
        THROW 50131, 'Transaction attempt does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @PersonId
          AND isDeleted = 0
    )
        THROW 50132, 'Person does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM transactionTypes
        WHERE transactionTypeId = @TransactionTypeId
          AND isDeleted = 0
    )
        THROW 50133, 'Transaction type does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM paymentMethods
        WHERE paymentMethodId = @PaymentMethodId
          AND isDeleted = 0
    )
        THROW 50134, 'Payment method does not exist.', 1;

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
        referenceTypeId,
        referenceId,
        auditPersonId
    )
    VALUES
    (
        @TransactionAttemptId,
        @PersonId,
        @TransactionTypeId,
        @PaymentMethodId,
        @Amount,
        @CurrencyId,
        @ExchangeRateId,
        @ExchangedAmount,
        @ReferenceTypeId,
        @ReferenceId,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateFinancialMovement
(
    @TransactionTypeId INT,
    @Amount NUMERIC(14,2),
    @CurrencyId INT,
    @ExchangeRateId INT,
    @ExchangedAmount NUMERIC(14,2),
    @ReferenceTypeId INT,
    @ReferenceId INT,
    @Description VARCHAR(120) = NULL,
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF @Amount <= 0
        THROW 50135, 'Amount must be greater than zero.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM transactionTypes
        WHERE transactionTypeId = @TransactionTypeId
          AND isDeleted = 0
    )
        THROW 50136, 'Transaction type does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM currencies
        WHERE currencyId = @CurrencyId
          AND isDeleted = 0
    )
        THROW 50137, 'Currency does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM exchangeRates
        WHERE exchangeRateId = @ExchangeRateId
          AND isDeleted = 0
    )
        THROW 50138, 'Exchange rate does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM referenceTypes
        WHERE referenceTypeId = @ReferenceTypeId
          AND isDeleted = 0
    )
        THROW 50139, 'Reference type does not exist.', 1;

    INSERT INTO financialMovements
    (
        transactionTypeId,
        amount,
        currencyId,
        exchangeRateId,
        exchangedAmount,
        referenceTypeId,
        referenceId,
        description,
        auditPersonId
    )
    VALUES
    (
        @TransactionTypeId,
        @Amount,
        @CurrencyId,
        @ExchangeRateId,
        @ExchangedAmount,
        @ReferenceTypeId,
        @ReferenceId,
        @Description,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateFinancialBalanceHistory
(
    @TotalBalance NUMERIC(16,2),
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    INSERT INTO financialBalancesHistory
    (
        totalBalance,
        auditPersonId
    )
    VALUES
    (
        @TotalBalance,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateCommission
(
    @CommissionTypeId INT,
    @ReferenceTypeId INT,
    @ReferenceId INT,
    @SourceWalletTransactionId INT,
    @FinancialMovementId INT,
    @AppliedAmount NUMERIC(16,2),
    @Percentage NUMERIC(5,2),
    @CommissionAmount NUMERIC(16,2),
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF @AppliedAmount < 0
        THROW 50140, 'Applied amount cannot be negative.', 1;

    IF @Percentage < 0 OR @Percentage > 100
        THROW 50141, 'Percentage must be between 0 and 100.', 1;

    IF @CommissionAmount < 0
        THROW 50142, 'Commission amount cannot be negative.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM commissionTypes
        WHERE commissionTypeId = @CommissionTypeId
          AND isDeleted = 0
    )
        THROW 50143, 'Commission type does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM referenceTypes
        WHERE referenceTypeId = @ReferenceTypeId
          AND isDeleted = 0
    )
        THROW 50144, 'Reference type does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM walletTransactions
        WHERE walletTransactionId = @SourceWalletTransactionId
          AND isDeleted = 0
    )
        THROW 50145, 'Wallet transaction does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM financialMovements
        WHERE movementId = @FinancialMovementId
          AND isDeleted = 0
    )
        THROW 50146, 'Financial movement does not exist.', 1;

    INSERT INTO commissions
    (
        commissionTypeId,
        referenceTypeId,
        referenceId,
        sourceWalletTransactionId,
        financialMovementId,
        appliedAmount,
        percentage,
        commissionAmount,
        auditPersonId
    )
    VALUES
    (
        @CommissionTypeId,
        @ReferenceTypeId,
        @ReferenceId,
        @SourceWalletTransactionId,
        @FinancialMovementId,
        @AppliedAmount,
        @Percentage,
        @CommissionAmount,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreatePredictionPayout
(
    @PredictionId INT,
    @WalletTransactionId INT,
    @MoneyPayoutAmount NUMERIC(8,2),
    @PointsPayoutAmount NUMERIC(8,2),
    @CommissionAmount NUMERIC(8,2)
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM predictions
        WHERE predictionId = @PredictionId
          AND isDeleted = 0
    )
        THROW 50147, 'Prediction does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM walletTransactions
        WHERE walletTransactionId = @WalletTransactionId
          AND isDeleted = 0
    )
        THROW 50148, 'Wallet transaction does not exist.', 1;

    INSERT INTO predictionPayouts
    (
        predictionId,
        walletTransactionId,
        moneyPayoutAmount,
        pointsPayoutAmount,
        commissionAmount
    )
    VALUES
    (
        @PredictionId,
        @WalletTransactionId,
        @MoneyPayoutAmount,
        @PointsPayoutAmount,
        @CommissionAmount
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateWalletReservation
(
    @WalletId INT,
    @PredictionId INT,
    @ReservedPointsAmount NUMERIC(16,2),
    @ReservedMoneyAmount NUMERIC(16,2),
    @StatusTypeId INT,
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF @ReservedPointsAmount < 0
        THROW 50170, 'Reserved points amount cannot be negative.', 1;

    IF @ReservedMoneyAmount < 0
        THROW 50171, 'Reserved money amount cannot be negative.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM wallets
        WHERE walletId = @WalletId
          AND isDeleted = 0
    )
        THROW 50172, 'Wallet does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM predictions
        WHERE predictionId = @PredictionId
          AND isDeleted = 0
    )
        THROW 50173, 'Prediction does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM statusTypes
        WHERE statusTypeId = @StatusTypeId
          AND isDeleted = 0
    )
        THROW 50174, 'Status type does not exist.', 1;

    IF @AuditPersonId IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @AuditPersonId
          AND isDeleted = 0
    )
        THROW 50175, 'Audit person does not exist.', 1;

    INSERT INTO walletReservations
    (
        walletId,
        predictionId,
        reservedPointsAmount,
        reservedMoneyAmount,
        statusTypeId,
        auditPersonId
    )
    VALUES
    (
        @WalletId,
        @PredictionId,
        @ReservedPointsAmount,
        @ReservedMoneyAmount,
        @StatusTypeId,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateAIValidationResult
(
    @PropositionId INT,
    @StatusTypeId INT,
    @AIComments VARCHAR(500) = NULL,
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM propositions
        WHERE propositionId = @PropositionId
          AND isDeleted = 0
    )
        THROW 50152, 'Proposition does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM statusTypes
        WHERE statusTypeId = @StatusTypeId
          AND isDeleted = 0
    )
        THROW 50153, 'Status type does not exist.', 1;

    INSERT INTO aiValidationResults
    (
        propositionId,
        statusTypeId,
        aiComments,
        auditPersonId
    )
    VALUES
    (
        @PropositionId,
        @StatusTypeId,
        @AIComments,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateFollowRequest
(
    @SenderPersonId INT,
    @ReceiverPersonId INT,
    @StatusTypeId INT
)
AS
BEGIN

    SET NOCOUNT ON;

    IF @SenderPersonId = @ReceiverPersonId
        THROW 50154, 'A person cannot follow themselves.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @SenderPersonId
          AND isDeleted = 0
    )
        THROW 50155, 'Sender does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @ReceiverPersonId
          AND isDeleted = 0
    )
        THROW 50156, 'Receiver does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM statusTypes
        WHERE statusTypeId = @StatusTypeId
          AND isDeleted = 0
    )
        THROW 50157, 'Status type does not exist.', 1;

    -- UQ_followRequests
    IF EXISTS
    (
        SELECT 1
        FROM followRequests
        WHERE senderPersonId = @SenderPersonId
          AND receiverPersonId = @ReceiverPersonId
          AND isDeleted = 0
    )
        THROW 50158, 'Follow request already exists.', 1;

    INSERT INTO followRequests
    (
        senderPersonId,
        receiverPersonId,
        statusTypeId
    )
    VALUES
    (
        @SenderPersonId,
        @ReceiverPersonId,
        @StatusTypeId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateFollow
(
    @FollowerPersonId INT,
    @FollowedPersonId INT
)
AS
BEGIN

    SET NOCOUNT ON;

    IF @FollowerPersonId = @FollowedPersonId
        THROW 50159, 'A person cannot follow themselves.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @FollowerPersonId
          AND isDeleted = 0
    )
        THROW 50160, 'Follower does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @FollowedPersonId
          AND isDeleted = 0
    )
        THROW 50161, 'Followed person does not exist.', 1;

    -- UQ_follows
    IF EXISTS
    (
        SELECT 1
        FROM follows
        WHERE followerPersonId = @FollowerPersonId
          AND followedPersonId = @FollowedPersonId
          AND isDeleted = 0
    )
        THROW 50162, 'Follow relationship already exists.', 1;

    INSERT INTO follows
    (
        followerPersonId,
        followedPersonId
    )
    VALUES
    (
        @FollowerPersonId,
        @FollowedPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateStatusHistory
(
    @ReferenceTypeId INT,
    @ReferenceId INT,
    @StatusTypeId INT,
    @AuditPersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM referenceTypes
        WHERE referenceTypeId = @ReferenceTypeId
          AND isDeleted = 0
    )
        THROW 50154, 'Reference type does not exist.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM statusTypes
        WHERE statusTypeId = @StatusTypeId
          AND isDeleted = 0
    )
        THROW 50155, 'Status type does not exist.', 1;

    INSERT INTO statusHistory
    (
        referenceTypeId,
        referenceId,
        statusTypeId,
        auditPersonId
    )
    VALUES
    (
        @ReferenceTypeId,
        @ReferenceId,
        @StatusTypeId,
        @AuditPersonId
    );

END;
GO

CREATE OR ALTER PROCEDURE spCreateAuditLog
(
    @ReferenceTypeId INT,
    @ReferenceId INT,
    @ActionType VARCHAR(30),
    @OldValue VARCHAR(500) = NULL,
    @NewValue VARCHAR(500) = NULL,
    @PersonId INT = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@ActionType)), '') IS NULL
        THROW 50156, 'Action type is required.', 1;

    IF NOT EXISTS
    (
        SELECT 1
        FROM referenceTypes
        WHERE referenceTypeId = @ReferenceTypeId
          AND isDeleted = 0
    )
        THROW 50157, 'Reference type does not exist.', 1;

    IF @PersonId IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 1
        FROM people
        WHERE personId = @PersonId
          AND isDeleted = 0
    )
        THROW 50158, 'Person does not exist.', 1;

    INSERT INTO auditLogs
    (
        referenceTypeId,
        referenceId,
        actionType,
        oldValue,
        newValue,
        personId
    )
    VALUES
    (
        @ReferenceTypeId,
        @ReferenceId,
        @ActionType,
        @OldValue,
        @NewValue,
        @PersonId
    );

END;
GO