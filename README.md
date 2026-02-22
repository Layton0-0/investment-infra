# investment-infra

인프라 전용 저장소. 비즈니스 로직 없음.

- **역할**: 전체 서비스 배포·연결·환경 통제 (최상위 컨트롤 레이어)
- **원칙**: 모든 서비스 이미지는 각 Repo에서 build → registry push. 본 저장소는 **이미지 tag만 참조**.
- **현재 구성**: 토폴로지·노드 역할(무거운 워크로드=AWS API 계층, Oracle 2=엣지, Oracle 3=매크로)은 [05 §2](../investment-backend/docs/06-deployment/05-multi-vps-oracle-aws-cicd.md) 참조. 서버 메모리·스왑 정책은 [05 §3.0](../investment-backend/docs/06-deployment/05-multi-vps-oracle-aws-cicd.md) 참조. IP·키·계정 등 민감정보는 저장소에 포함하지 않는다.

## 구조

```
├── docker-compose.local.yml       # 로컬 개발용 (DB, Redis, prediction, data-collector)
├── docker-compose.local-full.yml  # 로컬 풀 스택 (배포 3대 동일: Oracle1+Oracle2엣지+AWS API)
├── docker-compose.prod.yml        # 운영용 (이미지 tag만 참조)
├── nginx/
│   ├── nginx.conf
│   ├── conf.d.api / conf.d.edge   # 배포용
│   └── conf.d.local/              # 로컬 풀 스택용 (/api → backend, / → frontend)
├── monitoring/                    # Prometheus, Grafana (선택)
├── secrets/                       # .gitignore (env, certs)
├── scripts/                       # deploy, rollback, local-up/local-down
└── README.md
```

## 로컬 개발

### 옵션 1: 풀 스택 한 번에 기동 (배포 3대와 동일 구성, Mumbai 제외)

로컬에서 **Oracle 1(Osaka) + Oracle 2(Korea 엣지) + AWS(Seoul API)** 를 한 줄로 띄우기:

```bash
# Linux / WSL / Git Bash (프로젝트 루트 또는 investment-infra 에서)
./investment-infra/scripts/local-up.sh

# Windows PowerShell
.\investment-infra\scripts\local-up.ps1
```

- **Compose**: `docker-compose.local-full.yml` (timescaledb, redis, backend, prediction-service, data-collector, frontend, nginx)
- **백엔드 이미지**: backend는 `investment-backend/Dockerfile.local`(소스에서 Gradle 빌드) 사용. 코드 수정 후 `docker compose ... up -d --build backend` 하면 최신 코드가 반영됨. (기존 `Dockerfile`은 호스트에서 만든 JAR만 복사해, `./gradlew bootJar`를 안 하면 변경이 안 들어감.)
- **접속**: http://localhost (프론트), http://localhost/api (백엔드 API)
- **중지**: `./investment-infra/scripts/local-down.sh` 또는 `local-down.ps1`
- 상세: [scripts/README.md § 로컬 풀 스택](scripts/README.md)

### 옵션 2: DB/Redis + 일부 서비스만

로컬에서는 상위 workspace에서 다른 repo와 함께 clone 후 통합 실행:

```bash
# DB/Redis + prediction-service(8000) + data-collector(8001) 기동
docker compose -f docker-compose.local.yml up -d

# 이미지까지 빌드 후 기동
docker compose -f docker-compose.local.yml up -d --build
```

- **timescaledb**: 5432
- **redis**: 6379
- **prediction-service**: 8000 (상위 `investment-prediction-service`에서 빌드)
- **data-collector**: 8001 (상위 `investment-data-collector`에서 빌드)
- backend, frontend는 이 yml에 포함되지 않음 (호스트에서 별도 실행 또는 옵션 1 사용)

## 노드별 환경 설정 (.env)

각 노드에서 배포 전 **`.env`** 가 필요하다. 값은 저장소에 커밋하지 않는다.

1. **템플릿 복사**: `cp .env.example .env`
2. **값 채우기**: 노드 역할에 맞게 아래 최소 변수만 설정해도 된다.
   - **Oracle 1 (데이터)**: `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`
   - **Oracle 2 / Oracle 3 (앱)**: `REGISTRY`, `BACKEND_TAG`, `PREDICTION_TAG`, `DATA_COLLECTOR_TAG`, `SPRING_DATASOURCE_URL`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `REDIS_HOST`, `REDIS_PORT`
   - **AWS (엣지)**: `REGISTRY`, `FRONTEND_TAG`
   - **Backend가 도는 노드 (AWS API 등)**: `docker-compose.aws-api.yml`은 **`env_file: .env`** 로 해당 디렉터리의 `.env` 전체를 backend 컨테이너에 전달한다. 배포 서버에서는 SSH로 해당 노드에 접속해 `investment-infra/.env`를 직접 생성·수정하면 된다. (SUPER_ADMIN_*, DART_*, KRX_*, INVESTMENT_JWT_SECRET 등 backend에서 쓰는 변수를 모두 넣으면 된다. 참고: `investment-backend/.env.example`)
3. **배포 전 점검**: `./scripts/check-node-ready.sh` — investment-infra 존재·Docker·.env 필수 변수 중 하나라도 설정되었는지 확인. 스왑(모든 노드)은 [05 §3.0](../investment-backend/docs/06-deployment/05-multi-vps-oracle-aws-cicd.md) 참조.

상세 변수 설명·클론 방법은 [scripts/README.md](scripts/README.md) 참조.

## CI/CD

- **CI**: 각 서비스 Repo (build, test, image build, registry push). 각 레포 `.github/workflows/ci.yml` 참조.
- **CD**: 본 Repo `.github/workflows/cd.yml` — workflow_dispatch 또는 push to main 시 Oracle 1(Osaka), Oracle 2(Korea), Oracle 3(Mumbai), (선택) AWS 노드에 SSH 배포. 시크릿·저장소 변수는 [07-cicd-implementation-checklist.md](../investment-backend/docs/06-deployment/07-cicd-implementation-checklist.md) 참조.
- **멀티 VPS (Oracle Osaka + Oracle Korea + Oracle 3 Mumbai, 선택 시 AWS)**: 상세 토폴로지·CI/CD·배포 스크립트·Cursor Remote-SSH/SSH MCP는 [investment-backend/docs/06-deployment/05-multi-vps-oracle-aws-cicd.md](../investment-backend/docs/06-deployment/05-multi-vps-oracle-aws-cicd.md) 참조.