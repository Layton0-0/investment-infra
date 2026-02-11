# investment-infra

인프라 전용 저장소. 비즈니스 로직 없음.

- **역할**: 전체 서비스 배포·연결·환경 통제 (최상위 컨트롤 레이어)
- **원칙**: 모든 서비스 이미지는 각 Repo에서 build → registry push. 본 저장소는 **이미지 tag만 참조**.
- **현재 구성**: OCI 2노드 — **Oracle Osaka**(데이터 계층: TimescaleDB, Redis), **Oracle Korea**(애플리케이션 계층: Backend, prediction-service, data-collector). AWS는 선택 사항. IP·키·계정 등 민감정보는 저장소에 포함하지 않는다.

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

## CI/CD

- **CI**: 각 서비스 Repo (build, test, image build, registry push)
- **CD**: 본 Repo에서 docker-compose.prod.yml 이미지 tag 갱신 후 서비스 단위 재기동
- **멀티 VPS (Oracle Osaka + Oracle Korea, 선택 시 AWS)**: 상세 토폴로지·CI/CD·배포 스크립트·Cursor Remote-SSH/SSH MCP는 [investment-backend/docs/06-deployment/05-multi-vps-oracle-aws-cicd.md](../investment-backend/docs/06-deployment/05-multi-vps-oracle-aws-cicd.md) 참조.