# Docker y despliegue local del proyecto

Este proyecto utiliza Docker Compose para levantar de forma coordinada los servicios necesarios del MVP de Gathel. La configuración permite ejecutar la base de datos, las migraciones, el backend y el frontend con un solo comando, reduciendo problemas de instalación manual y diferencias entre ambientes.

## Servicios incluidos

El archivo `docker-compose.yml` define los siguientes servicios:

### SQL Server

El servicio de SQL Server utiliza la imagen oficial de Microsoft SQL Server 2022. Este contenedor aloja la base de datos principal del sistema, llamada `GathelDB`.

La base de datos se expone en el puerto `1433`, lo que permite conectarse desde SQL Server Management Studio usando:

```txt
Servidor: localhost,1433
Usuario: sa
Contraseña: Gathel123!
```

También se define un volumen persistente para conservar los datos mientras el contenedor no sea eliminado con `docker compose down -v`.

### Flyway

Flyway se utiliza para ejecutar las migraciones de base de datos de forma ordenada y reproducible. Este servicio espera a que SQL Server esté saludable antes de ejecutar los scripts ubicados en la carpeta de migraciones.

Las migraciones permiten crear la base de datos, las tablas, datos iniciales, Stored Procedures y otros objetos necesarios para el funcionamiento del sistema.

### Backend ASP.NET Core

El backend se ejecuta como una API REST desarrollada con ASP.NET Core. Este servicio depende de SQL Server y de Flyway, por lo que se levanta después de que la base de datos esté disponible y las migraciones hayan sido ejecutadas.

El backend se expone en:

```txt
http://localhost:5145
```

También se puede acceder a Swagger en:

```txt
http://localhost:5145/swagger
```

### Frontend Next.js

El frontend se ejecuta como una aplicación Next.js. Este servicio consume la API del backend mediante la variable de entorno:

```txt
NEXT_PUBLIC_API_URL=http://localhost:5145
```

El frontend se expone en:

```txt
http://localhost:3000
```

## Flujo de inicialización

El orden esperado de ejecución es:

```txt
1. SQL Server inicia.
2. Docker verifica que SQL Server esté saludable.
3. Flyway ejecuta las migraciones.
4. Backend inicia y se conecta a GathelDB.
5. Frontend inicia y consume la API del backend.
```

Este orden garantiza que la aplicación no intente conectarse a una base de datos incompleta o sin migraciones aplicadas.

## Comando principal de ejecución

Desde la raíz del proyecto se ejecuta:

```powershell
$env:COMPOSE_BAKE="false"
$env:DOCKER_BUILDKIT="0"
docker compose up --build
```

Las variables `COMPOSE_BAKE` y `DOCKER_BUILDKIT` se desactivan para evitar problemas de construcción en ciertos entornos de Windows, especialmente cuando el proyecto se encuentra en rutas con espacios o dentro de OneDrive.

## Verificación de migraciones

Una vez levantado el ambiente, se puede verificar el historial de Flyway con:

```sql
USE GathelDB;
GO

SELECT *
FROM flyway_schema_history;
GO
```

Esta tabla permite confirmar qué migraciones fueron aplicadas correctamente.

## Ventajas de usar Docker en este proyecto

El uso de Docker aporta las siguientes ventajas:

* Reduce la configuración manual del ambiente.
* Permite levantar todos los servicios con un solo comando.
* Facilita la defensa en vivo del proyecto.
* Asegura que SQL Server, Flyway, backend y frontend trabajen de forma coordinada.
* Permite reiniciar el ambiente desde cero para comprobar que el proyecto es reproducible.
* Mejora la portabilidad del proyecto entre integrantes del equipo y evaluadores.


