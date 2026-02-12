#!/usr/bin/env bash
# 노드 사전 점검: investment-infra 존재, Docker 설치, .env 필수 변수 중 하나라도 설정 여부.
# 사용처: SSH MCP 또는 수동으로 각 노드에서 실행. 배포 가능 상태면 0, 아니면 1 반환.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 스크립트가 investment-infra/scripts/ 안에 있으면 상위가 infra 디렉터리
if [[ -f "${SCRIPT_DIR}/../docker-compose.oracle1.yml" ]] || [[ -f "${SCRIPT_DIR}/../docker-compose.oracle2.yml" ]]; then
  INFRA_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
else
  INFRA_DIR="${INFRA_DIR:-$HOME/investment-infra}"
fi

echo "Checking node readiness (INFRA_DIR=${INFRA_DIR})..."

# 1. investment-infra 디렉터리 존재
if [[ ! -d "${INFRA_DIR}" ]]; then
  echo "ERROR: investment-infra directory not found at ${INFRA_DIR}. Clone the repo or set INFRA_DIR." >&2
  exit 1
fi

# 2. docker, docker compose 사용 가능
if ! command -v docker &>/dev/null; then
  echo "ERROR: docker not found. Install Docker first." >&2
  exit 1
fi
if ! docker compose version &>/dev/null; then
  echo "ERROR: docker compose not available. Install docker-compose-plugin." >&2
  exit 1
fi

# 3. .env 존재 시 필수 변수 중 하나라도 설정되어 있는지
ENV_FILE="${INFRA_DIR}/.env"
if [[ -f "${ENV_FILE}" ]]; then
  set +u
  set -a
  source "${ENV_FILE}" 2>/dev/null || true
  set +a
  set -u
  if [[ -n "${BACKEND_TAG:-}" ]] || [[ -n "${SPRING_DATASOURCE_URL:-}" ]] || [[ -n "${REDIS_HOST:-}" ]] || [[ -n "${REGISTRY:-}" ]] || [[ -n "${POSTGRES_PASSWORD:-}" ]]; then
    echo ".env found and at least one required variable is set."
  else
    echo "WARN: .env exists but none of BACKEND_TAG, SPRING_DATASOURCE_URL, REDIS_HOST, REGISTRY, POSTGRES_PASSWORD is set. App nodes need DB/Redis/tag settings." >&2
  fi
else
  echo "WARN: .env not found at ${ENV_FILE}. Data node (Oracle 1) may run without it; app nodes (Oracle 2/3) need .env with SPRING_DATASOURCE_URL, REDIS_HOST, *_TAG." >&2
fi

echo "Node readiness check passed."
exit 0
