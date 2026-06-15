# Gathel, Gaming The Life 

Caso #3 - Bases de Datos I 

Gathel es un juego digital de predicciones basado en acciones y eventos de la vida real de las personas, validados mediante redes sociales e inteligencia artificial.

Al registrarse en la plataforma, los jugadores pueden asociar una o varias cuentas de redes sociales, por ejemplo Instagram o TikTok. Esto permite que Gathel solicite autorización para acceder automáticamente a publicaciones, historias, reels, videos y demás contenido público o autorizado por el usuario.

Cada jugador inicia con un balance inicial de 100 puntos (pts) dentro de la plataforma.

## Estudiantes:
- Sebastián Aguilar Villalobos, 2025072110
- Xavier Céspedes Alvarado, 2025102887 
- Andrés Campos Montero, 2025069367

## Objetivo del proyecto

Diseñar una base de datos que cumpla con lo solicitado por el profesor y un MVP funcional para Gathel.

El proyecto contempla el diseño del modelo de datos, documentación técnica, migraciones con Flyway, scripts de seeding, laboratorios de seguridad, pruebas de transacciones y concurrencia, además de una aplicación mínima con frontend, backend y REST API.

## Guía del proyecto (Documentación) 

Por definir... Acá irían enlaces a carpetas especificas tipo Agentes IA -> Enlace a carpeta

La documentación se divide en cuatro áreas principales:

1. **Diseño de base de datos:** especificación Markdown, DBML y diagrama PDF.
2. **Administración de base de datos:** migraciones Flyway, seeding, scripts SQL y datos iniciales.
3. **Laboratorios técnicos:** seguridad, transacciones, concurrencia y live coding.
4. **MVP:** backend, frontend, endpoints, ejecución y Docker Compose.

## Alcance del MVP

Por definir... En general funcionalidades básicas del sitio web y lo más complejo se trabajará por medio de SP o scripts (esta parte meramente simulativa).

## Estructura del Repositorio

Por definir... Como están acomodadas las carpetas dentro del repositorio. Ejemplo: 

```txt
gathel/
│
├── README.md
├── docker-compose.yml
│
├── docs/
│   ├── database-spec.md
│   ├── flyway-guide.md
│   ├── seeding.md
│   ├── security-lab.md
│   ├── transactions-concurrency.md
│   ├── live-coding-guide.md
│   ├── docker-guide.md
│   │
│   ├── agents/
│   │   └── README.md
│   │
│   └── agent-results/
│       └── README.md
│
├── dbml/
│   └── gathel.dbml
│
├── diagrams/
│   └── gathel-database.pdf
│
├── flyway/
│   ├── conf/
│   │   └── flyway.conf
│   │
│   └── sql/
│       ├── V1__create_schemas.sql
│       ├── V2__create_tables.sql
│       ├── V3__constraints_indexes.sql
│       ├── V4__stored_procedures.sql
│       ├── V5__views_functions.sql
│       ├── V6__security_lab.sql
│       ├── V7__transactions_concurrency.sql
│       └── V8__seed_data.sql
│
├── backend/
│   └── README.md
│
└── frontend/
    └── README.md
```

## Agentes Implementados 

Los agentes utilizados para la revisión de la base de datos fueron... Se ponen los agentes 

## Tecnologías utilizadas

| Área | Tecnología |
|---|---|
| Base de datos | SQL Server |
| Migraciones | Flyway |
| Backend | Por definir... |
| Frontend | Por definir... |
| Contenedores | Docker / Docker Compose |
| Diagramas | Diagramador de SQL server |
| Control de versiones | Git / GitHub |

## Migraciones Flyway

Todas las modificaciones oficiales de la base de datos se administrarán mediante Flyway.
Para este proyecto, Flyway se ejecuta mediante Docker Compose, por lo que no es necesario instalar Flyway manualmente en cada computadora.

Flyway se encarga de ejecutar los scripts SQL versionados y registrar cuáles migraciones ya fueron aplicadas dentro de la tabla interna flyway_schema_history.

Accede a la guía aquí para entender mejor lo que se hizo: [Guía de Flyway](Gathel\docs"/flywayResearch.md)

## Seeding 

El script de seeding deberá generar como mínimo:

- 1000 jugadores.
- 5000 proposiciones.
- 250000 eventos asociados a proposiciones.
- Registros de pagos correspondientes a las 5000 proposiciones.

El seeding se implementará mediante bucles en SQL Server, evitando inserts exhaustivos escritos manualmente.

También deberá garantizar:

- Integridad referencial.
- Timestamps coherentes.
- Datos realistas.
- Relaciones válidas entre jugadores, proposiciones, predicciones, pagos y resultados.

## Ejecución del proyecto

El proyecto utiliza Docker Compose para levantar los servicios necesarios.
Actualmente se configuró SQL Server y Flyway mediante contenedores.

### Requisitos previos

* Git.
* Docker Desktop.
* SQL Server Management Studio.
* Visual Studio Code o editor equivalente.
* Node.js LTS, cuando se implemente el frontend o backend.

No es necesario instalar Flyway manualmente, ya que se ejecuta mediante Docker Compose.

### Levantar SQL Server

Desde la raíz del proyecto:

```bash
docker compose up -d sqlserver
```

### Ejecutar migraciones con Flyway

Cuando existan scripts SQL con contenido real dentro de `flyway/sql`, se ejecuta:

```bash
docker compose run --rm flyway
```

### Verificar migraciones aplicadas

En SQL Server Management Studio conectarse con:

```txt
Servidor: localhost,1433
Usuario: sa
Contraseña: Gathel123!
```

Luego ejecutar:

```sql
USE GathelDB;
GO

SELECT *
FROM flyway_schema_history;
GO
```

## Estado actual del proyecto

| Fase                                     | Estado      |
| ---------------------------------------- | ----------- |
| Repositorio inicial                      | En progreso |
| README inicial                           | En progreso |
| Docker Compose con SQL Server            | Configurado |
| Flyway mediante Docker Compose           | Configurado |
| Configuración `flyway.conf`              | En progreso |
| Scripts SQL definitivos                  | Pendiente   |
| Seeding inicial                          | Pendiente   |
| Especificación Markdown de base de datos | Pendiente   |
| DBML                                     | Pendiente   |
| Diagrama PDF                             | Pendiente   |
| Backend MVP                              | Pendiente   |
| Frontend MVP                             | Pendiente   |


### Requisitos previos

- Git
- Docker Desktop
- SQL Server Management Studio
- Por definir... La parte del frontend 

### Levantar servicios

Por definir... Como se va a levantar el proyecto
