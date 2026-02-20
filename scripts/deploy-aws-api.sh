#!/usr/bin/env bash
# AWS API 계층 배포: Backend, prediction-service, data-collector, nginx(api)
# 사용처: AWS 노드에서 직접 실행 또는 GitHub Actions CD에서 SSH로 원격 실행
# 환경 변수: BACKEND_TAG, PREDICTION_TAG, DATA_COLLECTOR_TAG, REGISTRY. .env 필수: SPRING_DATASOURCE_URL, POSTGRES_PASSWORD, REDIS_HOST
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.aws-api.yml}"

cd "${INFRA_DIR}"

if [[ -f .env ]]; then
  set -a
  source .env
  set +a
fi

if [[ -z "${SPRING_DATASOURCE_URL:-}" ]]; then
  echo "ERROR: SPRING_DATASOURCE_URL is not set. Add it to .env (e.g. jdbc:postgresql://<Oracle1-Public-IP>:5432/investment_portfolio)." >&2
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
  echo "ERROR: ${COMPOSE_FILE} not found." >&2
  exit 1
fi

echo "Stopping existing containers (down) and pruning unused images..."
docker compose -f "${COMPOSE_FILE}" down --remove-orphans 2>/dev/null || true
docker image prune -f

echo "Pulling images (AWS API: backend, prediction-service, data-collector, nginx)..."
docker compose -f "${COMPOSE_FILE}" pull backend prediction-service data-collector nginx

echo "Starting services..."
docker compose -f "${COMPOSE_FILE}" up -d backend prediction-service data-collector nginx

echo "Done. Check: docker compose -f ${COMPOSE_FILE} ps"
