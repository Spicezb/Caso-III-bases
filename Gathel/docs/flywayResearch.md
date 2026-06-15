# Guía de Flyway - Gathel

Flyway es una herramienta que facilita el control de versiones de una base de datos, esto ayudando a tener los datos de forma más ordenada.

El objetivo principal de esta guía/documentación es garantizar que todos los integrantes puedan crear la misma estructura de base de datos y cargar el mismo contenido inicial en sus ambientes locales usando los mismos scripts SQL versionados.

## Instalación

Para este proyecto se decidió utilizar Flyway mediante Docker Compose, por lo que no es necesario instalar Flyway directamente en cada computadora. Optamos por esto porque lo sentimos más sencillo y no teníamos que instalar software externo, ya que, ya contabamos con el Docker-Desktop.

Requisitos:
* Docker Desktop.
* SQL Server Management Studio.
* Git.
* Repositorio del proyecto clonado localmente.

Flyway se ejecuta como un contenedor definido en el archivo `docker-compose.yml` en la raíz del proyecto.

## Configuración

La configuración principal de Flyway se encuentra en el archivo .yml: 

```txt
flyway/conf/flyway.conf
```

Configuración utilizada:

```properties
flyway.url=jdbc:sqlserver://sqlserver:1433;databaseName=GathelDB;encrypt=true;trustServerCertificate=true
flyway.user=sa
flyway.password=Gathel123!

flyway.locations=filesystem:/flyway/sql
flyway.defaultSchema=dbo
flyway.schemas=dbo,security,game,economy,ai,audit

flyway.baselineOnMigrate=true
flyway.validateOnMigrate=true
flyway.outOfOrder=false
```

Explicación de los parámetros principales:

| Parámetro                  | Descripción                                                     |
| -------------------------- | --------------------------------------------------------------- |
| `flyway.url`               | Cadena JDBC utilizada para conectarse a SQL Server.             |
| `flyway.user`              | Usuario utilizado por Flyway para ejecutar las migraciones.     |
| `flyway.password`          | Contraseña del usuario de base de datos.                        |
| `flyway.locations`         | Ruta donde se encuentran los scripts SQL de migración.          |
| `flyway.schemas`           | Esquemas administrados por el proyecto.                         |
| `flyway.baselineOnMigrate` | Permite inicializar Flyway sobre una base no vacía si aplica.   |
| `flyway.validateOnMigrate` | Valida que las migraciones aplicadas no hayan sido modificadas. |
| `flyway.outOfOrder`        | Evita ejecutar migraciones fuera de orden.                      |

## Estructura de carpetas

La estructura de Flyway dentro del proyecto es la siguiente:

```txt
flyway/
├── conf/
│   └── flyway.conf
│
└── sql/
    ├── V1__create_schemas.sql
    ├── V2__create_tables.sql
    ├── V3__constraints_indexes.sql
    ├── V4__stored_procedures.sql
    ├── V5__views_functions.sql
    ├── V6__security_lab.sql
    ├── V7__transactions_concurrency.sql
    └── V8__seed_data.sql
```

## Versionamiento

Flyway ejecuta las migraciones siguiendo el orden definido por el número de versión en el nombre del archivo. Este formato lo optamos por lo que se observó en el manual de usuario de flyway. 

Formato utilizado (Muy importante mantener la estructura):

```txt
V<numero>__descripcion.sql
```

Ejemplos:

```txt
V1__create_schemas.sql
V2__create_tables.sql
V3__constraints_indexes.sql
```

## Ejecución de migraciones

Primero se levanta SQL Server:

```bash
docker compose up -d sqlserver
```

Después se ejecuta Flyway:

```bash
docker compose run --rm flyway
```

## Verificación desde SQL

También se puede revisar el historial dentro de SQL Server con:

```sql
USE GathelDB;
GO

SELECT *
FROM flyway_schema_history;
GO
```

La tabla `flyway_schema_history` permite verificar qué migraciones fueron ejecutadas, en qué orden, en qué fecha y con cuál resultado.

## Rollback

En este proyecto no se utiliza rollback automático de Flyway como mecanismo principal.

La estrategia definida para el rollback es:

1. Si el proyecto está en etapa inicial y no hay datos importantes, se puede reconstruir el ambiente local eliminando el volumen de Docker:

```bash
docker compose down -v
docker compose up -d sqlserver
docker compose run --rm flyway
```

2. Si la base ya tiene datos relevantes, se debe crear una nueva migración correctiva.

Ejemplo:

```txt
V9__fix_players_constraints.sql
```

3. Para ambientes importantes, se recomienda realizar respaldos antes de ejecutar migraciones críticas. No ejecutar versiones hasta estar seguros que están bien. 

## Hallazgos relevantes obtenidos durante las pruebas

Durante la configuración y pruebas de Flyway con SQL Server se identificaron los siguientes hallazgos:

### 1. La base de datos debe existir antes de conectar Flyway a ella

Si `flyway.url` apunta directamente a `GathelDB`, la base debe existir previamente. De lo contrario, Flyway muestra un error indicando que no puede abrir la base solicitada por el login.

Solución aplicada:

* Crear `GathelDB` previamente en SQL Server.
* Luego ejecutar las migraciones de Flyway sobre esa base.

### 2. El nombre del servicio Docker se usa como host

Dentro de Docker Compose, Flyway no se conecta a SQL Server usando `localhost`, sino usando el nombre del servicio:

```properties
jdbc:sqlserver://sqlserver:1433
```

Esto ocurre porque ambos contenedores están dentro de la misma red de Docker Compose.

### 3. La contraseña de `sa` queda asociada al volumen de SQL Server

Si se cambia la contraseña en `docker-compose.yml`, pero el volumen anterior sigue existiendo, SQL Server mantiene la configuración previa.

Solución aplicada en pruebas:

```bash
docker compose down -v
docker compose up -d sqlserver
```

### 4. Flyway registra automáticamente las migraciones aplicadas

Al ejecutar las migraciones, Flyway crea la tabla `flyway_schema_history`, donde se almacena el historial de scripts aplicados.

### 5. Las migraciones ya aplicadas no deben modificarse

Si se modifica un script que ya fue ejecutado, Flyway puede detectar diferencias por validación. Por esta razón, cualquier cambio posterior debe realizarse en una nueva migración.

## Conclusión

Flyway permite mantener controlado el ciclo de cambios de la base de datos del proyecto Gathel. Su integración con Docker Compose facilita que todos los integrantes del equipo puedan ejecutar las mismas migraciones y obtener una base de datos versionada y todos accediendo a lo mismo.

## Referencias

Video tutorial: https://www.youtube.com/watch?v=qsacSRcHCCs
Documentación oficial: https://documentation.red-gate.com/fd/getting-started-with-flyway-184127223.html

## Importante!!!!
En cada version poner la estructura así, esto porque flyway va a guardar cada cambio con el usuario sa. Entonces, así llevamos un registro de quien hizo cada cambio más rápidamente. Para la revisión del profesor se espera que vea los commits en github y ahí vería quien hizo cada versión. 

En cada versión empezar con "USE GathelDB" !!!!!

```sql
USE GathelDB;
GO

/*
    Author: Sebastián Aguilar Villalobos
    Purpose: Create game.Propositions table.
*/

CREATE TABLE game.Propositions (
    proposition_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(200) NOT NULL
);
GO
```