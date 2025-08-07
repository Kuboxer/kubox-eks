# Kubox EKS - Kubernetes Configurations

EKS에서 실행하는 Kubox 쇼핑몰 마이크로서비스를 위한 Kubernetes YAML 설정 파일들입니다.

## 🏗️ 아키텍처

```
┌─────────────────────────────────────────────────────────────┐
│                        EKS Cluster                          │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │User Service │  │Product Svc  │  │ Cart Service│         │
│  │   :8080     │  │   :8081     │  │    :8084    │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│  ┌─────────────┐  ┌─────────────┐                          │
│  │Order Service│  │Payment Svc  │                          │
│  │   :8082     │  │   :8083     │                          │
│  └─────────────┘  └─────────────┘                          │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐                          │
│  │   MySQL     │  │   Redis     │                          │
│  │   :3306     │  │   :6379     │                          │
│  │   (10Gi)    │  │   (1Gi)     │                          │
│  └─────────────┘  └─────────────┘                          │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 빠른 시작

```bash
# 저장소 클론
git clone <your-repo-url>
cd kubox-eks

# 실행 권한 부여
chmod +x *.sh

# 전체 서비스 배포
./deploy-all.sh

# 상태 확인
kubectl get pods,svc,pvc
```

## 📁 파일 구조

```
kubox-eks/
├── README.md           # 이 파일
├── .gitignore         # Git 무시 파일
├── configmap.yaml     # 환경변수 설정
├── secrets.yaml       # 민감정보 (base64 인코딩)
├── pvc.yaml          # 영구 볼륨
├── mysql-db.yaml     # MySQL + 초기화 스크립트
├── redis-cache.yaml  # Redis 캐시
├── user-service.yaml    # 사용자 서비스 (:8080)
├── product-service.yaml # 상품 서비스 (:8081)
├── order-service.yaml   # 주문 서비스 (:8082)
├── payment-service.yaml # 결제 서비스 (:8083)
├── cart-service.yaml    # 장바구니 서비스 (:8084)
├── deploy-all.sh     # 자동 배포 스크립트
├── cleanup.sh        # 정리 스크립트
└── git-init.sh       # Git 초기화 스크립트
```

## 🔧 주요 특징

- **ConfigMap/Secret**: 환경변수 중앙 관리
- **PVC**: 데이터 영속성 보장 
- **IRSA**: S3 액세스를 위한 보안 설정
- **Health Check**: 서비스 안정성 확보
- **단계별 배포**: 의존성을 고려한 순차 배포
- **안전한 정리**: PVC 보호 옵션

## 🎯 운영 가이드

상세한 사용법과 트러블슈팅은 [README.md](README.md)를 참고하세요.

## 🏷️ 태그

`kubernetes` `eks` `microservices` `aws` `mysql` `redis` `golang` `devops`
