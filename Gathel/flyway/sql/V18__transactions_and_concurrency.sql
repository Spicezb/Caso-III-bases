/*                     Transacciones y concurrencia, ejemplos y explicacion de cada caso 
/*
=========================================================
DEMO #1 - TRANSACCIONES ANIDADAS
=========================================================

La idea de este ejemplo es demostrar que una transacción
mantiene el principio de todo o nada.

Se tienen 3 procedimientos almacenados:

sp_DepositMoney
    -> sp_CreateWalletTransaction
        -> sp_CreateAuditLog

Si el último SP falla, entonces todas las operaciones
realizadas por los niveles superiores también deben
revertirse mediante ROLLBACK.

Resultado esperado:

Caso exitoso:
- Se actualiza la wallet.
- Se crea la transacción.
- Se crea el audit log.
- COMMIT.

Caso fallido:
- El último SP genera un error.
- Se ejecuta ROLLBACK.
- Ningún cambio queda guardado.
*/


-- Caso exitoso
CREATE OR ALTER PROCEDURE sp_demo1_level3_success --SP nivel 3
(
    @personId INT
)
AS
BEGIN

    INSERT INTO auditLogs
    (
        referenceTypeId,
        referenceId,
        actionType,
        personId
    )
    VALUES
    (
        14,
        @personId,
        'INSERT',
        @personId
    );

END;
GO

CREATE OR ALTER PROCEDURE sp_demo1_level2_success --SP nivelm2
(
    @personId INT
)
AS
BEGIN

    INSERT INTO followRequests
    (
        senderPersonId,
        receiverPersonId,
        statusTypeId
    )
    VALUES
    (
        @personId,
        ((@personId % 1000) + 1),
        1
    );

    EXEC sp_demo1_level3_success
        @personId;

END;
GO

CREATE OR ALTER PROCEDURE sp_demo1_level1_success --SP nivel 1
(
    @personId INT
)
AS
BEGIN

    BEGIN TRY

        BEGIN TRAN

            INSERT INTO follows
            (
                followerPersonId,
                followedPersonId
            )
            VALUES
            (
                @personId,
                ((@personId % 1000) + 2)
            );

            EXEC sp_demo1_level2_success
                @personId;

        COMMIT;

    END TRY
    BEGIN CATCH

        ROLLBACK;

        THROW;

    END CATCH

END;
GO

EXEC sp_demo1_level1_success 1; --Llama el proceso

--Caso fallido
CREATE OR ALTER PROCEDURE sp_demo1_level3_fail --SP nivel 3
(
    @personId INT
)
AS
BEGIN

    RAISERROR
    (
        'Error provocado intencionalmente',
        16,
        1
    );

END;
GO

CREATE OR ALTER PROCEDURE sp_demo1_level2_fail --SP nivel 2
(
    @personId INT
)
AS
BEGIN

    INSERT INTO followRequests
    (
        senderPersonId,
        receiverPersonId,
        statusTypeId
    )
    VALUES
    (
        @personId,
        ((@personId % 1000) + 3),
        1
    );

    EXEC sp_demo1_level3_fail
        @personId;

END;
GO

CREATE OR ALTER PROCEDURE sp_demo1_level1_fail --SP nivel 1
(
    @personId INT
)
AS
BEGIN

    BEGIN TRY

        BEGIN TRAN

            INSERT INTO follows
            (
                followerPersonId,
                followedPersonId
            )
            VALUES
            (
                @personId,
                ((@personId % 1000) + 4)
            );

            EXEC sp_demo1_level2_fail
                @personId;

        COMMIT;

    END TRY
    BEGIN CATCH

        ROLLBACK;

        PRINT 'TRANSACCION REVERTIDA';

    END CATCH

END;
GO

EXEC sp_demo1_level1_fail 1; --Llama el proceso


/*
=========================================================
DEMO #2 - DEADLOCK ENTRE DOS TRANSACCIONES
=========================================================

En este escenario voy a provocar un deadlock de forma
intencional.

T1 bloquea primero Wallet 1 y luego intenta acceder
a Wallet 2.

T2 bloquea primero Wallet 2 y luego intenta acceder
a Wallet 1.

Se genera una espera circular:

T1 espera a T2.
T2 espera a T1.

SQL Server detecta el deadlock y escoge una de las
transacciones como víctima para romper el ciclo.

Este es uno de los problemas más comunes cuando
varias transacciones actualizan recursos en distinto
orden.
*/


BEGIN TRAN --T1

    UPDATE walletBalances
    SET balancePointsAmount = balancePointsAmount - 1000,
        newPointsAmount = balancePointsAmount - 1000
    WHERE walletId = 1;

    WAITFOR DELAY '00:00:05';

    UPDATE walletBalances
    SET balancePointsAmount = balancePointsAmount + 1000,
        newPointsAmount = balancePointsAmount + 1000
    WHERE walletId = 2;

COMMIT;
GO

BEGIN TRAN --T2

    UPDATE walletBalances
    SET balancePointsAmount = balancePointsAmount - 500,
        newPointsAmount = balancePointsAmount - 500
    WHERE walletId = 2;

    WAITFOR DELAY '00:00:05';

    UPDATE walletBalances
    SET balancePointsAmount = balancePointsAmount + 500,
        newPointsAmount = balancePointsAmount + 500
    WHERE walletId = 1;

COMMIT;
GO


/*
=========================================================
DEMO #3 - DEADLOCK ENTRE LECTURA Y ESCRITURA
=========================================================

Normalmente uno asocia los deadlocks con dos UPDATE,
pero también pueden ocurrir cuando una transacción
realiza lecturas y otra escrituras.

En este ejemplo T1 realiza una lectura utilizando
REPEATABLE READ, por lo que mantiene bloqueada la fila
que acaba de leer.

Mientras tanto T2 actualiza otro recurso y después
intenta modificar la fila que T1 tiene bloqueada.

Posteriormente T1 intenta actualizar el recurso que
T2 mantiene bloqueado.

Se genera la siguiente situación:

T1 espera a T2.
T2 espera a T1.

SQL Server detecta el ciclo de espera y selecciona
una de las transacciones como víctima del deadlock.

Este caso demuestra que las lecturas también pueden
participar en deadlocks dependiendo del nivel de
aislamiento utilizado.
*/


--T1
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

BEGIN TRAN

    SELECT balancePointsAmount
    FROM walletBalances
    WHERE walletId = 1;

    WAITFOR DELAY '00:00:05';

    UPDATE walletBalances
    SET balancePointsAmount = balancePointsAmount + 1000
    WHERE walletId = 2;

COMMIT;
GO

BEGIN TRAN --T2

    UPDATE walletBalances
    SET balancePointsAmount = balancePointsAmount - 500
    WHERE walletId = 2;

    WAITFOR DELAY '00:00:05';

    UPDATE walletBalances
    SET balancePointsAmount = balancePointsAmount + 500
    WHERE walletId = 1;

COMMIT;
GO


/*
=========================================================
DEMO #4 - DEADLOCK CICLICO T1 -> T2 -> T3 -> T1
=========================================================

En este escenario participan tres transacciones.

T1 bloquea Wallet 1 y luego necesita Wallet 2.

T2 bloquea Wallet 2 y luego necesita Wallet 3.

T3 bloquea Wallet 3 y luego necesita Wallet 1.

Se forma el siguiente ciclo:

T1 -> T2
T2 -> T3
T3 -> T1

Ninguna transacción puede continuar.

SQL Server detecta el ciclo y finaliza una de ellas
para resolver el deadlock.
*/


BEGIN TRAN --T1

    UPDATE walletBalances
    SET balancePointsAmount = balancePointsAmount - 1000
    WHERE walletId = 1;

    WAITFOR DELAY '00:00:07';

    UPDATE walletBalances
    SET balancePointsAmount = balancePointsAmount + 1000
    WHERE walletId = 2;

COMMIT;
GO

BEGIN TRAN --T2

    UPDATE walletBalances
    SET balancePointsAmount = balancePointsAmount - 500
    WHERE walletId = 2;

    WAITFOR DELAY '00:00:07';

    UPDATE walletBalances
    SET balancePointsAmount = balancePointsAmount + 500
    WHERE walletId = 3;

COMMIT;
GO

BEGIN TRAN --T3

    UPDATE walletBalances
    SET balancePointsAmount = balancePointsAmount - 200
    WHERE walletId = 3;

    WAITFOR DELAY '00:00:07';

    UPDATE walletBalances
    SET balancePointsAmount = balancePointsAmount + 200
    WHERE walletId = 1;

COMMIT;
GO


/*
=========================================================
DEMO #5 - DIRTY READ
=========================================================

Problema demostrado:
Dirty Read

Un Dirty Read ocurre cuando una transacción lee datos
que fueron modificados por otra transacción pero que
todavía no han sido confirmados mediante COMMIT.

Si la transacción que realizó el cambio ejecuta
ROLLBACK, entonces la información leída nunca existió
realmente.

Niveles de aislamiento donde puede ocurrir:

READ UNCOMMITTED -> SI
READ COMMITTED   -> NO
REPEATABLE READ  -> NO
SERIALIZABLE     -> NO

Este ejemplo utiliza READ UNCOMMITTED para demostrar
el problema.
*/

/*
=========================================================
COMO IDENTIFICAR UN DIRTY READ
=========================================================

Se puede identificar cuando una transacción lee un
valor que posteriormente desaparece debido a un
ROLLBACK realizado por otra transacción.

Algunos síntomas comunes son:

- Resultados inconsistentes entre consultas.
- Datos que aparecen temporalmente y luego desaparecen.
- Reportes o cálculos realizados con información que
  realmente nunca fue confirmada.

En este ejemplo se puede identificar observando que
T2 lee el nuevo saldo mientras T1 todavía no ha hecho
COMMIT.

Posteriormente T1 ejecuta ROLLBACK y el valor leído
por T2 nunca existió realmente.

=========================================================
COMO MITIGAR O SOLUCIONARLO
=========================================================

La forma más sencilla es evitar READ UNCOMMITTED.

Opciones:

- Utilizar READ COMMITTED o superior.
- Diseñar procesos críticos para trabajar únicamente
  con datos confirmados.

En Gathel este problema podría afectar consultas de
saldo de billeteras o validaciones previas a una
predicción.

Un usuario podría visualizar un saldo que todavía no
ha sido confirmado y tomar decisiones basadas en un
valor que posteriormente desaparece debido a un
ROLLBACK.

Esto podría provocar inconsistencias en procesos de
apuestas, reservas de fondos o generación de reportes.
*/


BEGIN TRAN --T1

    UPDATE walletBalances
    SET balancePointsAmount = balancePointsAmount - 1000
    WHERE walletId = 1;

    WAITFOR DELAY '00:00:10';

ROLLBACK;
GO

--T2
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

BEGIN TRAN

    SELECT balancePointsAmount
    FROM walletBalances
    WHERE walletId = 1;

    WAITFOR DELAY '00:00:10';

    SELECT balancePointsAmount
    FROM walletBalances
    WHERE walletId = 1;

COMMIT;
GO


/*
=========================================================
DEMO #6 - NONREPEATABLE READ
=========================================================

Problema demostrado:
Nonrepeatable Read

Un Nonrepeatable Read ocurre cuando una transacción
lee una fila, otra transacción la modifica y hace
COMMIT, y posteriormente la primera transacción vuelve
a leer la misma fila obteniendo un valor diferente.

Niveles de aislamiento donde puede ocurrir:

READ UNCOMMITTED -> SI
READ COMMITTED   -> SI
REPEATABLE READ  -> NO
SERIALIZABLE     -> NO

Este ejemplo utiliza READ COMMITTED para demostrar
el problema.
*/

/*
=========================================================
COMO IDENTIFICAR UN NONREPEATABLE READ
=========================================================

Se identifica cuando una misma consulta devuelve
valores distintos para una misma fila dentro de la
misma transacción.

Síntomas comunes:

- Totales que cambian durante una operación.
- Validaciones que se ejecutan con un valor y luego
  actualizan utilizando otro valor diferente.
- Resultados inconsistentes en procesos largos.

En este ejemplo T1 consulta el saldo dos veces y
obtiene valores distintos porque T2 modificó el
registro entre ambas lecturas.

=========================================================
COMO MITIGAR O SOLUCIONARLO
=========================================================

Opciones:

- Utilizar REPEATABLE READ.
- Utilizar SERIALIZABLE.
- Reducir la duración de las transacciones.
- Evitar múltiples lecturas de los mismos datos cuando
  no sean necesarias.

En Gathel este problema podría afectar validaciones
realizadas sobre billeteras, predicciones o pagos.

Por ejemplo, un proceso podría consultar el saldo de
una billetera para verificar que existen fondos
suficientes y, antes de finalizar la operación,
otro proceso modificar dicho saldo.

Como resultado, la misma consulta devolvería valores
distintos dentro de la misma transacción, provocando
decisiones basadas en información que ya cambió.
*/


--T1
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

BEGIN TRAN

    SELECT balancePointsAmount
    FROM walletBalances
    WHERE walletId = 1;

    WAITFOR DELAY '00:00:10';

    SELECT balancePointsAmount
    FROM walletBalances
    WHERE walletId = 1;

COMMIT;
GO

BEGIN TRAN --T2

    WAITFOR DELAY '00:00:05';

    UPDATE walletBalances
    SET balancePointsAmount = balancePointsAmount + 2000
    WHERE walletId = 1;

COMMIT;
GO


/*
=========================================================
DEMO #7 - PHANTOM READ
=========================================================

Problema demostrado:
Phantom Read

Un Phantom Read ocurre cuando una consulta obtiene un
conjunto de registros y posteriormente, dentro de la
misma transacción, vuelve a ejecutar la consulta y
aparecen nuevas filas que antes no existían.

No cambia una fila existente, sino que aparecen o
desaparecen registros completos.

Niveles de aislamiento donde puede ocurrir:

READ UNCOMMITTED -> SI
READ COMMITTED   -> SI
REPEATABLE READ  -> SI
SERIALIZABLE     -> NO

Este ejemplo utiliza REPEATABLE READ para demostrar
el problema.

La solución es SERIALIZABLE, ya que bloquea el rango
completo involucrado en la consulta.
*/

/*
=========================================================
COMO IDENTIFICAR UN PHANTOM READ
=========================================================

Se identifica cuando una consulta devuelve una
cantidad diferente de registros durante la misma
transacción.

Síntomas comunes:

- COUNT(*) cambia entre consultas.
- Nuevos registros aparecen sin haber sido visibles
  anteriormente.
- Reportes muestran cantidades distintas dentro del
  mismo proceso.

En este ejemplo T1 consulta la cantidad de solicitudes
de seguimiento para un usuario.

Mientras T1 espera, T2 inserta una nueva solicitud.

Cuando T1 vuelve a ejecutar la consulta obtiene una
cantidad diferente de registros.

=========================================================
COMO MITIGAR O SOLUCIONARLO
=========================================================

Opciones:

- Utilizar SERIALIZABLE.
- Mantener las transacciones lo más cortas posible.
- Evitar consultas repetidas sobre conjuntos de datos
  que están siendo modificados constantemente.

En Gathel este problema podría afectar reportes,
estadísticas y métricas generadas sobre la actividad
de los usuarios.

Por ejemplo, un proceso podría contar la cantidad de
seguidores, solicitudes de seguimiento o predicciones
existentes para un usuario y, mientras la transacción
sigue activa, otro proceso insertar nuevos registros.

Al volver a ejecutar la misma consulta, aparecerían
filas que no existían anteriormente, generando
resultados inconsistentes dentro del mismo proceso
de análisis o generación de reportes.
*/


--T1
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

BEGIN TRAN

    SELECT COUNT(*) AS totalFollows
    FROM followRequests
    WHERE receiverPersonId = 10;

    WAITFOR DELAY '00:00:10';

    SELECT COUNT(*) AS totalFollows
    FROM followRequests
    WHERE receiverPersonId = 10;

COMMIT;
GO

BEGIN TRAN --T2

    WAITFOR DELAY '00:00:05';

    INSERT INTO followRequests
    (
        senderPersonId,
        receiverPersonId,
        statusTypeId
    )
    VALUES
    (
        999,
        10,
        1
    );

COMMIT;
GO
*/