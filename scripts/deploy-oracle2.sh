#!/usr/bin/env bash
# Oracle 2 (애플리케이션 계층) 배포: Backend, prediction-service, data-collector
# 사용처: 해당 노드에서 직접 실행하거나, GitHub Actions CD에서 SSH로 원격 실행
# 환경 변수: BACKEND_TAG, PREDICTION_TAG, DATA_COLLECTOR_TAG, REGISTRY (선택). .env 파일로도 주입 가능.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.oracle2.yml}"

cd "${INFRA_DIR}"

if [[ -f .env ]]; then
  set -a
  source .env
  set +a
fi

# Required for backend: fail fast with clear message if missing (CD runs on app nodes)
if [[ -z "${SPRING_DATASOURCE_URL:-}" ]]; then
  echo "ERROR: SPRING_DATASOURCE_URL is not set. Add it to .env (e.g. jdbc:postgresql://<Oracle1-Public-IP>:5432/<DB>)." >&2
  exit 1
fi
if [[ -z "${POSTGRES_PASSWORD:-}" ]]; then
  echo "ERROR: POSTGRES_PASSWORD is not set in .env (must match Oracle 1)." >&2
  exit 1
fi
if [[ -z "${REDIS_HOST:-}" ]]; then
  echo "ERROR: REDIS_HOST is not set in .env (use Oracle 1 Public IP)." >&2
  exit 1
fi

if [[ ! -f "${COMPOSE_FILE}" ]]; then
  echo "ERROR: ${COMPOSE_FILE} not found. Create it or set COMPOSE_FILE." >&2
  exit 1
fi

echo "Pulling images (Oracle 2: backend, prediction-service, data-collector)..."
docker compose -f "${COMPOSE_FILE}" pull backend prediction-service data-collector

echo "Starting services..."
docker compose -f "${COMPOSE_FILE}" up -d backend prediction-service data-collector

echo "Done. Check: docker compose -f ${COMPOSE_FILE} ps"
