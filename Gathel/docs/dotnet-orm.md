# Backend .NET y uso de Entity Framework Core

El backend de Gathel está desarrollado con ASP.NET Core Web API. Su propósito es exponer una API REST que permite al frontend comunicarse con la base de datos de forma controlada, validada y organizada.

## Arquitectura general del backend

El backend se estructura principalmente en:

```txt
Controllers
Services
DTOs
Models
Data / DbContext
Stored Procedures
```

Esta separación permite que cada parte tenga una responsabilidad clara.

### Controllers

Los controladores reciben las solicitudes HTTP del frontend. Su responsabilidad principal es exponer endpoints REST como:

```txt
/api/auth/login
/api/auth/register
/api/people/me
/api/propositions/active
/api/propositions/voting
/api/predictions/points
/api/predictions/money
/api/notifications
```

Los controladores delegan operaciones más complejas a los servicios.

### Services

Los servicios contienen la lógica de aplicación. Por ejemplo, `PeopleService`, `PropositionService` y `PredictionService` centralizan operaciones relacionadas con usuarios, proposiciones y predicciones.

### DbContext

El proyecto utiliza Entity Framework Core mediante `GathelDbContext`. Este componente representa el puente entre el backend y la base de datos relacional.

El `DbContext` define las entidades que pueden consultarse desde C# y las asocia con las tablas reales de SQL Server.

Ejemplos de entidades mapeadas:

```txt
People
Propositions
Predictions
Wallets
WalletBalances
Notifications
StatusTypes
```

## Uso de Entity Framework Core

Entity Framework Core se utiliza principalmente para operaciones de lectura. Esto permite consultar datos de forma más natural desde C#, usando LINQ y entidades del dominio.

Ejemplos de lecturas realizadas mediante ORM:

```txt
Consultar información de un usuario.
Consultar proposiciones activas.
Consultar proposiciones en votación.
Consultar predicciones de una proposición.
Consultar notificaciones.
Consultar balances.
```

## Uso de Stored Procedures

Aunque el proyecto utiliza Entity Framework Core, las operaciones críticas de escritura se realizan mediante Stored Procedures en SQL Server.

Esto aplica especialmente a operaciones que modifican datos sensibles o financieros, como:

```txt
Registrar usuario.
Crear proposición.
Votar por una candidata.
Seleccionar proposición ganadora.
Aceptar proposición ganadora.
Rechazar proposición ganadora.
Crear predicción con puntos.
Crear predicción con dinero.
Validar login.
```

Esta decisión permite que las reglas críticas se ejecuten dentro de la base de datos, cerca de los datos y bajo control transaccional.


## Connection Pooling

La conexión del backend hacia SQL Server utiliza un tamaño fijo de pool mediante la cadena de conexión:

```txt
Min Pool Size=10;Max Pool Size=10
```

Esto permite demostrar el uso de connection pooling de tamaño fijo, tal como se solicita en el proyecto. El pool evita abrir una conexión nueva por cada solicitud y reutiliza conexiones existentes, lo cual mejora la eficiencia del backend.

## Seguridad y validación

El backend valida datos importantes antes de ejecutar operaciones. Además, el login se maneja mediante un Stored Procedure que valida la contraseña contra el hash almacenado en la base de datos.

El sistema evita que el frontend acceda directamente a la base de datos. Toda interacción pasa por la API REST, lo que permite controlar reglas, validar entradas y mantener una capa de seguridad entre la interfaz y los datos.

## Ventajas del diseño backend

El diseño del backend aporta las siguientes ventajas:

* Expone una API REST clara para el frontend.
* Separa responsabilidades entre controladores, servicios y acceso a datos.
* Usa Entity Framework Core para lecturas mantenibles.
* Usa Stored Procedures para escrituras críticas.
* Permite aplicar transacciones desde SQL Server.
* Facilita el uso de Swagger para probar endpoints.
* Mantiene una conexión controlada con SQL Server mediante connection pooling.
* Permite una defensa clara del diseño técnico del MVP.
