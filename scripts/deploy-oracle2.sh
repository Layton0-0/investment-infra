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

if [[ ! -f "${COMPOSE_FILE}" ]]; then
  echo "ERROR: ${COMPOSE_FILE} not found. Create it or set COMPOSE_FILE." >&2
  exit 1
fi

echo "Pulling images (Oracle 2: backend, prediction-service, data-collector)..."
docker compose -f "${COMPOSE_FILE}" pull backend prediction-service data-collector

echo "Starting services..."
docker compose -f "${COMPOSE_FILE}" up -d backend prediction-service data-collector

echo "Done. Check: docker compose -f ${COMPOSE_FILE} ps"
