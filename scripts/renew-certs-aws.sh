#!/usr/bin/env bash
# AWS API 노드 전용: Let's Encrypt 인증서 갱신 후 nginx에 반영
# - 80 포트를 쓰는 nginx를 잠시 중단 → certbot renew (standalone) → 인증서 복사 → nginx 재기동
# 사용: cron에서 주기 실행 (예: 0 0,12 * * * root /home/ec2-user/investment-infra/scripts/renew-certs-aws.sh)
# 실행: root 또는 sudo로 실행 (certbot, docker, cp 권한 필요)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="${INFRA_DIR:-$(cd "${SCRIPT_DIR}/.." && pwd)}"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.aws-api.yml}"
DOMAIN="${CERTBOT_DOMAIN:-api.neekly-report.cloud}"

cd "${INFRA_DIR}"

if [[ ! -f "${COMPOSE_FILE}" ]]; then
  echo "ERROR: ${COMPOSE_FILE} not found in ${INFRA_DIR}" >&2
  exit 1
fi

echo "[$(date -Iseconds)] Stopping nginx for certbot standalone..."
docker compose -f "${COMPOSE_FILE}" stop nginx || true

renewed=0
if certbot renew --quiet 2>/dev/null; then
  renewed=1
fi

echo "[$(date -Iseconds)] Copying certs to secrets/certs (for nginx volume)..."
mkdir -p "${INFRA_DIR}/secrets/certs/live"
if [[ -d "/etc/letsencrypt/live/${DOMAIN}" ]]; then
  cp -rL "/etc/letsencrypt/live/${DOMAIN}" "${INFRA_DIR}/secrets/certs/live/" || \
    sudo cp -rL "/etc/letsencrypt/live/${DOMAIN}" "${INFRA_DIR}/secrets/certs/live/"
fi

echo "[$(date -Iseconds)] Starting nginx..."
docker compose -f "${COMPOSE_FILE}" start nginx

if [[ "${renewed}" -eq 1 ]]; then
  echo "[$(date -Iseconds)] Certificate renewed and nginx restarted."
else
  echo "[$(date -Iseconds)] No renewal needed (or renew failed). nginx restarted."
fi
