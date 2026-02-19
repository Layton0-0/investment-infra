#!/usr/bin/env bash
# Mumbai (Oracle 3) 노드 최초 1회 설정: Docker, Docker Compose 설치 및 investment-infra 준비.
# Mumbai 인스턴스에 SSH 접속한 뒤 이 스크립트를 실행한다. (실제 비밀번호·IP는 저장소에 넣지 않음.)
# 사용: curl -sL <raw_url> | bash  또는  bash setup-oracle3-mumbai.sh
set -euo pipefail

echo "=== Mumbai (Oracle 3) node setup ==="

# Docker 설치 (Ubuntu 24.04)
if ! command -v docker &>/dev/null; then
  echo "Installing Docker..."
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${VERSION_CODENAME:-$VERSION_ID}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo usermod -aG docker "$USER" || true
  echo "Docker installed. You may need to log out and back in for 'docker' without sudo."
fi

# Docker Compose (plugin) 확인
if ! docker compose version &>/dev/null; then
  echo "Docker Compose plugin not found. Install docker-compose-plugin or use standalone compose."
  exit 1
fi

echo "Docker: $(docker --version), Compose: $(docker compose version)"

# investment-infra 디렉터리 (스크립트가 investment-infra/scripts/ 안에 있으면 자동 감지)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-.}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/../docker-compose.oracle2.yml" ]]; then
  INFRA_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
else
  INFRA_DIR="${INFRA_DIR:-$HOME/investment-infra}"
fi
if [[ ! -d "${INFRA_DIR}" ]]; then
  echo ""
  echo "Clone investment-infra into ${INFRA_DIR}:"
  echo "  git clone <your-investment-infra-repo-url> ${INFRA_DIR}"
  echo "  cd ${INFRA_DIR} && ./scripts/setup-oracle3-mumbai.sh"
  echo ""
  echo "Or set INFRA_DIR and re-run."
else
  echo "Found investment-infra at ${INFRA_DIR}"
fi

echo ""
echo "=== Next steps (do not commit secrets to repo) ==="
echo "1. Oracle 1 (Osaka) Security List: add this instance's PUBLIC IP to TCP 5432, 6379 Ingress."
echo "2. In ${INFRA_DIR}, create .env with (replace placeholders):"
echo "   REGISTRY=ghcr.io"
echo "   BACKEND_TAG=latest"
echo "   PREDICTION_TAG=latest"
echo "   DATA_COLLECTOR_TAG=latest"
echo "   SPRING_DATASOURCE_URL=jdbc:postgresql://<ORACLE_1_PUBLIC_IP>:5432/investment_portfolio"
echo "   POSTGRES_USER=investment_pg"
echo "   POSTGRES_PASSWORD=<your-db-password>"
echo "   POSTGRES_DB=investment_portfolio"
echo "   REDIS_HOST=<ORACLE_1_PUBLIC_IP>"
echo "   REDIS_PORT=6379"
echo "3. Deploy: ./scripts/set-env-tags.sh && ./scripts/deploy-oracle3-mumbai.sh"
echo "4. GitHub Actions CD: set Variables DEPLOY_HOST_ORACLE_MUMBAI=<this-instance-public-ip>, Secrets SSH_PRIVATE_KEY_ORACLE_MUMBAI."
echo "5. Swap: RAM-based swap is in 05 §3.0 (recommend 2GB). Check with: free -m; swapon --show"
echo "=== Done ==="
