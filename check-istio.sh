#!/bin/bash

echo "🔍 Istio 상태 확인 및 문제 해결..."

# 1. 전체 클러스터 상태 확인
echo "1️⃣ 전체 클러스터 상태:"
kubectl get nodes
echo ""

# 2. Istio 시스템 상태 확인
echo "2️⃣ Istio 시스템 컴포넌트 상태:"
kubectl get pods -n istio-system
echo ""

# 3. 애플리케이션 팟 상태 확인
echo "3️⃣ 애플리케이션 팟 상태:"
kubectl get pods -o wide
echo ""

# 4. 사이드카 주입 확인
echo "4️⃣ 사이드카 프록시 주입 상태 확인:"
for pod in $(kubectl get pods -o name | grep -E "(user|product|cart|order|payment)"); do
    echo "📦 $pod:"
    kubectl get $pod -o jsonpath='{.spec.containers[*].name}' | tr ' ' '\n' | grep -E "(istio-proxy|envoy)" || echo "  ❌ 사이드카 없음"
done
echo ""

# 5. Istio 설정 상태 확인
echo "5️⃣ Istio 트래픽 관리 설정:"
echo "🚪 Gateway:"
kubectl get gateway -o wide
echo ""
echo "🔄 VirtualService:"
kubectl get virtualservice -o wide
echo ""
echo "🎯 DestinationRule:"
kubectl get destinationrule -o wide
echo ""

# 6. 외부 접속 정보
echo "6️⃣ 외부 접속 정보:"
GATEWAY_IP=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
if [ -z "$GATEWAY_IP" ]; then
    GATEWAY_IP=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
fi

if [ -n "$GATEWAY_IP" ]; then
    echo "🌍 External URL: http://$GATEWAY_IP"
    echo "🔗 API 테스트 예시:"
    echo "  - Health Check: curl http://$GATEWAY_IP/"
    echo "  - User API: curl http://$GATEWAY_IP/api/users"
    echo "  - Product API: curl http://$GATEWAY_IP/api/products"
else
    echo "❌ Gateway IP 할당되지 않음. LoadBalancer 생성 대기 중..."
fi
echo ""

# 7. 사이드카 주입 문제 해결
echo "7️⃣ 사이드카 주입 문제 해결:"
echo "네임스페이스 라벨 확인:"
kubectl get namespace default -o jsonpath='{.metadata.labels}' | grep istio-injection || echo "❌ default 네임스페이스에 istio-injection 라벨 없음"

if ! kubectl get namespace default -o jsonpath='{.metadata.labels}' | grep -q istio-injection; then
    echo "🔧 default 네임스페이스에 Istio 주입 라벨 추가..."
    kubectl label namespace default istio-injection=enabled --overwrite
fi

# 8. 팟 재시작 (사이드카 주입을 위해)
echo ""
echo "8️⃣ 사이드카 주입을 위한 팟 재시작:"
echo "⚠️  기존 팟들을 재시작하여 사이드카를 주입합니다..."
kubectl rollout restart deployment/user-service
kubectl rollout restart deployment/product-service
kubectl rollout restart deployment/cart-service
kubectl rollout restart deployment/order-service
kubectl rollout restart deployment/payment-service

echo "⏳ 재시작 완료 대기..."
kubectl rollout status deployment/user-service --timeout=300s
kubectl rollout status deployment/product-service --timeout=300s
kubectl rollout status deployment/cart-service --timeout=300s
kubectl rollout status deployment/order-service --timeout=300s
kubectl rollout status deployment/payment-service --timeout=300s

# 9. 최종 검증
echo ""
echo "9️⃣ 최종 사이드카 주입 검증:"
for pod in $(kubectl get pods -o name | grep -E "(user|product|cart|order|payment)"); do
    echo "📦 $pod:"
    CONTAINERS=$(kubectl get $pod -o jsonpath='{.spec.containers[*].name}')
    if echo "$CONTAINERS" | grep -q "istio-proxy"; then
        echo "  ✅ 사이드카 주입 완료"
    else
        echo "  ❌ 사이드카 주입 실패"
    fi
done

echo ""
echo "🎉 Istio 상태 확인 완료!"
echo ""
echo "📊 모니터링 접속 명령어:"
echo "kubectl port-forward -n istio-system svc/kiali 20001:20001"
echo "kubectl port-forward -n istio-system svc/grafana 3000:80"
echo "kubectl port-forward -n istio-system svc/jaeger-query 16686:16686"
