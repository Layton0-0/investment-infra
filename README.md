# auto-investment-infra

인프라 전용 저장소. 비즈니스 로직 없음.

- **역할**: 전체 서비스 배포·연결·환경 통제 (최상위 컨트롤 레이어)
- **원칙**: 모든 서비스 이미지는 각 Repo에서 build → registry push. 본 저장소는 **이미지 tag만 참조**.

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
# 예: docker-compose.local.yml로 DB/Redis만 기동
docker-compose -f docker-compose.local.yml up -d
```

## CI/CD

- **CI**: 각 서비스 Repo (build, test, image build, registry push)
- **CD**: 본 Repo에서 docker-compose.prod.yml 이미지 tag 갱신 후 서비스 단위 재기동
