--Demostración acceso a información mediante SP

CREATE USER SecurityTester WITHOUT LOGIN;

DENY SELECT
ON dbo.people
TO SecurityTester;

CREATE OR ALTER PROCEDURE spViewPeopleBasicInfo
AS
BEGIN

    SELECT
        personId,
        username,
        name,
        lastName
    FROM people
    WHERE isDeleted = 0;
    LIMIT 10

END;
GO

GRANT EXECUTE
ON dbo.spViewPeopleBasicInfo
TO SecurityTester;

EXECUTE AS USER = 'SecurityTester';

SELECT *
FROM people;

EXEC spViewPeopleBasicInfo;

REVERT;




-- Data Masking

ALTER TABLE people
ALTER COLUMN email
ADD MASKED WITH (FUNCTION = 'email()');

--Masking de algunos datos sensibles o personales en la tabla people
ALTER TABLE people
ALTER COLUMN identification
ADD MASKED WITH
(
    FUNCTION = 'partial(0,"******",2)'
);

ALTER TABLE people
ALTER COLUMN phone
ADD MASKED WITH
(
    FUNCTION = 'partial(0,"****",2)'
);

CREATE USER MaskingTester WITHOUT LOGIN;
GRANT SELECT ON people TO MaskingTester;

--Prueba como user sin permisos de UNMASK
EXECUTE AS USER = 'MaskingTester';

SELECT
    email,
    phone,
    identification
FROM people;

REVERT;    --Vuelve al usuario admin

--Prueba como admin
SELECT
    email,
    phone,
    identification
FROM people;




--RLS
CREATE FUNCTION dbo.fnWalletRLS
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
        CAST(SESSION_CONTEXT(N'PersonId') AS INT)
);
GO

CREATE SECURITY POLICY WalletSecurityPolicy
ADD FILTER PREDICATE
dbo.fnWalletRLS(personId)
ON dbo.wallets
WITH (STATE = ON);
GO

--Prueba con un usuario
EXEC sp_set_session_context
    @key = N'PersonId',
    @value = 20;

SELECT *
FROM wallets;

--Prueba con otro usuario
EXEC sp_set_session_context
    @key = N'PersonId',
    @value = 10;

SELECT *
FROM wallets;

--Volver al admin
EXEC sp_set_session_context
    @key = N'PersonId',
    @value = NULL;