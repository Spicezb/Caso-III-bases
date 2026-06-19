# Gathel, Gaming The Life

Caso #3 - Bases de Datos I

Gathel es un juego digital de predicciones basado en acciones y eventos de la vida real de las personas, validados mediante redes sociales e inteligencia artificial.

Al registrarse en la plataforma, los jugadores pueden asociar una o varias cuentas de redes sociales, por ejemplo Instagram o TikTok. Esto permite que Gathel solicite autorización para acceder automáticamente a publicaciones, historias, reels, videos y demás contenido público o autorizado por el usuario.

Cada jugador inicia con un balance inicial de 100 puntos (pts) dentro de la plataforma.

## Estudiantes:

* Sebastián Aguilar Villalobos, 2025072110
* Xavier Céspedes Alvarado, 2025102887
* Andrés Campos Montero, 2025069367

## Objetivo del proyecto

Diseñar una base de datos que cumpla con lo solicitado por el profesor y un MVP funcional para Gathel.

El proyecto contempla el diseño del modelo de datos, documentación técnica, migraciones con Flyway, scripts de seeding, laboratorios de seguridad, pruebas de transacciones y concurrencia, además de una aplicación mínima con frontend, backend y REST API.

## Guía del proyecto (Documentación)

La documentación del proyecto se organiza en las siguientes áreas:

1. **Diseño de base de datos:** especificación en Markdown y diagrama del modelo.
2. **Administración de base de datos:** migraciones Flyway, seeding, scripts SQL y datos iniciales.
3. **Agentes de IA:** agentes utilizados para revisar seguridad, normalización, escalabilidad y economía del modelo.
4. **Laboratorios técnicos:** seguridad, transacciones, concurrencia y live coding.
5. **MVP:** backend, frontend, REST API y ejecución del proyecto.

Archivos principales:

* [Diseño de tablas](BDDdesign/tablas_gathel.md)
* [Investigación de Flyway](docs/flywayResearch.md)
* [Agentes de IA](docs/Agentes%20de%20IA/)
* [Migraciones Flyway](flyway/sql/)
* [Backend](backend/Gathel.Api/)
* [Frontend](frontend/)

## Alcance del MVP

El MVP de Gathel implementa las funcionalidades principales necesarias para demostrar el flujo básico del juego.

Funcionalidades implementadas:

* Login y logout básico.
* Visualización del balance de puntos.
* Visualización del balance de dinero real.
* Visualización de actividad básica del jugador en la pantalla principal.
* Creación de proposiciones para otro jugador.
* Creación de proposiciones sobre sí mismo.
* Creación de Gathel padre y proposiciones hijas candidatas.
* Votación por propuestas candidatas.
* Selección de propuesta ganadora mediante Stored Procedure.
* Pantalla de pendientes para que la persona objetivo acepte o rechace la propuesta ganadora.
* Activación de proposiciones aceptadas.
* Visualización de proposiciones activas disponibles para pronosticar.
* Realización de pronósticos utilizando puntos o dinero real.
* Visualización de resultados e historial de pronósticos.

El flujo avanzado del juego, como selección automática después de 24 horas, cierre de eventos, validación final de resultados, distribución de ganancias y penalizaciones, puede ejecutarse mediante Stored Procedures o scripts SQL directamente en la base de datos.

La integración real con redes sociales e inteligencia artificial no forma parte del MVP funcional. Para efectos de demostración, los eventos externos se representan mediante proposiciones creadas manualmente dentro de la plataforma.

## Estructura del Repositorio

La estructura principal del proyecto es la siguiente:

```txt
Caso-III-bases/
│
└── Gathel/
    │
    ├── README.md
    ├── docker-compose.yml
    │
    ├── BDDdesign/
    │   ├── Diagrama_Gathel.png
    │   └── tablas_gathel.md
    │
    ├── docs/
    │   ├── flywayResearch.md
    │   │
    │   └── Agentes de IA/
    │       ├── financialAgent.md
    │       ├── NormalizationAgent.md
    │       ├── ScalabilityAgent.md
    │       └── SecurityAgent.md
    │
    ├── flyway/
    │   ├── conf/
    │   │   └── flyway.conf
    │   │
    │   └── sql/
    │       ├── V1__create_database.sql
    │       ├── V2__create_tables.sql
    │       ├── V3__seeding.sql
    │       ├── V4__important_changes.sql
    │       ├── V5__permission_tables.sql
    │       ├── V6__register_person_procedure.sql
    │       ├── V7__create_proposition_procedure.sql
    │       ├── V8__create_prediction_procedures.sql
    │       ├── V9__update_money_prediction_balance_validation.sql
    │       ├── V10__gathel_candidate_voting_flow.sql
    │       ├── V11__gathel_candidate_voting_procedures.sql
    │       ├── V12__update_create_proposition_to_voting.sql
    │       ├── V13__update_prediction_procedures_for_better_flow.sql
    │       ├── V14__normalize_generated_proposition_statuses.sql
    │       ├── V15__followers_tables.sql
    │       ├── V16__update_candidate_flow_to_parent_proposition.sql
    │       ├── V17__update_vote_candidate_one_vote_per_parent.sql
    │       └── V18__transactions_and_concurrency.sql
    │
    ├── backend/
    │   └── Gathel.Api/
    │       ├── Controllers/
    │       │   ├── AuthController.cs
    │       │   ├── HealthController.cs
    │       │   ├── NotificationsController.cs
    │       │   ├── PeopleController.cs
    │       │   ├── PredictionsController.cs
    │       │   └── PropositionsController.cs
    │       │
    │       ├── Data/
    │       │   └── GathelDbContext.cs
    │       │
    │       ├── DTOs/
    │       ├── Models/
    │       ├── Services/
    │       ├── Properties/
    │       ├── appsettings.Development.json
    │       ├── appsettings.json
    │       ├── Dockerfile
    │       ├── Gathel.Api.csproj
    │       ├── Gathel.Api.http
    │       └── Program.cs
    │
    └── frontend/
        ├── app/
        ├── components/
        ├── lib/
        ├── public/
        ├── .gitignore
        ├── Dockerfile
        ├── eslint.config.mjs
        ├── package-lock.json
        ├── package.json
        ├── postcss.config.mjs
        ├── README.md
        └── tsconfig.json
```

## Agentes Implementados

Los agentes utilizados para la revisión de la base de datos fueron:

financial, normalization, scalability y security

Estos agentes fueron utilizados en ChatGPT, los archivos de estos contienen las instrucciones relacionadas a cada área, por ejemplo, el de security tiene la instrucción de revisar solamente aspectos relacionados a la seguridad del sistema.

Cada agente revisó el diseño de la base de datos en cuanto al área requerida, y detectó posibles problemas o recomendaciones que mejorarían el proyecto. Estos cambios fueron aplicados en el diseño.

Las respuestas/recomendaciones brindadas por los agentes pueden ser revisadas en la carpeta de docs dentro del proyecto Gathel.

## Tecnologías utilizadas

| Área                 | Tecnología                           |
| -------------------- | ------------------------------------ |
| Base de datos        | SQL Server                           |
| Migraciones          | Flyway                               |
| Backend              | C# / ASP.NET Core Web API            |
| ORM                  | Entity Framework Core                |
| Frontend             | Next.js / React / TypeScript         |
| Interfaz             | Tailwind CSS / HeroUI / Lucide React |
| Contenedores         | Docker / Docker Compose              |
| Diagramas            | Diagramador de SQL Server / DBML     |
| Control de versiones | Git / GitHub                         |

## Migraciones Flyway

Todas las modificaciones oficiales de la base de datos se administran mediante Flyway.

Para este proyecto, Flyway se ejecuta mediante Docker Compose, por lo que no es necesario instalar Flyway manualmente en cada computadora.

Flyway se encarga de ejecutar los scripts SQL versionados y registrar cuáles migraciones ya fueron aplicadas dentro de la tabla interna `flyway_schema_history`.

Accede a la guía aquí para entender mejor lo que se hizo: [Investigación de Flyway](docs/flywayResearch.md)

## Seeding

El script de seeding genera como mínimo:

* 1000 jugadores.
* 5000 proposiciones.
* 250000 eventos asociados a proposiciones.
* Registros de pagos correspondientes a las 5000 proposiciones.

El seeding se implementa mediante bucles en SQL Server, evitando inserts exhaustivos escritos manualmente.

También garantiza:

* Integridad referencial.
* Timestamps coherentes.
* Datos realistas.
* Relaciones válidas entre jugadores, proposiciones, predicciones, pagos y resultados.

## Ejecución del proyecto

El proyecto utiliza Docker Compose para levantar los servicios necesarios del MVP:

* SQL Server.
* Flyway para ejecutar migraciones.
* Backend ASP.NET Core Web API.
* Frontend Next.js.

### Requisitos previos

* Git.
* Docker Desktop.
* SQL Server Management Studio.
* Visual Studio Code o editor equivalente.

No es necesario instalar Flyway manualmente, ya que se ejecuta mediante Docker Compose.

Tampoco es necesario levantar manualmente el backend ni el frontend para la ejecución principal del MVP, ya que ambos servicios están incluidos en `docker-compose.yml`.

### Levantar el proyecto completo

Desde la raíz del proyecto, donde se encuentra el archivo `docker-compose.yml`, ejecutar:

```powershell
$env:COMPOSE_BAKE="false"
$env:DOCKER_BUILDKIT="0"
docker compose up --build
```
Este comando construye y levanta los contenedores del backend, frontend, SQL Server y Flyway.

Una vez levantados los servicios, se puede acceder a:

```txt
Frontend: http://localhost:3000
Backend Swagger: http://localhost:5145/swagger
SQL Server: localhost,1433
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

### Limpiar contenedores y volumen de base de datos

Si se desea reiniciar completamente el ambiente, incluyendo la base de datos, ejecutar:

```bash
docker compose down -v
```

Luego volver a levantar el proyecto:

```bash
docker compose up --build
```

## Estado actual del proyecto

| Fase                                      | Estado                   |
| ----------------------------------------- | ------------------------ |
| Repositorio inicial                       | Completado               |
| README inicial                            | Actualizado              |
| Docker Compose con SQL Server             | Configurado              |
| Docker Compose con Flyway                 | Configurado              |
| Docker Compose con backend                | Configurado              |
| Docker Compose con frontend               | Configurado              |
| Configuración `flyway.conf`               | Configurado              |
| Scripts SQL principales                   | Implementado             |
| Stored Procedures principales             | Implementado             |
| Seeding inicial                           | Implementado / en ajuste |
| Especificación Markdown de base de datos  | Completado               |
| DBML                                      | Completado               |
| Diagrama PDF                              | Completado               |
| Backend MVP                               | Implementado             |
| Frontend MVP                              | Implementado             |
| REST API                                  | Implementado             |
| Login y logout                            | Implementado             |
| Dashboard con balance de puntos y dinero  | Implementado             |
| Creación de proposiciones                 | Implementado             |
| Votación de propuestas candidatas         | Implementado             |
| Aceptación o rechazo por persona objetivo | Implementado             |
| Pronósticos con puntos o dinero real      | Implementado             |
| Pantalla de resultados                    | Implementado             |
| Scripts SQL de apoyo para demostración    | En progreso              |

## Flujo principal implementado en el MVP

El flujo principal del MVP funciona de la siguiente manera:

```md
1. Un usuario inicia sesión en Gathel.
2. El usuario visualiza su balance de puntos, balance de dinero real y actividad básica.
3. El usuario puede crear un Gathel para sí mismo o para otro jugador.
4. Otros usuarios pueden agregar propuestas candidatas relacionadas con ese Gathel.
5. Los jugadores votan por la propuesta candidata que consideran más interesante o probable.
6. Después de 24 horas, se puede ejecutar un Stored Procedure para seleccionar la propuesta ganadora.
7. La propuesta ganadora pasa al estado `PendingApproval`.
8. La persona objetivo puede aceptar o rechazar la propuesta desde la pantalla de pendientes.
9. Si la rechaza, la proposición se cierra y no se habilitan predicciones.
10. Si la acepta, define las fechas de predicción y la proposición pasa al estado `Active`.
11. Otros jugadores pueden realizar pronósticos utilizando puntos o dinero real.
12. Los resultados e historial de pronósticos pueden visualizarse desde la pantalla de resultados.
```

Algunos pasos internos del flujo se ejecutan mediante Stored Procedures o scripts SQL, lo cual se mantiene dentro del alcance permitido para el MVP.
