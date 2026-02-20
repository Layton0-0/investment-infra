#!/usr/bin/env bash
# Oracle 3 (India West Mumbai): 앱 스택(Backend, prediction-service, data-collector) 제거 및 이미지 정리만 수행.
# 매크로(Jenkins 또는 cron/shell 등)는 별도 관리. 앱 스택은 AWS에서만 운영.
# 사용처: Mumbai 노드에서 직접 실행하거나, GitHub Actions CD에서 SSH로 원격 실행.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
APP_COMPOSE="${INFRA_DIR}/docker-compose.oracle2.yml"

cd "${INFRA_DIR}"

if ! command -v docker &>/dev/null; then
  echo "Docker not installed on Mumbai; skipping app stack cleanup."
  exit 0
fi

if [[ ! -f "${APP_COMPOSE}" ]]; then
  echo "No app compose at ${APP_COMPOSE}; nothing to down. Pruning images only."
else
  echo "Stopping and removing app stack (Backend, prediction-service, data-collector) on Mumbai..."
  docker compose -f "${APP_COMPOSE}" down --remove-orphans 2>/dev/null || true
fi

echo "Pruning unused images..."
docker image prune -f

echo "Done. Mumbai: app stack removed. Macro (cron/shell or Jenkins) if any is managed separately."
