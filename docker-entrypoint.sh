#!/bin/bash
set -e

check_required_vars() {
    local missing_vars=()
    if [ -z "$LIQUIBASE_COMMAND_URL" ]; then
        missing_vars+=("LIQUIBASE_COMMAND_URL")
    fi
    if [ -z "$LIQUIBASE_COMMAND_USERNAME" ]; then
        missing_vars+=("LIQUIBASE_COMMAND_USERNAME")
    fi
    if [ -z "$LIQUIBASE_COMMAND_PASSWORD" ]; then
        missing_vars+=("LIQUIBASE_COMMAND_PASSWORD")
    fi
    if [ ${#missing_vars[@]} -ne 0 ]; then
        echo "Error: Missing required environment variables: ${missing_vars[*]}"
        exit 1
    fi
}

check_db_connection() {
    local max_attempts=30
    local attempt=1
    local wait_seconds=2
    echo "Checking database connectivity..."
    while [ $attempt -le $max_attempts ]; do
        if liquibase --url="$LIQUIBASE_COMMAND_URL" --username="$LIQUIBASE_COMMAND_USERNAME" --password="$LIQUIBASE_COMMAND_PASSWORD" status >/dev/null 2>&1; then
            echo "Database connection successful"
            return 0
        fi
        echo "Attempt $attempt of $max_attempts: Database not ready, waiting ${wait_seconds}s..."
        sleep $wait_seconds
        attempt=$((attempt + 1))
    done
    echo "Error: Could not connect to database after $max_attempts attempts"
    exit 1
}

validate_changelog() {
    if [ -n "$LIQUIBASE_COMMAND_CHANGELOG_FILE" ]; then
        if [ ! -f "$LIQUIBASE_COMMAND_CHANGELOG_FILE" ]; then
            echo "Error: Changelog file not found: $LIQUIBASE_COMMAND_CHANGELOG_FILE"
            exit 1
        fi
    fi
}

set_defaults() {
    : ${LIQUIBASE_LOG_LEVEL:=INFO}
    : ${LIQUIBASE_COMMAND_CHANGELOG_FILE:=changelog.xml}
}

handle_signal() {
    echo "Received signal, cleaning up..."
    exit 0
}

trap handle_signal SIGTERM SIGINT

main() {
    set_defaults
    if [ "$1" = "healthcheck" ]; then
        check_db_connection
        exit 0
    fi
    if [ "$1" != "--version" ] && [ "$1" != "version" ]; then
        check_required_vars
        validate_changelog
        check_db_connection
    fi
    echo "Executing: liquibase $*"
    exec liquibase "$@"
}

main "$@"
