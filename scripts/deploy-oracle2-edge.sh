#!/usr/bin/env bash
# Oracle 2/3 엣지 전용 배포: Frontend, nginx(app). /api 는 AWS로 프록시.
# 사용처: 해당 노드에서 직접 실행 또는 CD에서 SSH로 원격 실행
# 환경 변수: FRONTEND_TAG, REGISTRY. .env 선택.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.oracle2-edge.yml}"

cd "${INFRA_DIR}"

if [[ -f .env ]]; then
  set -a
  source .env
  set +a
fi

if [[ ! -f "${COMPOSE_FILE}" ]]; then
  echo "ERROR: ${COMPOSE_FILE} not found." >&2
  exit 1
fi

echo "Stopping existing app stack (oracle2.yml) if any, then edge stack..."
docker compose -f docker-compose.oracle2.yml down --remove-orphans 2>/dev/null || true
docker compose -f "${COMPOSE_FILE}" down --remove-orphans 2>/dev/null || true
docker image prune -f

echo "Pulling images (Edge: frontend, nginx)..."
docker compose -f "${COMPOSE_FILE}" pull frontend nginx

echo "Starting services..."
docker compose -f "${COMPOSE_FILE}" up -d frontend nginx

echo "Done. Check: docker compose -f ${COMPOSE_FILE} ps"
