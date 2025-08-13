# 🚀 Kubox 쇼핑몰 Istio 배포 가이드

## 📁 파일 구조
```
kubox-eks/kubox-eks/
├── istio/
│   ├── gateway.yaml           # Istio Gateway (외부 진입점)
│   ├── virtual-service.yaml   # 트래픽 라우팅 규칙
│   └── destination-rules.yaml # 서킷브레이커, 로드밸런싱
├── deploy-istio.sh           # 전체 배포 스크립트
├── check-istio.sh           # 상태 확인 및 문제 해결
└── README-ISTIO.md          # 이 가이드
```

## 🎯 실행 순서

### 1단계: Terraform으로 인프라 구성
```bash
cd /Users/ichungmin/Desktop/kubox-terraform/kubox-terraform/02-eks
terraform apply
```

### 2단계: Istio + 애플리케이션 배포
```bash
cd /Users/ichungmin/Desktop/kubox-eks/kubox-eks
chmod +x deploy-istio.sh
./deploy-istio.sh
```

### 3단계: 상태 확인 및 문제 해결
```bash
chmod +x check-istio.sh
./check-istio.sh
```

## ✨ Istio 적용 후 변화

### 🔄 기존 vs Istio
| 항목 | 기존 (ALB Ingress) | Istio Gateway |
|------|-------------------|---------------|
| **진입점** | AWS ALB | Istio Gateway (NLB) |
| **라우팅** | Ingress 규칙 | VirtualService |
| **로드밸런싱** | ALB 기본 | LEAST_CONN |
| **서킷브레이커** | 애플리케이션 코드 | DestinationRule |
| **재시도** | 애플리케이션 코드 | VirtualService |
| **모니터링** | CloudWatch | Kiali, Jaeger, Grafana |
| **보안** | 수동 설정 | 자동 mTLS |

### 🛡️ 트래픽 정책
- **서킷브레이커**: 3회 연속 실패 시 30초간 차단
- **재시도**: 3회 자동 재시도, 10초 타임아웃
- **로드밸런싱**: LEAST_CONN (최소 연결)
- **타임아웃**: 30초 요청 타임아웃
- **CORS**: Gateway에서 통합 관리

## 📊 모니터링 대시보드

### Kiali (서비스 메시 시각화)
```bash
kubectl port-forward -n istio-system svc/kiali 20001:20001
# 브라우저: http://localhost:20001
```

### Grafana (메트릭 대시보드)
```bash
kubectl port-forward -n istio-system svc/grafana 3000:80
# 브라우저: http://localhost:3000 (admin/admin)
```

### Jaeger (분산 추적)
```bash
kubectl port-forward -n istio-system svc/jaeger-query 16686:16686
# 브라우저: http://localhost:16686
```

## 🔧 문제 해결

### 사이드카 주입 안됨
```bash
# 네임스페이스 라벨 확인
kubectl get namespace default -L istio-injection

# 라벨 추가
kubectl label namespace default istio-injection=enabled

# 팟 재시작
kubectl rollout restart deployment/user-service
```

### Gateway 접속 안됨
```bash
# Istio Gateway IP 확인
kubectl get svc istio-ingressgateway -n istio-system

# Gateway 설정 확인
kubectl describe gateway kubox-gateway
```

### 서비스 간 통신 실패
```bash
# DestinationRule 확인
kubectl get destinationrule

# 사이드카 로그 확인
kubectl logs <pod-name> -c istio-proxy
```

## 🎛️ 고급 기능

### 트래픽 분할 (카나리 배포)
```yaml
# VirtualService에 가중치 설정
route:
- destination:
    host: user-svc
    subset: v1
  weight: 90
- destination:
    host: user-svc  
    subset: v2
  weight: 10
```

### 장애 주입 (테스트)
```yaml
# VirtualService에 장애 주입
fault:
  delay:
    percentage:
      value: 50
    fixedDelay: 5s
  abort:
    percentage:
      value: 10
    httpStatus: 500
```

## 🚀 성능 최적화

이미 적용된 최적화:
- **연결 풀**: 최대 100개 TCP 연결
- **HTTP 큐잉**: 50개 대기 요청
- **아웃라이어 감지**: 불량 인스턴스 자동 제외
- **최소 건강 비율**: 30% 이상 유지

모든 설정이 프로덕션 레벨로 구성되어 있습니다! 🎉
