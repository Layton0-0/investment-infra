#!/usr/bin/env bash
# Oracle 2 (Korea) 엣지 전용: app.neekly-report.cloud 인증서 갱신 후 nginx에 반영
# - 80 포트를 쓰는 nginx를 잠시 중단 → certbot renew (standalone) → 인증서 복사 → nginx 재기동
# 사용: cron에서 주기 실행 (예: 0 0,12 * * * root /home/ubuntu/investment-infra/scripts/renew-certs-oracle2-edge.sh)
# 실행: root 또는 sudo로 실행 (certbot, docker, cp 권한 필요)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="${INFRA_DIR:-$(cd "${SCRIPT_DIR}/.." && pwd)}"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.oracle2-edge.yml}"
DOMAIN="${CERTBOT_DOMAIN:-app.neekly-report.cloud}"

cd "${INFRA_DIR}"

if [[ ! -f "${COMPOSE_FILE}" ]]; then
  echo "ERROR: ${COMPOSE_FILE} not found in ${INFRA_DIR}" >&2
  exit 1
fi

echo "[$(date -Iseconds)] Stopping nginx for certbot standalone..."
docker compose -f "${COMPOSE_FILE}" stop nginx || true

renewed=0
if command -v certbot &>/dev/null; then
  if certbot renew --quiet 2>/dev/null; then renewed=1; fi
else
  if sudo docker run --rm -p 80:80 -v /etc/letsencrypt:/etc/letsencrypt -v /var/lib/letsencrypt:/var/lib/letsencrypt certbot/certbot renew --standalone --quiet 2>/dev/null; then renewed=1; fi
fi

echo "[$(date -Iseconds)] Copying certs to secrets/certs (for nginx volume)..."
sudo mkdir -p "${INFRA_DIR}/secrets/certs/live"
if [[ -d "/etc/letsencrypt/live/${DOMAIN}" ]]; then
  sudo cp -rL "/etc/letsencrypt/live/${DOMAIN}" "${INFRA_DIR}/secrets/certs/live/" || true
  sudo chown -R "$(whoami):$(whoami)" "${INFRA_DIR}/secrets/certs/live/${DOMAIN}" 2>/dev/null || true
fi

echo "[$(date -Iseconds)] Starting nginx..."
docker compose -f "${COMPOSE_FILE}" start nginx

if [[ "${renewed}" -eq 1 ]]; then
  echo "[$(date -Iseconds)] Certificate renewed and nginx restarted."
else
  echo "[$(date -Iseconds)] No renewal needed (or renew failed). nginx restarted."
fi
