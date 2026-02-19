# investment-infra

인프라 전용 저장소. 비즈니스 로직 없음.

- **역할**: 전체 서비스 배포·연결·환경 통제 (최상위 컨트롤 레이어)
- **원칙**: 모든 서비스 이미지는 각 Repo에서 build → registry push. 본 저장소는 **이미지 tag만 참조**.
- **현재 구성**: 토폴로지·노드 역할(무거운 워크로드=AWS API 계층, Oracle 2=엣지, Oracle 3=매크로)은 [05 §2](../investment-backend/docs/06-deployment/05-multi-vps-oracle-aws-cicd.md) 참조. 서버 메모리·스왑 정책은 [05 §3.0](../investment-backend/docs/06-deployment/05-multi-vps-oracle-aws-cicd.md) 참조. IP·키·계정 등 민감정보는 저장소에 포함하지 않는다.

## 구조

```
├── docker-compose.local.yml   # 로컬 개발용 (DB, Redis, 필요 시 서비스 build)
├── docker-compose.prod.yml    # 운영용 (이미지 tag만 참조)
├── nginx/
│   ├── nginx.conf
│   └── conf.d/
├── monitoring/                # Prometheus, Grafana (선택)
├── secrets/                   # .gitignore (env, certs)
├── scripts/                   # deploy / rollback
└── README.md
```

## 로컬 개발

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
- backend, frontend는 로컬 yml에 포함되지 않음 (호스트에서 별도 실행)

## 노드별 환경 설정 (.env)

각 노드에서 배포 전 **`.env`** 가 필요하다. 값은 저장소에 커밋하지 않는다.

1. **템플릿 복사**: `cp .env.example .env`
2. **값 채우기**: 노드 역할에 맞게 아래 최소 변수만 설정해도 된다.
   - **Oracle 1 (데이터)**: `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`
   - **Oracle 2 / Oracle 3 (앱)**: `REGISTRY`, `BACKEND_TAG`, `PREDICTION_TAG`, `DATA_COLLECTOR_TAG`, `SPRING_DATASOURCE_URL`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `REDIS_HOST`, `REDIS_PORT`
   - **AWS (엣지)**: `REGISTRY`, `FRONTEND_TAG`
3. **배포 전 점검**: `./scripts/check-node-ready.sh` — investment-infra 존재·Docker·.env 필수 변수 중 하나라도 설정되었는지 확인. 스왑(모든 노드)은 [05 §3.0](../investment-backend/docs/06-deployment/05-multi-vps-oracle-aws-cicd.md) 참조.

상세 변수 설명·클론 방법은 [scripts/README.md](scripts/README.md) 참조.

## CI/CD

- **CI**: 각 서비스 Repo (build, test, image build, registry push). 각 레포 `.github/workflows/ci.yml` 참조.
- **CD**: 본 Repo `.github/workflows/cd.yml` — workflow_dispatch 또는 push to main 시 Oracle 1(Osaka), Oracle 2(Korea), Oracle 3(Mumbai), (선택) AWS 노드에 SSH 배포. 시크릿·저장소 변수는 [07-cicd-implementation-checklist.md](../investment-backend/docs/06-deployment/07-cicd-implementation-checklist.md) 참조.
- **멀티 VPS (Oracle Osaka + Oracle Korea + Oracle 3 Mumbai, 선택 시 AWS)**: 상세 토폴로지·CI/CD·배포 스크립트·Cursor Remote-SSH/SSH MCP는 [investment-backend/docs/06-deployment/05-multi-vps-oracle-aws-cicd.md](../investment-backend/docs/06-deployment/05-multi-vps-oracle-aws-cicd.md) 참조.