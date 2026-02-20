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
  echo "Skipping Oracle 1 deploy: .env not found. Create .env with POSTGRES_PASSWORD, POSTGRES_USER, POSTGRES_DB to deploy."
  exit 0
fi
if ! grep -qE '^POSTGRES_PASSWORD=.+' "${ENV_FILE}"; then
  echo "Skipping Oracle 1 deploy: POSTGRES_PASSWORD missing or empty in .env."
  exit 0
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker not found. Install Docker on this host." >&2
  exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
  echo "ERROR: docker compose (plugin) not available. Install docker-compose-plugin." >&2
  exit 1
fi

echo "Stopping existing containers (down) and pruning unused images..."
docker compose -f "${COMPOSE_FILE}" down --remove-orphans 2>/dev/null || true
docker image prune -f

echo "Pulling images (Oracle 1: timescaledb, redis)..."
docker compose -f "${COMPOSE_FILE}" pull

echo "Starting services..."
docker compose -f "${COMPOSE_FILE}" up -d

echo "Done. Check: docker compose -f ${COMPOSE_FILE} ps"
