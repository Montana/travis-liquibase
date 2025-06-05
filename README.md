# Travis CI + Liquibase Pro

![Liquibase](https://github.com/user-attachments/assets/710ceb2e-3a92-4251-b252-6e2254e4e52f)

This project builds a custom Docker image for Liquibase Pro version 4.32.0, including Liquibase Package Manager (LPM) and support for PostgreSQL migrations.

## Features

- Liquibase Pro 4.32.0
- LPM 0.2.9
- PostgreSQL JDBC support
- Based on Eclipse Temurin JDK 21
- SHA256 verification for all binaries

## Build the Image

Build the Docker image by running: 

```bash
docker build -t liquibase-pro:4.32.0 .
```
## Use with Liquibase Package Manager (LPM)

LPM is included:

```
docker run --rm liquibase-pro:4.32.0 lpm list
```
## Optional: Run PostgreSQL Locally

Start a PostgreSQL database in Docker:

```bash
docker run -d \
  --name pgdb \
  -e POSTGRES_DB=liquibasedb \
  -e POSTGRES_USER=liquibase \
  -e POSTGRES_PASSWORD=secret \
  -p 5432:5432 \
  postgres:14
```
