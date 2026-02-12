#!/usr/bin/env bash
# Oracle 1 (데이터 계층) 배포: TimescaleDB, Redis
# 사용처: 해당 노드에서 직접 실행하거나, GitHub Actions CD에서 SSH로 원격 실행
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.oracle1.yml}"
ENV_FILE="${INFRA_DIR}/.env"

cd "${INFRA_DIR}"

if [[ ! -f "${COMPOSE_FILE}" ]]; then
  echo "ERROR: ${COMPOSE_FILE} not found. Create it or set COMPOSE_FILE." >&2
  exit 1
fi

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "ERROR: .env not found. On Oracle 1 create .env with POSTGRES_PASSWORD, POSTGRES_USER, POSTGRES_DB." >&2
  exit 1
fi
if ! grep -qE '^POSTGRES_PASSWORD=.+' "${ENV_FILE}"; then
  echo "ERROR: POSTGRES_PASSWORD is missing or empty in .env. Set it before deploying Oracle 1." >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker not found. Install Docker on this host." >&2
  exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
  echo "ERROR: docker compose (plugin) not available. Install docker-compose-plugin." >&2
  exit 1
fi

echo "Pulling images (Oracle 1: timescaledb, redis)..."
docker compose -f "${COMPOSE_FILE}" pull

echo "Starting services..."
docker compose -f "${COMPOSE_FILE}" up -d

echo "Done. Check: docker compose -f ${COMPOSE_FILE} ps"
