# Travis CI + Liquibase Pro

![Liquibase](https://github.com/user-attachments/assets/710ceb2e-3a92-4251-b252-6e2254e4e52f)

This project builds a custom Docker image for Liquibase Pro version 4.32.0, including Liquibase Package Manager (LPM) and comprehensive support for PostgreSQL database migrations. The image is designed for production use with enterprise-grade features and security considerations.

## Features

* **Liquibase Pro 4.32.0** - Latest professional version with advanced features
* **Liquibase Package Manager (LPM) 0.2.9** - Integrated package management for extensions
* **PostgreSQL JDBC Driver** - Full support for PostgreSQL database operations
* **Eclipse Temurin JDK 21** - Modern, secure Java runtime environment
* **SHA256 Verification** - All binaries are cryptographically verified for security
* **Multi-architecture Support** - Compatible with x86_64 and ARM64 platforms
* **Optimized Layer Caching** - Efficient Docker builds with minimal layer changes

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

For multi-platform builds:

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t liquibase-pro:4.32.0 .
```

### Verify Installation

Check the Liquibase version:

```bash
docker run --rm liquibase-pro:4.32.0 liquibase --version
```

## Usage Examples

Run a database update with your changelog:

```bash
docker run --rm \
  -v $(pwd)/changelogs:/liquibase/changelog \
  -v $(pwd)/liquibase.properties:/liquibase/liquibase.properties \
  liquibase-pro:4.32.0 \
  liquibase update
```

### Generate Changelog from Existing Database

Create a changelog from your current database schema:

```bash
docker run --rm \
  -v $(pwd)/output:/liquibase/output \
  liquibase-pro:4.32.0 \
  liquibase generate-changelog \
  --changelog-file=output/db-changelog.xml \
  --url=jdbc:postgresql://host.docker.internal:5432/mydb \
  --username=myuser \
  --password=mypass
```

### Rollback Operations

Rollback the last 3 changesets:

```bash
docker run --rm \
  -v $(pwd)/changelogs:/liquibase/changelog \
  liquibase-pro:4.32.0 \
  liquibase rollback-count 3 \
  --changelog-file=changelog/db-changelog.xml \
  --url=jdbc:postgresql://localhost:5432/mydb \
  --username=myuser \
  --password=mypass
```

## Liquibase Package Manager (LPM)

LPM is included for managing Liquibase extensions and additional database drivers.

### List Available Packages

```bash
docker run --rm liquibase-pro:4.32.0 lpm list
```

### Install Additional Database Drivers

```bash
# Install Oracle driver
docker run --rm liquibase-pro:4.32.0 lpm install oracle

# Install MySQL driver
docker run --rm liquibase-pro:4.32.0 lpm install mysql
```

### Update Package Repository

```bash
docker run --rm liquibase-pro:4.32.0 lpm update
```

### PostgreSQL (Recommended for Development)

Start a PostgreSQL database container for testing:

```bash
docker run -d \
  --name pgdb \
  -e POSTGRES_DB=liquibasedb \
  -e POSTGRES_USER=liquibase \
  -e POSTGRES_PASSWORD=secret \
  -p 5432:5432 \
  postgres:14
```

Create a docker-compose setup for integrated development (not required): 

```yaml
version: '3.8'
services:
  postgres:
    image: postgres:14
    environment:
      POSTGRES_DB: liquibasedb
      POSTGRES_USER: liquibase
      POSTGRES_PASSWORD: secret
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  liquibase:
    image: liquibase-pro:4.32.0
    depends_on:
      - postgres
    volumes:
      - ./changelogs:/liquibase/changelog
      - ./liquibase.properties:/liquibase/liquibase.properties
    command: liquibase update

volumes:
  postgres_data:
```

### Environment Variables

The image supports the following environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `LIQUIBASE_COMMAND_URL` | Database JDBC URL | - |
| `LIQUIBASE_COMMAND_USERNAME` | Database username | - |
| `LIQUIBASE_COMMAND_PASSWORD` | Database password | - |
| `LIQUIBASE_COMMAND_CHANGELOG_FILE` | Path to changelog file | `changelog.xml` |
| `LIQUIBASE_LOG_LEVEL` | Logging level | `INFO` |
| `LIQUIBASE_PRO_LICENSE_KEY` | Liquibase Pro license key | - |

### Properties File

Create a `liquibase.properties` file for consistent configuration:

```properties
# Database connection
url=jdbc:postgresql://localhost:5432/liquibasedb
username=liquibase
password=secret

# Changelog configuration
changeLogFile=changelog/db-changelog.xml

# Liquibase Pro license
liquibase.pro.licenseKey=YOUR_LICENSE_KEY_HERE

# Logging
logLevel=INFO
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Database Migration
on:
  push:
    branches: [main]

jobs:
  migrate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Liquibase Update
        run: |
          docker run --rm \
            -v ${{ github.workspace }}/db:/liquibase/changelog \
            -e LIQUIBASE_COMMAND_URL=${{ secrets.DB_URL }} \
            -e LIQUIBASE_COMMAND_USERNAME=${{ secrets.DB_USER }} \
            -e LIQUIBASE_COMMAND_PASSWORD=${{ secrets.DB_PASS }} \
            liquibase-pro:4.32.0 \
            liquibase update
```

## Author

Michael Mendy (c) 2025.
