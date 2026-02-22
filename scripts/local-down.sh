#!/usr/bin/env bash
# 로컬 풀 스택 중지
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPOSE_FILE="${INFRA_DIR}/docker-compose.local-full.yml"

cd "${INFRA_DIR}"
docker compose -f "${COMPOSE_FILE}" down
echo "Local full stack stopped."
