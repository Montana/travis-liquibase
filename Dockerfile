FROM eclipse-temurin:21-jre-jammy

LABEL org.opencontainers.image.title="Liquibase Pro Custom Image" \
      org.opencontainers.image.version="4.32.0" \
      org.opencontainers.image.vendor="Liquibase" \
      org.opencontainers.image.description="Liquibase Pro + LPM with PostgreSQL support" \
      org.opencontainers.image.documentation="https://docs.liquibase.com"

RUN groupadd --gid 1001 liquibase && \
    useradd --uid 1001 --gid liquibase --create-home --home-dir /liquibase liquibase

WORKDIR /liquibase

ARG LIQUIBASE_VERSION=4.32.0
ARG LB_SHA256=10910d42ae9990c95a4ac8f0a3665a24bd40d08fb264055d78b923a512774d54
ARG LPM_VERSION=0.2.9
ARG LPM_SHA256=...
ARG LPM_SHA256_ARM=...

RUN set -eux; \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        wget unzip ca-certificates && \
    wget -q https://github.com/liquibase/liquibase/releases/download/v${LIQUIBASE_VERSION}/liquibase-${LIQUIBASE_VERSION}.tar.gz && \
    echo "$LB_SHA256 *liquibase-${LIQUIBASE_VERSION}.tar.gz" | sha256sum -c - && \
    tar -xzf liquibase-${LIQUIBASE_VERSION}.tar.gz && \
    rm liquibase-${LIQUIBASE_VERSION}.tar.gz && \
    ln -s /liquibase/liquibase /usr/local/bin/liquibase && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN set -eux; \
    ARCH=$(dpkg --print-architecture); \
    LPM_SHA="$([ "$ARCH" = "amd64" ] && echo $LPM_SHA256 || echo $LPM_SHA256_ARM)"; \
    wget -q https://github.com/liquibase/liquibase-package-manager/releases/download/v${LPM_VERSION}/lpm-${LPM_VERSION}-linux.zip && \
    echo "$LPM_SHA *lpm-${LPM_VERSION}-linux.zip" | sha256sum -c - && \
    unzip lpm-${LPM_VERSION}-linux.zip && \
    rm lpm-${LPM_VERSION}-linux.zip && \
    chmod +x lpm && \
    ln -s /liquibase/lpm /usr/local/bin/lpm

RUN mkdir -p /liquibase/extensions && \
    chown -R liquibase:liquibase /liquibase

USER liquibase

ENV LIQUIBASE_HOME=/liquibase
ENV PATH="$LIQUIBASE_HOME:$PATH"

EXPOSE 8080

ENTRYPOINT ["liquibase"]
CMD ["--help"]

