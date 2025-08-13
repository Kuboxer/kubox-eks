# 🔗 API Gateway 자동 연결 가이드

## 🎯 자동 연결 시나리오

### **deploy-istio.sh → terraform apply 실행 순서**

1. **deploy-istio.sh 실행** → Istio Gateway 생성
2. **terraform apply 실행** → API Gateway가 자동으로 Istio Gateway 연결

## 🔄 연결 우선순위 로직

### **API Gateway 백엔드 선택**
```
1순위: Istio Gateway (있으면 우선 연결)
  ↓ (없으면)
2순위: ALB (기존 방식 유지)
```

### **Terraform 스마트 연결**
- ✅ **Istio Gateway 감지 시**: 인터넷 직접 연결 (INTERNET)
- ✅ **ALB만 있을 시**: VPC Link 연결 (기존 방식)

## 🚀 실행 방법

### 1단계: Istio + 애플리케이션 배포
```bash
cd /Users/ichungmin/Desktop/kubox-eks/kubox-eks
./deploy-istio.sh
```

### 2단계: API Gateway 연결 확인
```bash
./check-api-gateway.sh
```

### 3단계: API Gateway 자동 연결
```bash
cd /Users/ichungmin/Desktop/kubox-terraform/kubox-terraform/03-api-gateway
terraform apply
```

## ✨ 자동 연결 결과

### **Istio Gateway 사용 시**
```
Internet → API Gateway → Istio Gateway (NLB) → Istio Proxy → EKS Pods
```

### **ALB 사용 시 (백업)**
```
Internet → API Gateway → VPC Link → ALB → EKS Pods
```

## 📊 연결 상태 확인

### **Terraform Output**
```bash
terraform output backend_connection_info
```

**예시 출력:**
```json
{
  "connection_type" = "Istio Gateway (Internet)"
  "target_endpoint" = "http://a1b2c3d4e5.us-east-2.elb.amazonaws.com"
  "istio_available" = true
}
```

## 🔧 호환성 보장

### **두 가지 접속 방법 동시 지원**
- ✅ **API Gateway**: `https://api.kubox.shop` 
- ✅ **Istio Gateway**: `http://<istio-gateway-ip>`
- ✅ **ALB**: `http://<alb-dns>` (유지됨)

### **점진적 마이그레이션**
1. 기존 ALB 유지 → 서비스 중단 없음
2. Istio Gateway 추가 → 새로운 진입점
3. API Gateway 스마트 연결 → 최적 경로 선택

## 🎯 장점

### **자동화된 연결**
- 🤖 Istio Gateway 자동 감지
- 🔄 백엔드 자동 전환
- 📈 무중단 업그레이드

### **이중 안전성**
- 🛡️ Istio Gateway 실패 시 ALB 사용
- 🔒 기존 인프라 보존
- ⚡ 즉시 롤백 가능

이제 **deploy-istio.sh 실행 → terraform apply**만으로 API Gateway가 자동으로 Istio Gateway에 연결됩니다! 🚀
