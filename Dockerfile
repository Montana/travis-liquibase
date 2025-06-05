# Use lightweight Java 21 base
FROM eclipse-temurin:21-jre-jammy

# Metadata
LABEL org.opencontainers.image.title="Liquibase Pro Custom Image" \
      org.opencontainers.image.version="4.32.0" \
      org.opencontainers.image.vendor="Liquibase" \
      org.opencontainers.image.description="Liquibase Pro + LPM with PostgreSQL support" \
      org.opencontainers.image.documentation="https://docs.liquibase.com"

# Create liquibase user
RUN groupadd --gid 1001 liquibase && \
    useradd --uid 1001 --gid liquibase --create-home --home-dir /liquibase liquibase

WORKDIR /liquibase

# Liquibase version and checksum
ARG LIQUIBASE_VERSION=4.32.0
ARG LB_SHA256=10910d42ae9990c95a4ac8f0a3665a24bd40d08fb264055d78b923a512774d54

# Download and install Liquibase CLI
RUN apt-get update && apt-get install -y wget unzip && \
    wget -q https://github.com/liquibase/liquibase/releases/download/v${LIQUIBASE_VERSION}/liquibase-${LIQUIBASE_VERSION}.tar.gz && \
    echo "$LB_SHA256 *liquibase-${LIQUIBASE_VERSION}.tar.gz" | sha256sum -c - && \
    tar -xzf liquibase-${LIQUIBASE_VERSION}.tar.gz && \
    rm liquibase-${LIQUIBASE_VERSION}.tar.gz && \
    ln -s /liquibase/liquibase /usr/local/bin/liquibase

# Liquibase Package Manager
ARG LPM_VERSION=0.2.9
ARG LPM_SHA256=b9caecd34c98a6c19a2bc582e8064aff5251c5f1adbcd100d3403c5eceb5373a
ARG LPM_SHA256_ARM=0adb3a96d7384b4da549979bf00217a8914f0df37d1ed8fdb1b4a4baebfa104c

RUN mkdir /liquibase/bin && \
    arch="$(dpkg --print-architecture)" && \
    case "$arch" in \
      amd64) DOWNLOAD_ARCH="" && FINAL_SHA=$LPM_SHA256 ;; \
      arm64) DOWNLOAD_ARCH="-arm64" && FINAL_SHA=$LPM_SHA256_ARM ;; \
      *) echo "Unsupported architecture: $arch" && exit 1 ;; \
    esac && \
    wget -q -O lpm-${LPM_VERSION}.zip https://github.com/liquibase/liquibase-package-manager/releases/download/v${LPM_VERSION}/lpm-${LPM_VERSION}-linux${DOWNLOAD_ARCH}.zip && \
    echo "$FINAL_SHA *lpm-${LPM_VERSION}.zip" | sha256sum -c - && \
    unzip lpm-${LPM_VERSION}.zip -d /liquibase/bin && \
    rm lpm-${LPM_VERSION}.zip && \
    ln -s /liquibase/bin/lpm /usr/local/bin/lpm && \
    lpm --version

# Add entrypoint and changelog for testing
COPY docker-entrypoint.sh /liquibase/docker-entrypoint.sh
COPY liquibase.docker.properties /liquibase/liquibase.properties
COPY changelog.xml /liquibase/changelog.xml

# Ensure scripts are executable
RUN chmod +x /liquibase/docker-entrypoint.sh

# Environment
ENV LIQUIBASE_HOME=/liquibase
ENV DOCKER_LIQUIBASE=true

# Switch to non-root liquibase user
USER liquibase:liquibase

ENTRYPOINT ["/liquibase/docker-entrypoint.sh"]
CMD ["--help"]
