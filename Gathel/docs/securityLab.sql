--Datos insertados de previo en la base de datos que sirven para el securityLab

/*
INSERT INTO peopleTypes(name, description)
VALUES
('Player', 'Regular player'),
('Admin', 'System administrator'),
('Moderator', 'Content moderator'),
('Auditor', 'System auditor');

INSERT INTO permissionTypes
(
    name,
    description
)
VALUES
('View',   'Allows viewing records'),
('Create', 'Allows creating records'),
('Edit',   'Allows editing records'),
('Delete', 'Allows deleting records');
GO

INSERT INTO permissions
(
    permissionTypeId,
    referenceTypeId
)
SELECT
    pt.permissionTypeId,
    rt.referenceTypeId
FROM permissionTypes pt
CROSS JOIN referenceTypes rt;
GO

INSERT INTO rolePermissions -- Admin
(
    peopleTypeId,
    permissionId
)
SELECT
    2,
    permissionId
FROM permissions;
GO

INSERT INTO rolePermissions -- Moderator
(
    peopleTypeId,
    permissionId
)
SELECT
    3,
    p.permissionId
FROM permissions p
INNER JOIN permissionTypes pt
    ON pt.permissionTypeId = p.permissionTypeId
INNER JOIN referenceTypes rt
    ON rt.referenceTypeId = p.referenceTypeId
WHERE
(
    rt.name IN
    (
        'Proposition',
        'Prediction',
        'Report',
        'Notification'
    )
    AND pt.name IN ('View','Edit')
)
OR
(
    rt.name = 'Penalty'
    AND pt.name IN ('View','Create')
);
GO

INSERT INTO rolePermissions -- Auditor
(
    peopleTypeId,
    permissionId
)
SELECT
    4,
    p.permissionId
FROM permissions p
INNER JOIN permissionTypes pt
    ON pt.permissionTypeId = p.permissionTypeId
INNER JOIN referenceTypes rt
    ON rt.referenceTypeId = p.referenceTypeId
WHERE
    pt.name = 'View';
GO

INSERT INTO rolePermissions -- Player
(
    peopleTypeId,
    permissionId
)
SELECT
    1,
    p.permissionId
FROM permissions p
INNER JOIN permissionTypes pt
    ON pt.permissionTypeId = p.permissionTypeId
INNER JOIN referenceTypes rt
    ON rt.referenceTypeId = p.referenceTypeId
WHERE
(
    rt.name IN
    (
        'Proposition',
        'Prediction'
    )
    AND pt.name IN
    (
        'View',
        'Create'
    )
)
OR
(
    rt.name IN
    (
        'WalletTransaction',
        'WalletReservation',
        'Notification'
    )
    AND pt.name = 'View'
);
GO
*/

-----------------------------------------------------
--Creación de usuarios para la prueba

INSERT INTO people
(peopleTypeId,name,lastName,identification,phone,email,username,birthDate,isVerified,isActive)
VALUES
(
    1, -- Player, este es el rol, de aquí se heredan los permisos insertados arriba
    'usuarioPrueba1',
    'prueba',
    '123456789',
    '88888888',
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
    '123456789',
    '88888888',
    'usuarioPrueba2@gmail.com',
    'usuarioPrueba2Xx',
    '2000-01-01',
    1,
    1
),

--------------------------------------------------
-- Busca el id de un player a partir de su username

SELECT
    personId,
    username,
    name,
    lastName
FROM people
WHERE username = 'usuarioPrueba2Xx';

---------------------------------------------------
--Buscar el id de un permiso

SELECT
    p.permissionId,
    pt.name AS permissionType,
    rt.name AS referenceType
FROM permissions p
INNER JOIN permissionTypes pt
    ON pt.permissionTypeId = p.permissionTypeId
INNER JOIN referenceTypes rt
    ON rt.referenceTypeId = p.referenceTypeId
WHERE
    pt.name = 'Delete'         --Estos dos campos se cambian por el permiso deseado
    AND rt.name = 'Proposition';

--------------------------------------------------
--Asignación del permiso directo

INSERT INTO peoplePermissions
(
    peopleId,
    permissionId
)
SELECT
    p.personId,
    42           --id del permiso, se puede buscar con la consulta anterior
FROM people p
WHERE p.username = 'usuarioPrueba2Xx';

--------------------------------------------------
--Consulta de demostración de permisos

SELECT
    p.personId,
    p.username,
    ptPerm.name AS permissionType,
    rt.name AS resourceName,
    'ROLE' AS permissionSource
FROM people p
INNER JOIN rolePermissions rp
    ON rp.peopleTypeId = p.peopleTypeId
INNER JOIN permissions perm
    ON perm.permissionId = rp.permissionId
INNER JOIN permissionTypes ptPerm
    ON ptPerm.permissionTypeId = perm.permissionTypeId
INNER JOIN referenceTypes rt
    ON rt.referenceTypeId = perm.referenceTypeId
WHERE p.username = 'usuarioPrueba2Xx'

UNION ALL

SELECT
    p.personId,
    p.username,
    ptPerm.name AS permissionType,
    rt.name AS resourceName,
    'DIRECT' AS permissionSource
FROM people p
INNER JOIN peoplePermissions pp
    ON pp.peopleId = p.personId
INNER JOIN permissions perm
    ON perm.permissionId = pp.permissionId
INNER JOIN permissionTypes ptPerm
    ON ptPerm.permissionTypeId = perm.permissionTypeId
INNER JOIN referenceTypes rt
    ON rt.referenceTypeId = perm.referenceTypeId
WHERE p.username = 'usuarioPrueba2Xx'

ORDER BY
    resourceName,
    permissionType,
    permissionSource;

-------------------------------------------------------
-- function de verificación, retorna 1 si sí y 0 si no, es para llamarla en los SP

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
            pp.peopleId = @PersonId
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

------------------------------------------------------
--SP de delete para la prueba
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

----------------------------------------
--Prueba de la llamada al SP de delete

EXEC spDeleteProposition
    @PersonId = 1001,
    @PropositionId = 25;

----------------------------------------
--Demostración del funcionamiento del SP con permisos

SELECT
    propositionId,
    isDeleted
FROM propositions
WHERE propositionId = 25;  

---------------------------------------------------
--SP de lectura de propositions

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

----------------------------------------
--Prueba de la llamada al SP de view

EXEC spDeleteProposition
    @PersonId = 1001,
    @PropositionId = 25;





/* Data masking:

La idea del data masking es proteger datos sensibles de un usuario para que otros usuarios no puedan visualizarlos completamente, esto reduce riesgos de filtración o exposición de datos personales. 

En el caso de Gathel, sería provechoso aplicar data masking en la tabla people, donde se guarda información como correos electrónicos y números de teléfono.

Un ejemplo del uso de data masking es el siguiente:

ALTER TABLE people
ALTER COLUMN email
ADD MASKED WITH (FUNCTION = 'email()');

Resultado:
mXXXXXXX@XXXX.com   

En este caso solo las personas con los permisos necesarios (UNMASK) pueden acceder a estos datos sin masking, por ejemplo un administrador o un db_owner.

Cabe aclarar que el masking no modifica el dato ni lo encripta/cifra, sino que simplemente protege la visualización de datos para los usuarios no autorizados.

Ejemplos con otros datos de la tabla people:

ALTER TABLE people
ALTER COLUMN phone
ADD MASKED WITH
(
    FUNCTION = 'partial(0,"******",2)'        --partial(inicio,masked,final)
);

Resultado:
******77


ALTER TABLE people
ALTER COLUMN identification
ADD MASKED WITH
(
    FUNCTION = 'partial(0,"*******",2)'
);

Resultado:
*******89

*/







/* RLS

El objetivo del RLS es que cada usuario solo pueda acceder a su propia información dentro de tablas específicas.

Por ejemplo la tabla wallets, en este caso, lo correcto es que cada usuario solamente pueda tener acceso a su propia información financiera, no tendría sentido que un usuario pueda consultar la información financiera de otros usuarios.

RLS permite garantizar que cada usuario vea únicamente los registros asociados a su cuenta.

Esto reduce el riesgo de exposición de información privada y protege la información financiera de las personas, siguiendo el ejemplo de wallets.

Funcionamiento:

La idea es que varios usuarios realizan la misma consulta, sin embargo, aunque la consulta sea igual, obtienen únicamente la información relacionada con sus cuentas y no las de todos los usuarios.

Ejemplo:

Función de filtro

CREATE FUNCTION fnWalletSecurity
(
    @PersonId INT
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
(
    SELECT 1
    WHERE @PersonId =
        CAST(SESSION_CONTEXT(N'PersonId') AS INT)    --La función filtra la tabla de acuerdo al personId
);

Posteriormente se crea un policy

CREATE SECURITY POLICY WalletPolicy
ADD FILTER PREDICATE
dbo.fnWalletSecurity(personId)            --El policy utiliza la función de filtro
ON dbo.wallets;

Resultado:
El usuario al consultar directamente la tabla, solo ve el registro correspondiente a su wallet.

La aplicación de RLS requiere utilizar mecanismos nativos de autenticación del motor de base de datos, los cuales permiten manejar inicios de sesión, autenticaciones y demás; que permiten asociar los usuarios con las sesiones, y así aplicar los filtros sobre las filas visibles.

*/




/*   Cifrado de contraseñas   */

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

------------------------------------------------
-- SP para user con password cifrada

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

---------------------------------------
--Uso del SP con clave cifrada

EXEC spCreateUserEncrypted
    @PeopleTypeId = 1,
    @Name = 'Miguel',
    @LastName = 'Prueba',
    @Identification = '123456789',
    @Phone = '88888888',
    @Email = 'miguel777@gmail.com',
    @Username = 'userPrueba3',
    @Password = 'Password123',    <---------------- Contraseña utilizada
    @BirthDate = '2000-01-01';

-------------------------------------
--Comprobación de cifrado
SELECT
    personId,
    username,
    passwordHash
FROM people
WHERE username = 'userPrueba3';

--------------------------------------------------
--Comprobación de descifrado
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

------------------------------------------------
--Llamada al SP de descifrado
EXEC spViewDecryptedPassword
    @Username = 'userPrueba3';

--La contraseña se almacena cifrada mediante la clave simétrica que es protegida por el certificado y el master key, sin acceso a estos objetos, el valor almacenado para la contraseña en la base de datos es ilegible