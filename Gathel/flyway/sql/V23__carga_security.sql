USE GathelDB;
GO

INSERT INTO people
(peopleTypeId,name,lastName,identification,phone,email,username,birthDate,isVerified,isActive)
VALUES
(
    1, -- Player, este es el rol, de aquí se heredan los permisos insertados arriba
    'usuarioPrueba1',
    'prueba',
    '123456781',
    '88888880',
    'usuarioPrueba1@gmail.com',
    'usuarioPrueba1Xx',
    '2000-01-01',
    1,
    1
),
(
    1, -- Player
    'usuarioPrueba2',
    'prueba2',
    '123456782',
    '88888889',
    'usuarioPrueba2@gmail.com',
    'usuarioPrueba2Xx',
    '2000-01-01',
    1,
    1
);
GO

CREATE OR ALTER FUNCTION dbo.fnHasPermission
(
    @PersonId INT,
    @PermissionName VARCHAR(20),
    @ReferenceName VARCHAR(30)
)
RETURNS BIT
AS
BEGIN

    DECLARE @HasPermission BIT = 0;

    -- Permisos directos
    IF EXISTS
    (
        SELECT 1
        FROM peoplePermissions pp
        INNER JOIN permissions p
            ON p.permissionId = pp.permissionId
        INNER JOIN permissionTypes pt
            ON pt.permissionTypeId = p.permissionTypeId
        INNER JOIN referenceTypes rt
            ON rt.referenceTypeId = p.referenceTypeId
        WHERE
            pp.personId = @PersonId
            AND pt.name = @PermissionName
            AND rt.name = @ReferenceName
    )
    BEGIN
        SET @HasPermission = 1;
    END

    -- Permisos heredados por rol
    ELSE IF EXISTS
    (
        SELECT 1
        FROM people pe
        INNER JOIN rolePermissions rp
            ON rp.peopleTypeId = pe.peopleTypeId
        INNER JOIN permissions p
            ON p.permissionId = rp.permissionId
        INNER JOIN permissionTypes pt
            ON pt.permissionTypeId = p.permissionTypeId
        INNER JOIN referenceTypes rt
            ON rt.referenceTypeId = p.referenceTypeId
        WHERE
            pe.personId = @PersonId
            AND pt.name = @PermissionName
            AND rt.name = @ReferenceName
    )
    BEGIN
        SET @HasPermission = 1; 
    END

    RETURN @HasPermission;

END;
GO

CREATE OR ALTER PROCEDURE spDeleteProposition
(
    @PersonId INT,
    @PropositionId INT
)
AS
BEGIN

    SET NOCOUNT ON;

    IF dbo.fnHasPermission
    (
        @PersonId,
        'Delete',
        'Proposition'
    ) = 0  --Si el function retornó 0 entonces no tiene permisos
    BEGIN
        THROW 50001,
            'User does not have permission to delete propositions.',
            1;
    END;
            --De lo contrario pasa a la lógica del SP, o sea, el usuario tiene permisos
    IF NOT EXISTS
    (
        SELECT 1
        FROM propositions
        WHERE propositionId = @PropositionId
        AND isDeleted = 0
    )
    BEGIN
        THROW 50002,
            'Proposition not found or already deleted.',
            1;
    END;

    UPDATE propositions
    SET
        isDeleted = 1,
        updatedAt = GETDATE(),
        auditPersonId = @PersonId
    WHERE propositionId = @PropositionId;

    PRINT 'Proposition deleted successfully.';

END;
GO

CREATE OR ALTER PROCEDURE spViewPropositions
(
    @PersonId INT,
    @PropositionId INT
)
AS
BEGIN

    SET NOCOUNT ON;

    IF dbo.fnHasPermission
    (
        @PersonId,
        'View',
        'Proposition'
    ) = 0
    BEGIN
        THROW 50003,
            'User does not have permission to view propositions.',
            1;
    END;

    SELECT * FROM propositions
    WHERE propositionId = @PropositionId
    AND isDeleted = 0;

END;
GO

CREATE MASTER KEY
ENCRYPTION BY PASSWORD = 'GathelMasterKey2026!';
GO

CREATE CERTIFICATE GathelPasswordCertificate
WITH SUBJECT = 'Password Encryption Certificate';
GO

CREATE SYMMETRIC KEY GathelPasswordKey            --Clave simétrica que se utilizará para cifrar las contraseñas
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE GathelPasswordCertificate;
GO

CREATE OR ALTER PROCEDURE spCreateUserEncrypted
(
    @PeopleTypeId INT,
    @Name VARCHAR(60),
    @LastName VARCHAR(60),
    @Identification VARCHAR(30),
    @Phone VARCHAR(20),
    @Email VARCHAR(100),
    @Username VARCHAR(40),
    @Password VARCHAR(200),
    @BirthDate DATE
)
AS
BEGIN

    SET NOCOUNT ON;

    OPEN SYMMETRIC KEY GathelPasswordKey
    DECRYPTION BY CERTIFICATE GathelPasswordCertificate;

    INSERT INTO people
    (
        peopleTypeId,
        name,
        lastName,
        identification,
        phone,
        email,
        username,
        passwordHash,
        birthDate,
        isVerified,
        isActive
    )
    VALUES
    (
        @PeopleTypeId,
        @Name,
        @LastName,
        @Identification,
        @Phone,
        @Email,
        @Username,
        EncryptByKey
        (
            Key_GUID('GathelPasswordKey'),  --Aquí hace uso de la clave simétrica
            @Password
        ),
        @BirthDate,
        0,
        1
    );

    CLOSE SYMMETRIC KEY GathelPasswordKey;

END;
GO

CREATE OR ALTER PROCEDURE spViewDecryptedPassword
(
    @Username VARCHAR(40)
)
AS
BEGIN

    SET NOCOUNT ON;

    OPEN SYMMETRIC KEY GathelPasswordKey
    DECRYPTION BY CERTIFICATE GathelPasswordCertificate;

    SELECT
        personId,
        username,
        CONVERT
        (
            VARCHAR(200),
            DecryptByKey(passwordHash)
        ) AS decryptedPassword
    FROM people
    WHERE username = @Username;

    CLOSE SYMMETRIC KEY GathelPasswordKey;

END;
GO

CREATE USER SecurityTester WITHOUT LOGIN;

DENY SELECT
ON dbo.people
TO SecurityTester;
GO

CREATE OR ALTER PROCEDURE spViewPeopleBasicInfo
AS
BEGIN

    SELECT TOP 10
        personId,
        username,
        name,
        lastName
    FROM people
    WHERE isDeleted = 0;

END;
GO

GRANT EXECUTE
ON dbo.spViewPeopleBasicInfo
TO SecurityTester;

CREATE USER MaskingTester WITHOUT LOGIN;
GRANT SELECT ON people TO MaskingTester;
GO

CREATE FUNCTION dbo.fnWalletRLS
(
    @PersonId INT
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
(
    SELECT 1 AS Result
    WHERE @PersonId =
        CAST(SESSION_CONTEXT(N'PersonId') AS INT)
);
GO

CREATE SECURITY POLICY WalletSecurityPolicy
ADD FILTER PREDICATE
dbo.fnWalletRLS(personId)
ON dbo.wallets
WITH (STATE = ON);
GO