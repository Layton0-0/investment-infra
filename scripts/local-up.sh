#!/usr/bin/env bash
# 로컬 풀 스택 기동 (배포 3대: Osaka + Korea + AWS, Mumbai 제외)
# 사용: ./scripts/local-up.sh  또는  bash scripts/local-up.sh
# 프로젝트 루트(auto-investment-project) 또는 investment-infra 에서 실행 가능.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ROOT_DIR="$(cd "${INFRA_DIR}/.." && pwd)"
COMPOSE_FILE="${INFRA_DIR}/docker-compose.local-full.yml"
ENV_FILE="${INFRA_DIR}/.env"

cd "${INFRA_DIR}"

if [[ ! -f "${COMPOSE_FILE}" ]]; then
  echo "ERROR: ${COMPOSE_FILE} not found." >&2
  exit 1
fi

# .env 없으면 로컬용 기본값으로 생성
if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Creating .env with local defaults..."
  cat <<'ENVEOF' > "${ENV_FILE}"
# Local full stack (do not commit secrets in prod)
POSTGRES_USER=local_pg
POSTGRES_PASSWORD=local_pg_pass
POSTGRES_DB=investment_portfolio
ENVEOF
fi
export POSTGRES_USER="${POSTGRES_USER:-local_pg}"
export POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-local_pg_pass}"
export POSTGRES_DB="${POSTGRES_DB:-investment_portfolio}"

# Backend JAR: Dockerfile가 build/libs/*.jar 를 요구하므로 없으면 bootJar 실행
BACKEND_DIR="${ROOT_DIR}/investment-backend"
if [[ -d "${BACKEND_DIR}" ]]; then
  if ! compgen -G "${BACKEND_DIR}/build/libs/*.jar" >/dev/null 2>&1; then
    echo "Building backend JAR (bootJar)..."
    (cd "${BACKEND_DIR}" && ./gradlew bootJar --no-daemon -q)
  fi
fi

echo "Starting local full stack (Oracle1 + Oracle2-edge + AWS API)..."
docker compose -f "${COMPOSE_FILE}" up -d --build

echo "Done. Services:"
docker compose -f "${COMPOSE_FILE}" ps
echo ""
echo "Access: http://localhost (frontend), http://localhost/api (backend API)"
