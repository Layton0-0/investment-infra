#!/usr/bin/env bash
# AWS (엣지 계층) 배포: Nginx, Frontend
# 사용처: 해당 노드에서 직접 실행하거나, GitHub Actions CD에서 SSH로 원격 실행
# 환경 변수: FRONTEND_TAG, REGISTRY (선택). .env 파일로도 주입 가능.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.aws.yml}"

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

echo "Pulling images (AWS: frontend, nginx)..."
docker compose -f "${COMPOSE_FILE}" pull frontend nginx

echo "Starting services..."
docker compose -f "${COMPOSE_FILE}" up -d frontend nginx

echo "Done. Check: docker compose -f ${COMPOSE_FILE} ps"
