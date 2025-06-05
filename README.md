# Travis CI + Liquibase Pro

![Liquibase](https://github.com/user-attachments/assets/710ceb2e-3a92-4251-b252-6e2254e4e52f)

This project builds a custom Docker image for Liquibase Pro version 4.32.0, including Liquibase Package Manager (LPM) and comprehensive support for PostgreSQL database migrations whilst The image is designed for production use with enterprise-grade features and security considerations.

## Features

* **Liquibase Pro 4.32.0** - Latest professional version with advanced features
* **Liquibase Package Manager (LPM) 0.2.9** - Integrated package management for extensions
* **PostgreSQL JDBC Driver** - Full support for PostgreSQL database operations
* **Eclipse Temurin JDK 21** - Modern, secure Java runtime environment
* **SHA256 Verification** - All binaries are cryptographically verified for security
* **Multi-architecture Support** - Compatible with x86_64 and ARM64 platforms
* **Optimized Layer Caching** - Efficient Docker builds with minimal layer changes
* **CI/CD Pipeline** - Automated testing across multiple PostgreSQL versions
* **Rollback Testing** - Automated verification of database rollback operations
* **BuildKit Support** - Faster and more efficient Docker builds

## PostgreSQL Versions

The project is tested against multiple PostgreSQL versions to ensure compatibility:

| Version | Docker Image | Status | Notes |
|---------|--------------|--------|-------|
| 15 | postgres:15-alpine | Primary | Latest stable version, recommended for production |
| 14 | postgres:14-alpine | Supported | Previous stable version |
| 13 | postgres:13-alpine | Supported | Legacy version support |

Each version is tested in the CI/CD pipeline to ensure compatibility with Liquibase operations.

### Version Details

| Version | Release Date | EOL Date | Key Features | Size (Alpine) |
|---------|--------------|----------|--------------|---------------|
| 15 | Oct 2023 | Nov 2028 | - Logical replication improvements<br>- MERGE command<br>- Enhanced JSON support<br>- Better performance | ~200MB |
| 14 | Sep 2021 | Nov 2026 | - Multirange types<br>- Extended statistics<br>- Improved connection handling | ~190MB |
| 13 | Sep 2020 | Nov 2025 | - Improved indexing<br>- Better vacuuming<br>- Enhanced monitoring | ~180MB |

Note: All versions use the Alpine-based Docker images for minimal size and security. The size column shows approximate compressed image sizes.

## Continuous Integration

The project uses Travis CI.

### Matrix Testing
- Tests against PostgreSQL 13, 14, and 15
- Parallel test execution for faster feedback
- Automated rollback testing
- Database inspection and validation

### Build Pipeline Stages
1. **Build and Test**
   - Docker image build
   - Basic connectivity tests
   - Changelog validation

2. **Extended Tests**
   - Multi-version PostgreSQL testing
   - Rollback verification
   - Database structure validation

3. **Deploy** (master branch only)
   - Production deployment
   - Automated tagging
   - Change tracking

## Build the Image

Build the Docker image by running: 

```bash
docker build -t liquibase-pro:4.32.0 .
```

For multi-platform builds with BuildKit:

```bash
DOCKER_BUILDKIT=1 docker build --build-arg BUILDKIT_INLINE_CACHE=1 -t liquibase-pro:4.32.0 .
```

## Use with Liquibase Package Manager (LPM)

LPM is included:

```bash
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
  postgres:15-alpine
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

LPM is a powerful package management tool included with Liquibase Pro that helps manage extensions, drivers, and additional functionality.

### What is LPM?

LPM is a command-line tool that:
- Manages Liquibase extensions and plugins
- Handles database driver installations
- Updates Liquibase components
- Manages dependencies between packages

### Available Packages

| Package | Description | Use Case |
|---------|-------------|-----------|
| `oracle` | Oracle Database driver | Oracle database migrations |
| `mysql` | MySQL/MariaDB driver | MySQL database migrations |
| `mssql` | Microsoft SQL Server driver | SQL Server migrations |
| `db2` | IBM DB2 driver | DB2 database migrations |
| `snowflake` | Snowflake driver | Snowflake data warehouse migrations |
| `diff` | Database diff tool | Compare database schemas |
| `pro` | Pro features | Advanced Liquibase Pro features |

### Common LPM Commands

```bash
docker run --rm liquibase-pro:4.32.0 lpm list
docker run --rm liquibase-pro:4.32.0 lpm install <package-name>
docker run --rm liquibase-pro:4.32.0 lpm update
docker run --rm liquibase-pro:4.32.0 lpm show
docker run --rm liquibase-pro:4.32.0 lpm remove <package-name>
```

### Package Management Best Practices

1. **Version Control**
   - Keep track of installed packages in your project
   - Document package versions in your README
   - Use specific versions for production

2. **Security**
   - Only install packages from trusted sources
   - Regularly update packages for security patches
   - Review package permissions

3. **Performance**
   - Install only required packages
   - Remove unused packages
   - Use Alpine-based images for smaller footprint

### Example: Setting Up a New Project

```bash
docker run --rm liquibase-pro:4.32.0 lpm install postgresql
docker run --rm liquibase-pro:4.32.0 lpm install mysql
docker run --rm liquibase-pro:4.32.0 lpm install diff
docker run --rm liquibase-pro:4.32.0 lpm show
```

### Troubleshooting LPM

Common issues and solutions:

| Issue | Solution |
|-------|----------|
| Package not found | Check package name and availability |
| Installation fails | Verify network connectivity and permissions |
| Version conflicts | Use `lpm update` to resolve conflicts |
| Permission denied | Run with appropriate user permissions |

For more information, visit the [Liquibase Package Manager documentation](https://docs.liquibase.com/tools-integrations/lpm/overview.html).

## Liquibase and Extensions

### What is Liquibase?

Liquibase is an open-source database-independent library for tracking, managing, and applying database schema changes. It provides:

- **Version Control for Databases**: Track all database changes in version control
- **Database Refactoring**: Safe and repeatable database refactoring
- **Multiple Database Support**: Works with all major databases
- **Change Tracking**: Maintains a record of all database changes
- **Rollback Support**: Ability to roll back changes when needed

### Key Liquibase Concepts

| Concept | Description | Example |
|---------|-------------|---------|
| ChangeSet | Atomic unit of database change | Creating a table, adding a column |
| Changelog | Ordered list of changesets | XML, YAML, or SQL file |
| Context | Logical grouping of changesets | dev, test, prod |
| Labels | Filtering mechanism for changesets | feature-x, bugfix-y |
| Preconditions | Conditions for changeset execution | tableExists, onFail |

### Liquibase Extensions

Liquibase supports various types of extensions:

1. **Custom Change Types**
   - Create reusable database changes
   - Share changes across projects
   - Maintain consistency

2. **Extension Points**
   - Custom preconditions
   - Custom validators
   - Custom reporters

3. **Integration Features**
   - Database-specific optimizations
   - Custom SQL generators
   - Extended rollback support

### Using Extensions

```bash
docker run --rm liquibase-pro:4.32.0 lpm list
docker run --rm liquibase-pro:4.32.0 lpm install <extension-name>
```

### Common Extensions

| Extension | Purpose | Use Case |
|-----------|---------|-----------|
| `postgresql` | PostgreSQL-specific features | PostgreSQL database support |
| `mysql` | MySQL-specific features | MySQL database support |
| `oracle` | Oracle-specific features | Oracle database support |
| `mssql` | SQL Server features | SQL Server database support |

### Best Practices

1. **Extension Management**
   - Version control your changes
   - Document dependencies
   - Test changes thoroughly

2. **Performance**
   - Use database-specific optimizations
   - Minimize change overhead
   - Cache when appropriate

3. **Security**
   - Validate change sources
   - Review change code
   - Use trusted repositories

### Example: Custom Change

```xml
<changeSet id="custom-change-example" author="travis">
    <customChange class="com.example.CustomChange">
        <property name="tableName" value="users"/>
        <property name="columnName" value="status"/>
    </customChange>
</changeSet>
```

### Troubleshooting

| Issue | Solution |
|-------|----------|
| Change not found | Check change name and availability |
| Version conflict | Update or adjust version |
| Performance issues | Review implementation |
| Integration errors | Check compatibility |

For more information, visit the [Liquibase Documentation](https://docs.liquibase.com).

## Docker Buildx (Bake) with Liquibase

Docker Buildx (bake) provides advanced build capabilities for creating multi-platform Docker images. Here's how to use it with Liquibase:

### Basic Bake Configuration

Create a `docker-bake.hcl` file:

```hcl
variable "LIQUIBASE_VERSION" {
  default = "4.32.0"
}

group "default" {
  targets = ["liquibase-pro"]
}

target "liquibase-pro" {
  context = "."
  dockerfile = "Dockerfile"
  tags = ["liquibase-pro:${LIQUIBASE_VERSION}"]
  platforms = ["linux/amd64", "linux/arm64"]
  args = {
    LIQUIBASE_VERSION = "${LIQUIBASE_VERSION}"
  }
}
```

### Building with Bake

```bash
docker buildx bake
docker buildx bake --set *.platform=linux/amd64
docker buildx bake --set *.args.LIQUIBASE_VERSION=4.32.0
```

### Advanced Bake Configuration

```hcl
variable "LIQUIBASE_VERSION" {
  default = "4.32.0"
}

variable "POSTGRES_VERSION" {
  default = "15-alpine"
}

group "default" {
  targets = ["liquibase-pro", "postgres"]
}

target "liquibase-pro" {
  context = "."
  dockerfile = "Dockerfile"
  tags = [
    "liquibase-pro:${LIQUIBASE_VERSION}",
    "liquibase-pro:latest"
  ]
  platforms = ["linux/amd64", "linux/arm64"]
  args = {
    LIQUIBASE_VERSION = "${LIQUIBASE_VERSION}"
  }
  cache-from = ["type=registry,ref=liquibase-pro:buildcache"]
  cache-to = ["type=registry,ref=liquibase-pro:buildcache,mode=max"]
}

target "postgres" {
  context = "."
  dockerfile = "Dockerfile.postgres"
  tags = ["postgres:${POSTGRES_VERSION}"]
  platforms = ["linux/amd64", "linux/arm64"]
  args = {
    POSTGRES_VERSION = "${POSTGRES_VERSION}"
  }
}
```

### Build Features

| Feature | Description | Use Case |
|---------|-------------|-----------|
| Multi-platform | Build for multiple architectures | Cross-platform deployment |
| Caching | Efficient layer caching | Faster builds |
| Parallel builds | Build multiple targets | CI/CD pipelines |
| Variable substitution | Dynamic configuration | Version management |

### Best Practices

1. **Caching**
   ```hcl
   cache-from = ["type=registry,ref=liquibase-pro:buildcache"]
   cache-to = ["type=registry,ref=liquibase-pro:buildcache,mode=max"]
   ```

2. **Platform Selection**
   ```hcl
   platforms = ["linux/amd64", "linux/arm64"]
   ```

3. **Version Management**
   ```hcl
   variable "LIQUIBASE_VERSION" {
     default = "4.32.0"
   }
   ```

### CI/CD Integration

Add to your `.travis.yml`:

```yaml
before_install:
  - docker buildx create --use
  - docker buildx inspect --bootstrap

script:
  - docker buildx bake
```

### Troubleshooting

| Issue | Solution |
|-------|----------|
| Platform not supported | Check Docker buildx platform support |
| Cache issues | Clear buildx cache |
| Build failures | Check platform compatibility |
| Registry errors | Verify registry credentials |

## Author

Michael Mendy (c) 2025.
