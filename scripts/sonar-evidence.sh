#!/usr/bin/env bash
#
# sonar-evidence.sh — capture SonarQube UI screenshots into docs/evidence/.
#
# Reads the server URL and admin password from the local credential store
# (KWallet); nothing sensitive is stored in the repo.

set -euo pipefail
cd "$(dirname "$0")/.."

secret() {
  if command -v secret-tool >/dev/null 2>&1; then
    secret-tool lookup "$@" 2>/dev/null || true
  elif command -v distrobox-host-exec >/dev/null 2>&1; then
    distrobox-host-exec secret-tool lookup "$@" 2>/dev/null || true
  fi
}

export SONAR_HOST_URL="${SONAR_HOST_URL:-$(secret service sonarqube item host-url)}"
export SONAR_ADMIN_PASSWORD="${SONAR_ADMIN_PASSWORD:-$(secret service sonarqube item admin-password)}"
export SONAR_PROJECT_KEY="${SONAR_PROJECT_KEY:-hd2-sc-arrow}"
: "${SONAR_HOST_URL:?not set and not in keyring (service=sonarqube item=host-url)}"
: "${SONAR_ADMIN_PASSWORD:?not set and not in keyring (service=sonarqube item=admin-password)}"

node scripts/capture-sonar-evidence.mjs
