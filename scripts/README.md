# Deploy / Rollback scripts

배포·롤백 스크립트. **GitHub Actions CD 단계**에서 SSH로 각 노드에 접속해 실행하거나, 로컬에서 SSH로 원격 실행하는 용도이다.

## 멀티 VPS (Oracle Osaka + Oracle Korea + Oracle 3 Mumbai, 선택 시 AWS)

노드별 전용 스크립트와 Compose 파일. Oracle 1 = 데이터 계층(Osaka), Oracle 2 = 앱 계층(Korea), Oracle 3 = 앱 계층(India West Mumbai).

| 스크립트 | 대상 노드(예) | Compose 파일 | 서비스 |
|----------|---------------|--------------|--------|
| `deploy-oracle1.sh` | Oracle Osaka (데이터) | `docker-compose.oracle1.yml` | timescaledb, redis |
| `deploy-oracle2.sh` | Oracle Korea (앱) | `docker-compose.oracle2.yml` | backend, prediction-service, data-collector |
| `deploy-oracle3-mumbai.sh` | India West (Mumbai, Oracle 3) | `docker-compose.oracle2.yml` | backend, prediction-service, data-collector (동일) |
| `setup-oracle3-mumbai.sh` | Mumbai 최초 1회 | — | Docker·Compose 설치, investment-infra 경로·.env 안내 |
| `check-node-ready.sh` | 모든 노드 | — | investment-infra 존재·Docker·.env 필수 변수 점검 (SSH MCP 또는 수동 실행) |
| `deploy-aws.sh` | AWS (엣지, 선택) | `docker-compose.aws.yml` | frontend, nginx |

### 노드에 investment-infra 클론 (최초 1회)

CD 및 로컬 배포 스크립트는 각 노드의 **`~/investment-infra`** (또는 동일 구조 경로)를 전제로 한다. 최초 1회 클론이 필요하다.

- **저장소가 public인 경우** (노드에서 인증 없이 클론 가능):
  ```bash
  cd ~ && git clone https://github.com/Layton0-0/investment-infra.git investment-infra
  ```
- **저장소가 private인 경우** (둘 중 하나):
  1. **Deploy key**: 각 노드에서 `ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_github -N ""` 후, `~/.ssh/id_ed25519_github.pub` 내용을 GitHub → investment-infra → Settings → Deploy keys에 등록. 그 다음 해당 노드에서:
     ```bash
     cd ~ && GIT_SSH_COMMAND='ssh -i ~/.ssh/id_ed25519_github -o StrictHostKeyChecking=accept-new' git clone git@github.com:Layton0-0/investment-infra.git investment-infra
     ```
  2. **수동 클론**: 로컬 PC에서 SSH로 접속한 뒤, 본인 계정으로 한 번만 `git clone https://github.com/Layton0-0/investment-infra.git investment-infra` (프롬프트에 토큰/비밀번호 입력) 후 나머지 배포는 CD·스크립트 사용.

클론 후 `./scripts/check-node-ready.sh` 로 사전 점검 가능.

### 사용 방법

1. **해당 노드에 investment-infra 클론** (위 참고) **또는 스크립트/yml만 복사**
2. **환경 변수**: Oracle 2 / Oracle 3 (Mumbai) 노드는 `BACKEND_TAG`, `PREDICTION_TAG`, `DATA_COLLECTOR_TAG`, `SPRING_DATASOURCE_URL`, `REDIS_HOST`(Oracle 1 Public IP) 등을 `.env`에 두거나 export 후 실행. AWS는 `FRONTEND_TAG` 등.
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
