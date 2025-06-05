from eclipse-temurin:21-jre-jammy

label org.opencontainers.image.title="Liquibase Pro Custom Image" \
      org.opencontainers.image.version="4.32.0" \
      org.opencontainers.image.vendor="Liquibase" \
      org.opencontainers.image.description="Liquibase Pro + LPM with PostgreSQL support" \
      org.opencontainers.image.documentation="https://docs.liquibase.com"

run groupadd --gid 1001 liquibase && \
    useradd --uid 1001 --gid liquibase --create-home --home-dir /liquibase liquibase

workdir /liquibase

arg liquibase_version=4.32.0
arg lb_sha256=10910d42ae9990c95a4ac8f0a3665a24bd40d08fb264055d78b923a512774d54
arg lpm_version=0.2.9
arg lpm_sha256=b9caecd34c98a6c19a2bc582e8064aff5251c5f1adbcd100d3403c5eceb5373a
arg lpm_sha256_arm=0adb3a96d7384b4da549979bf00217a8914f0df37d1ed8fdb1b4a4baebfa104c

run set -ex && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /var/cache/apt/*.bin && \
    apt-get clean && \
    apt-get update && \
    debian_frontend=noninteractive apt-get install -y --no-install-recommends --fix-missing wget unzip ca-certificates && \
    apt-get autoremove -y && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /var/cache/apt/*.bin /tmp/* /var/tmp/* && \
    wget -q https://github.com/liquibase/liquibase/releases/download/v${liquibase_version}/liquibase-${liquibase_version}.tar.gz && \
    echo "$lb_sha256 *liquibase-${liquibase_version}.tar.gz" | sha256sum -c - && \
    tar -xzf liquibase-${liquibase_version}.tar.gz && \
    rm liquibase-${liquibase_version}.tar.gz && \
    ln -s /liquibase/liquibase /usr/local/bin/liquibase

run arch=$(dpkg --print-architecture) && \
    if [ "$arch" = "amd64" ]; then \
        lpm_sha=$lpm_sha256; \
    else \
        lpm_sha=$lpm_sha256_arm; \
    fi && \
    wget -q https://github.com/liquibase/liquibase-package-manager/releases/download/v${lpm_version}/lpm-${lpm_version}-linux.zip && \
    echo "$lpm_sha *lpm-${lpm_version}-linux.zip" | sha256sum -c - && \
    unzip lpm-${lpm_version}-linux.zip && \
    rm lpm-${lpm_version}-linux.zip && \
    chmod +x lpm && \
    ln -s /liquibase/lpm /usr/local/bin/lpm

run mkdir -p /liquibase/extensions
run chown -r liquibase:liquibase /liquibase

user liquibase

env liquibase_home=/liquibase
env path="$liquibase_home:$path"

expose 8080

entrypoint ["liquibase"]
cmd ["--help"]
