#!/usr/bin/env bash
# Oracle 3 (India West Mumbai) 배포: Backend, prediction-service, data-collector
# Oracle 2와 동일한 앱 스택. .env에 SPRING_DATASOURCE_URL, REDIS_HOST = Oracle 1(Osaka) Public IP 로 설정 후 실행.
# 사용처: Mumbai 노드에서 직접 실행하거나, GitHub Actions CD에서 SSH로 원격 실행.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

exec "${SCRIPT_DIR}/deploy-oracle2.sh"
