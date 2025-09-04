#!/bin/bash
NS="app-services"
echo "🚀 Kubox 쇼핑몰 + Istio 배포 시작..."

# 1. SecretProviderClass 적용
echo "1️⃣ AWS Secrets Manager 연동 설정..."
kubectl apply -f app-services/secret-provider-class.yaml

# 2. 시크릿 생성 테스트 Job
echo "2️⃣ 시크릿 생성 테스트..."
kubectl apply -f app-services/first-init.yaml
echo "⏳ 시크릿 생성 대기 중..."
kubectl wait -n "$NS" --for=condition=ready pod/secrets-test --timeout=300s

# 3. 시크릿 생성 확인
echo "✅ 시크릿 생성 확인:"
kubectl get secrets -n "$NS" | grep kubox

# 4. 인프라 서비스 배포
echo "4️⃣ 인프라 서비스 배포 (MySQL, Redis)..."
kubectl apply -f app-services/mysql.yaml
# kubectl apply -f app-services/redis.yaml
echo "⏳ 인프라 서비스 준비 대기..."
kubectl wait -n "$NS" --for=condition=ready pod/mysql-0 --timeout=300s
# kubectl wait -n "$NS" --for=condition=ready pod/redis-0 --timeout=300s

# 6. Istio 설정 적용
echo "6️⃣ Istio 트래픽 관리 설정 적용..."
kubectl apply -f istio/gateway.yaml
kubectl apply -f istio/virtual-service.yaml
kubectl apply -f istio/destination-rules.yaml

# 7. first-init 삭제
kubectl delete -f app-services/first-init.yaml

kubectl apply -f argocd-application.yaml

# 8. Istio Gateway 외부 IP 확인
echo "8️⃣ Istio Gateway 외부 IP 확인..."
echo "⏳ LoadBalancer IP 할당 대기 중..."
kubectl wait --for=jsonpath='{.status.loadBalancer.ingress}' service/istio-ingressgateway -n istio-system --timeout=300s

echo ""
echo "🌐 Istio Gateway 상태:"
kubectl get svc istio-ingressgateway -n istio-system


echo "🚪 Istio Gateway 상태:"
kubectl get gateway

echo ""
echo "🔄 Istio VirtualService 상태:"
kubectl get virtualservice

echo ""
echo "🎯 Istio DestinationRule 상태:"
kubectl get destinationrule -n "$NS"

echo ""
echo "🌍 Istio Gateway 외부 접속 주소:"
GATEWAY_IP=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
if [ -z "$GATEWAY_IP" ]; then
    GATEWAY_IP=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
fi
echo "External URL: http://$GATEWAY_IP"


echo ""
echo "🎉 Kubox 쇼핑몰 + Istio 배포 완료!"
echo "🔗 웹사이트 접속: http://$GATEWAY_IP"
echo ""
echo "✨ Istio 기능 활성화됨:"
echo "  - 자동 로드밸런싱 (LEAST_CONN)"
echo "  - 서킷브레이커 (3회 실패 시 차단)"
echo "  - 자동 재시도 (3회, 10초 타임아웃)"
echo "  - 분산 추적 및 메트릭 수집"
echo "  - mTLS 보안 통신"
echo "  - CORS 정책 관리"
