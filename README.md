# Kubox EKS YAML Files

이 폴더에는 EKS 클러스터에서 실행할 쇼핑몰 마이크로서비스 YAML 파일들이 포함되어 있습니다.

## 파일 목록

### 🔧 인프라 설정
- `configmap.yaml` - 공통 환경변수 설정
- `secrets.yaml` - 민감한 정보 (DB 비밀번호, JWT 시크릿, API 키)
- `pvc.yaml` - 영구 볼륨 클레임 (MySQL, Redis 데이터 저장용)

### 💾 데이터 레이어
- `mysql-db.yaml` - MySQL 데이터베이스 Deployment + Service + 초기화 스크립트
- `redis-cache.yaml` - Redis 캐시 Deployment + Service

### 🛍️ 마이크로서비스
- `user-service.yaml` - 사용자 서비스 (포트: 8080, DB: user_db)
- `product-service.yaml` - 상품 서비스 (포트: 8081, DB: product_db)
- `cart-service.yaml` - 장바구니 서비스 (포트: 8084, DB: cart_db)
- `order-service.yaml` - 주문 서비스 (포트: 8082, DB: order_db)
- `payment-service.yaml` - 결제 서비스 (포트: 8083, DB: payment_db)

### 📝 스크립트
- `deploy-all.sh` - 전체 쇼핑몰 서비스 배포 (단계별)
- `cleanup.sh` - 전체 서비스 정리 (데이터 보호 포함)

## 🚀 배포 방법

### 1단계: 전체 서비스 배포
```bash
cd /Users/choiyunha/kubox-eks
chmod +x deploy-all.sh cleanup.sh
./deploy-all.sh
```

### 2단계: 배포 과정
1. **ConfigMap, Secret, PVC 생성** (60초 대기)
2. **MySQL, Redis 배포** (60초 대기) 
3. **User, Product 서비스 배포** (30초 대기)
4. **Cart, Order, Payment 서비스 배포** (60초 대기)
5. **상태 확인 및 완료**

## 📊 상태 확인

```bash
# 전체 리소스 확인
kubectl get pods,svc,pvc

# 특정 서비스 로그 확인
kubectl logs deployment/user-service
kubectl logs deployment/mysql

# 서비스 상세 정보
kubectl describe pod <pod-name>
```

## 🔧 개별 서비스 관리

### 개별 배포
```bash
# 순서대로 배포 (의존성 고려)
kubectl apply -f configmap.yaml
kubectl apply -f secrets.yaml
kubectl apply -f pvc.yaml
kubectl apply -f mysql-db.yaml
kubectl apply -f redis-cache.yaml
kubectl apply -f user-service.yaml
# ... 나머지 서비스들
```

### 서비스 재시작
```bash
kubectl rollout restart deployment/user-service
kubectl rollout restart deployment/mysql
```

## 🧹 정리

```bash
# 전체 정리 (PVC 보호 옵션 포함)
./cleanup.sh

# 강제 전체 삭제
kubectl delete -f .
```

## ⚙️ 시스템 구성

### 환경변수 구성
**ConfigMap (kubox-config):**
- DB_HOST, DB_PORT, DB_USERNAME
- REDIS_HOST, REDIS_PORT  
- JWT_EXPIRATION, CORS 설정
- BootPay API URL
- AWS 리전 설정

**Secret (kubox-secrets):**
- MySQL 비밀번호들
- JWT 시크릿 키
- BootPay API 키들

### 포트 매핑
- User Service: `8080` → user_db
- Product Service: `8081` → product_db  
- Order Service: `8082` → order_db
- Payment Service: `8083` → payment_db
- Cart Service: `8084` → cart_db
- MySQL: `3306`
- Redis: `6379`

### 데이터 영속성
- **mysql-pvc**: 10Gi (MySQL 데이터)
- **redis-pvc**: 1Gi (Redis 데이터)
- **StorageClass**: gp2 (AWS EBS)

### IRSA 보안
- 모든 서비스에 `s3-sa` Service Account 적용
- S3 Full Access 권한으로 파일 업로드/다운로드 가능

## 🔍 트러블슈팅

### Pod가 시작되지 않는 경우
```bash
# Pod 상태 확인
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>

# 리소스 확인
kubectl top nodes
kubectl top pods
```

### 데이터베이스 연결 문제
```bash
# MySQL 연결 테스트
kubectl exec -it deployment/mysql -- mysql -u shop_user -p

# Redis 연결 테스트  
kubectl exec -it deployment/redis -- redis-cli ping
```

### 네트워크 문제
```bash
# 서비스 DNS 확인
kubectl exec -it deployment/user-service -- nslookup mysql-service
kubectl exec -it deployment/user-service -- nslookup redis-service
```
