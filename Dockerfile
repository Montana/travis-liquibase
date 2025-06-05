FROM eclipse-temurin:21-jre-jammy

# Labels for container metadata
LABEL org.opencontainers.image.title="Liquibase Pro Custom Image" \
      org.opencontainers.image.version="4.32.0" \
      org.opencontainers.image.vendor="Liquibase" \
      org.opencontainers.image.description="Liquibase Pro + LPM with PostgreSQL support" \
      org.opencontainers.image.documentation="https://docs.liquibase.com"

# Create liquibase user and group
RUN groupadd --gid 1001 liquibase && \
    useradd --uid 1001 --gid liquibase --create-home --home-dir /liquibase liquibase

# Set working directory
WORKDIR /liquibase

# Version arguments
ARG LIQUIBASE_VERSION=4.32.0
ARG LB_SHA256=10910d42ae9990c95a4ac8f0a3665a24bd40d08fb264055d78b923a512774d54
ARG LPM_VERSION=0.2.9
ARG LPM_SHA256=b9caecd34c98a6c19a2bc582e8064aff5251c5f1adbcd100d3403c5eceb5373a
ARG LPM_SHA256_ARM=0adb3a96d7384b4da549979bf00217a8914f0df37d1ed8fdb1b4a4baebfa104c

# Install packages and Liquibase - Fixed APT cache handling
RUN set -ex && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /var/cache/apt/*.bin && \
    apt-get clean && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --fix-missing wget unzip ca-certificates && \
    apt-get autoremove -y && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /var/cache/apt/*.bin /tmp/* /var/tmp/* && \
    wget -q https://github.com/liquibase/liquibase/releases/download/v${LIQUIBASE_VERSION}/liquibase-${LIQUIBASE_VERSION}.tar.gz && \
    echo "$LB_SHA256 *liquibase-${LIQUIBASE_VERSION}.tar.gz" | sha256sum -c - && \
    tar -xzf liquibase-${LIQUIBASE_VERSION}.tar.gz && \
    rm liquibase-${LIQUIBASE_VERSION}.tar.gz && \
    ln -s /liquibase/liquibase /usr/local/bin/liquibase

# Install LPM (Liquibase Package Manager)
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then \
        LPM_SHA=$LPM_SHA256; \
    else \
        LPM_SHA=$LPM_SHA256_ARM; \
    fi && \
    wget -q https://github.com/liquibase/liquibase-package-manager/releases/download/v${LPM_VERSION}/lpm-${LPM_VERSION}-linux.zip && \
    echo "$LPM_SHA *lpm-${LPM_VERSION}-linux.zip" | sha256sum -c - && \
    unzip lpm-${LPM_VERSION}-linux.zip && \
    rm lpm-${LPM_VERSION}-linux.zip && \
    chmod +x lpm && \
    ln -s /liquibase/lpm /usr/local/bin/lpm

# PostgreSQL JDBC driver is already included in Liquibase 4.32.0
# No need to download separately to avoid duplicate JARs

# Set up extensions directory
RUN mkdir -p /liquibase/extensions

# Change ownership to liquibase user
RUN chown -R liquibase:liquibase /liquibase

# Switch to liquibase user
USER liquibase

# Environment variables
ENV LIQUIBASE_HOME=/liquibase
ENV PATH="$LIQUIBASE_HOME:$PATH"

# Expose port for Liquibase Hub
EXPOSE 8080

# Default command
ENTRYPOINT ["liquibase"]
CMD ["--help"]
