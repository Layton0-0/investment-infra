#!/usr/bin/env bash
# IntelliJ/Cursor 직접 구동용: DB + Redis + Python(prediction-service, data-collector) 기동 (백엔드·프론트·nginx 제외)
# 사용: ./scripts/local-up-db-only.sh  (investment-infra 또는 프로젝트 루트에서 실행)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPOSE_FILE="${INFRA_DIR}/docker-compose.local-db-only.yml"

cd "${INFRA_DIR}"
if [[ ! -f "${COMPOSE_FILE}" ]]; then
  echo "ERROR: ${COMPOSE_FILE} not found." >&2
  exit 1
fi

echo "Starting timescaledb + redis + prediction-service + data-collector (for IntelliJ/Cursor direct run)..."
docker compose -f docker-compose.local-db-only.yml up -d --build
echo "Done. Backend: IntelliJ (local,intellij) or investment-backend/scripts/bootRun-agent.ps1 (local,local-agent)."
