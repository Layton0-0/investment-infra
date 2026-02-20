#!/usr/bin/env bash
# AWS API 노드에서 인증서 갱신 cron 등록 (한 번만 실행)
# 사용: AWS에 SSH 접속한 뒤, investment-infra 루트에서 ./scripts/register-cron-aws.sh
# 또는: bash -c "$(curl -sL https://raw.githubusercontent.com/.../register-cron-aws.sh)" (경로는 실제 저장소에 맞게)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="${INFRA_DIR:-$(cd "${SCRIPT_DIR}/.." && pwd)}"
CRON_CMD="0 0,12 * * * root ${INFRA_DIR}/scripts/renew-certs-aws.sh >> /var/log/certbot-renew.log 2>&1"

if [[ -f /etc/cron.d/certbot-renew-aws ]]; then
  echo "cron already registered: /etc/cron.d/certbot-renew-aws"
  cat /etc/cron.d/certbot-renew-aws
  exit 0
fi

echo "Registering certbot renew cron for AWS (api.neekly-report.cloud)..."
echo "${CRON_CMD}" | sudo tee /etc/cron.d/certbot-renew-aws
sudo chmod 644 /etc/cron.d/certbot-renew-aws
echo "Done. Verify: cat /etc/cron.d/certbot-renew-aws"
cat /etc/cron.d/certbot-renew-aws
