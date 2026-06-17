/*
Creacion y llenado de el modulo de permisos de la DB
*/

/*=========================================================
  Creacion de tablas
=========================================================*/


USE GathelDB;
GO

CREATE TABLE permissionTypes(
    permissionTypeId INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(20),
    description VARCHAR(100),
    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0
);
GO

CREATE TABLE permissions(
    permissionId INT IDENTITY(1,1) PRIMARY KEY,

    permissionTypeId INT NOT NULL,
    referenceTypeId INT NOT NULL,

    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_permissions_permissionTypes
        FOREIGN KEY(permissionTypeId)
        REFERENCES permissionTypes(permissionTypeId),

    CONSTRAINT FK_permissions_referenceTypes
        FOREIGN KEY(referenceTypeId)
        REFERENCES referenceTypes(referenceTypeId),

    CONSTRAINT UQ_permissions
        UNIQUE(permissionTypeId, referenceTypeId)
);
GO

CREATE TABLE rolePermissions(
    rolePermissionId INT IDENTITY(1,1) PRIMARY KEY,

    peopleTypeId INT NOT NULL,
    permissionId INT NOT NULL,

    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_rolePermissions_peopleTypes
        FOREIGN KEY(peopleTypeId)
        REFERENCES peopleTypes(peopleTypeId),

    CONSTRAINT FK_rolePermissions_permissions
        FOREIGN KEY(permissionId)
        REFERENCES permissions(permissionId),

    CONSTRAINT UQ_rolePermissions
        UNIQUE(peopleTypeId, permissionId)
);
GO

CREATE TABLE peoplePermissions(
    peoplePermissionId INT IDENTITY(1,1) PRIMARY KEY,

    personId INT NOT NULL,
    permissionId INT NOT NULL,

    createdAt DATETIME2(3) DEFAULT GETDATE(),
    updatedAt DATETIME2(3) DEFAULT GETDATE(),
    isDeleted BIT DEFAULT 0,

    CONSTRAINT FK_peoplePermissions_people
        FOREIGN KEY(personId)
        REFERENCES people(personId),

    CONSTRAINT FK_peoplePermissions_permissions
        FOREIGN KEY(permissionId)
        REFERENCES permissions(permissionId),

    CONSTRAINT UQ_peoplePermissions
        UNIQUE(personId, permissionId)
);
GO


/*=========================================================
  LLenado de datos
=========================================================*/

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

-- La tabla de permisos por persona en especifico enpieza vacia, 
-- esa se llenara conforme se necesite en el desarrollo del programa