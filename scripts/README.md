# Deploy / Rollback scripts

배포·롤백 스크립트. **GitHub Actions CD 단계**에서 SSH로 각 노드에 접속해 실행하거나, 로컬에서 SSH로 원격 실행하는 용도이다.

## 멀티 VPS (Oracle Osaka + Oracle Korea, 선택 시 AWS)

노드별 전용 스크립트와 Compose 파일. Oracle 1 = 데이터 계층(예: Oracle Osaka), Oracle 2 = 앱 계층(예: Oracle Korea)에 대응한다.

| 스크립트 | 대상 노드(예) | Compose 파일 | 서비스 |
|----------|---------------|--------------|--------|
| `deploy-oracle1.sh` | Oracle Osaka (데이터) | `docker-compose.oracle1.yml` | timescaledb, redis |
| `deploy-oracle2.sh` | Oracle Korea (앱) | `docker-compose.oracle2.yml` | backend, prediction-service, data-collector |
| `deploy-aws.sh` | AWS (엣지, 선택) | `docker-compose.aws.yml` | frontend, nginx |

### 사용 방법

1. **해당 노드에 investment-infra 클론 또는 스크립트/yml 복사**
2. **환경 변수**: Oracle 2 / AWS 노드는 `BACKEND_TAG`, `PREDICTION_TAG`, `DATA_COLLECTOR_TAG`, `FRONTEND_TAG` 등을 `.env`에 두거나 export 후 실행
3. **태그 설정 헬퍼**: `set-env-tags.sh` — 인자 또는 환경 변수로 태그를 받아 `.env`에 쓴다. CI에서 `GITHUB_SHA` 전달 후 원격 노드에 `.env` 복사하고 `deploy-*.sh` 실행 시 참조

```bash
# 예: Oracle 2에서 (백엔드 등 태그가 이미 .env에 있다고 가정)
./scripts/deploy-oracle2.sh

# 태그만 갱신 후 배포 (로컬에서 .env 생성 후 원격으로 복사해 실행)
BACKEND_TAG=abc1234 PREDICTION_TAG=abc1234 DATA_COLLECTOR_TAG=abc1234 ./scripts/set-env-tags.sh
```

### 단일 VPS

이미지 태그만 갱신한 뒤 전체 서비스 재기동:

```bash
# docker-compose.prod.yml 기준
export BACKEND_TAG=xxx FRONTEND_TAG=xxx  # 필요 시
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d
```

상세 토폴로지·CI/CD·보안·체크리스트는 [investment-backend/docs/06-deployment/05-multi-vps-oracle-aws-cicd.md](../../investment-backend/docs/06-deployment/05-multi-vps-oracle-aws-cicd.md) 참조.
