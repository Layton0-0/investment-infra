#!/usr/bin/env bash
# 배포용 이미지 태그를 환경 변수로 export 하거나 .env에 쓸 때 사용.
# CI에서 SHA를 넘긴 뒤 이 스크립트로 .env를 생성하고, 원격 노드에 복사 후 deploy-*.sh 실행 시 참조.
# 사용 예: BACKEND_TAG=abc1234 PREDICTION_TAG=abc1234 ./set-env-tags.sh && cat .env
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${INFRA_DIR}/.env"

cd "${INFRA_DIR}"

# 인자 또는 환경 변수로 태그 받기 (CI에서 GITHUB_SHA 등 전달)
BACKEND_TAG="${BACKEND_TAG:-${1:-latest}}"
PREDICTION_TAG="${PREDICTION_TAG:-${2:-$BACKEND_TAG}}"
DATA_COLLECTOR_TAG="${DATA_COLLECTOR_TAG:-${3:-$BACKEND_TAG}}"
FRONTEND_TAG="${FRONTEND_TAG:-${4:-$BACKEND_TAG}}"
REGISTRY="${REGISTRY:-ghcr.io}"

# 기존 .env가 있으면 백업하지 않고 태그 관련만 덮어쓴다. 없으면 새로 만든다.
if [[ -f "${ENV_FILE}" ]]; then
  grep -v -E '^(BACKEND_TAG|PREDICTION_TAG|DATA_COLLECTOR_TAG|FRONTEND_TAG|REGISTRY)=' "${ENV_FILE}" > "${ENV_FILE}.tmp" 2>/dev/null || true
  mv "${ENV_FILE}.tmp" "${ENV_FILE}"
fi

{
  echo "BACKEND_TAG=${BACKEND_TAG}"
  echo "PREDICTION_TAG=${PREDICTION_TAG}"
  echo "DATA_COLLECTOR_TAG=${DATA_COLLECTOR_TAG}"
  echo "FRONTEND_TAG=${FRONTEND_TAG}"
  echo "REGISTRY=${REGISTRY}"
} >> "${ENV_FILE}"

echo "Wrote tag env to ${ENV_FILE}"
