#!/usr/bin/env bash
#
# sonar.sh — analyse this project with SonarQube, locally.
#
# The server URL and analysis token come from the local credential store
# (KWallet via secret-tool). Nothing sensitive is stored in the repo:
#   service=sonarqube item=host-url
#   service=sonarqube item=analysis-token
#
# Override with SONAR_HOST_URL / SONAR_TOKEN env vars if needed.

set -euo pipefail
cd "$(dirname "$0")/.."
PROJECT_KEY="hd2-sc-arrow"

# secret-tool runs on the host; reach it directly or through distrobox.
secret() {
  if command -v secret-tool >/dev/null 2>&1; then
    secret-tool lookup "$@" 2>/dev/null || true
  elif command -v distrobox-host-exec >/dev/null 2>&1; then
    distrobox-host-exec secret-tool lookup "$@" 2>/dev/null || true
  fi
}

SONAR_HOST_URL="${SONAR_HOST_URL:-$(secret service sonarqube item host-url)}"
SONAR_TOKEN="${SONAR_TOKEN:-$(secret service sonarqube item analysis-token)}"
: "${SONAR_HOST_URL:?not set and not in keyring (service=sonarqube item=host-url)}"
: "${SONAR_TOKEN:?not set and not in keyring (service=sonarqube item=analysis-token)}"

# This mod has no unit tests or coverage: the product is binary game-asset
# patches and the only code is shell/Node tooling. Coverage is therefore N/A
# (see sonar.coverage.exclusions in sonar-project.properties).

# Pick a podman runner: host podman, or through distrobox.
if command -v podman >/dev/null 2>&1; then
  RUNNER=(podman)
elif command -v distrobox-host-exec >/dev/null 2>&1; then
  RUNNER=(distrobox-host-exec podman)
else
  echo "ERROR: need podman (host) or distrobox-host-exec (in distrobox)." >&2
  exit 1
fi

echo ">> scanning $PROJECT_KEY"
"${RUNNER[@]}" run --rm --network=host \
  -e SONAR_TOKEN="$SONAR_TOKEN" \
  -e SONAR_HOST_URL="$SONAR_HOST_URL" \
  -v "$PWD":/usr/src:Z \
  docker.io/sonarsource/sonar-scanner-cli

# Wait for the server to finish processing, then read the quality gate.
echo ">> waiting for quality gate"
sleep 6
STATUS="UNKNOWN"
for _ in $(seq 1 30); do
  STATUS=$(curl -s -u "$SONAR_TOKEN:" \
    "$SONAR_HOST_URL/api/qualitygates/project_status?projectKey=$PROJECT_KEY" \
    | python3 -c "import sys,json;print(json.load(sys.stdin)['projectStatus']['status'])" 2>/dev/null || echo UNKNOWN)
  [ "$STATUS" = "OK" ] || [ "$STATUS" = "ERROR" ] && break
  sleep 2
done

echo ">> quality gate: $STATUS"
[ "$STATUS" = "OK" ]
