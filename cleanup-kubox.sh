#!/bin/bash
NS="app-services"
echo "🧹 Kubox 쇼핑몰 + Istio 완전 삭제 시작..."

# 1. Istio 설정 삭제
echo "1️⃣ Istio 트래픽 관리 설정 삭제..."
kubectl delete -f istio/destination-rules.yaml --ignore-not-found=true
kubectl delete -f istio/virtual-service.yaml --ignore-not-found=true
kubectl delete -f istio/gateway.yaml --ignore-not-found=true
echo "✅ Istio 설정 삭제 완료"

# 2. 애플리케이션 서비스 삭제
echo "2️⃣ MSA 애플리케이션 삭제..."
kubectl delete -f app-services/payment-service.yaml --ignore-not-found=true
kubectl delete -f app-services/order-service.yaml --ignore-not-found=true
kubectl delete -f app-services/cart-service.yaml --ignore-not-found=true
kubectl delete -f app-services/product-service.yaml --ignore-not-found=true
kubectl delete -f app-services/user-service.yaml --ignore-not-found=true

echo "⏳ 애플리케이션 Pod 종료 대기..."
kubectl wait -n "$NS" --for=delete pod -l app=payment-service --timeout=120s --ignore-not-found=true
kubectl wait -n "$NS" --for=delete pod -l app=order-service --timeout=120s --ignore-not-found=true
kubectl wait -n "$NS" --for=delete pod -l app=cart-service --timeout=120s --ignore-not-found=true
kubectl wait -n "$NS" --for=delete pod -l app=product-service --timeout=120s --ignore-not-found=true
kubectl wait -n "$NS" --for=delete pod -l app=user-service --timeout=120s --ignore-not-found=true
echo "✅ 애플리케이션 서비스 삭제 완료"

# 3. 인프라 서비스 삭제
echo "3️⃣ 인프라 서비스 삭제 (MySQL, Redis)..."
kubectl delete -f app-services/redis.yaml --ignore-not-found=true
kubectl delete -f app-services/mysql.yaml --ignore-not-found=true

echo "⏳ 인프라 서비스 종료 대기..."
kubectl wait -n "$NS" --for=delete pod/redis-0 --timeout=120s --ignore-not-found=true
kubectl wait -n "$NS" --for=delete pod/mysql-0 --timeout=120s --ignore-not-found=true
echo "✅ 인프라 서비스 삭제 완료"

# 4. PVC 삭제 (데이터 완전 삭제)
echo "4️⃣ 영구 볼륨 및 데이터 삭제..."
kubectl delete pvc -n "$NS" --all --ignore-not-found=true
echo "✅ 영구 볼륨 삭제 완료"

# 5. 시크릿 삭제
echo "5️⃣ Kubernetes 시크릿 삭제..."
kubectl delete secret -n "$NS" kubox-common-secret --ignore-not-found=true
kubectl delete secret -n "$NS" kubox-bootpay-secret --ignore-not-found=true
kubectl delete secret -n "$NS" kubox-mysql-secret --ignore-not-found=true
echo "✅ 시크릿 삭제 완료"

# 6. SecretProviderClass 삭제
echo "6️⃣ AWS Secrets Manager 연동 설정 삭제..."
kubectl delete -f app-services/secret-provider-class.yaml --ignore-not-found=true

# 7. 테스트 Pod 삭제
echo "7️⃣ 테스트 리소스 정리..."
kubectl delete -f app-services/first-init.yaml --ignore-not-found=true

# 8. HPA 삭제
echo "8️⃣ HPA (Horizontal Pod Autoscaler) 삭제..."
kubectl delete hpa -n "$NS" --all --ignore-not-found=true
echo "✅ HPA 삭제 완료"

# 10. 최종 상태 확인
echo "삭제 상태 확인..."
echo ""
echo "📋 남은 리소스 확인:"
echo "Pods:"
kubectl get pods -n "$NS" 2>/dev/null || echo "  ✅ Pod 없음"
echo "Services:"
kubectl get svc -n "$NS" 2>/dev/null || echo "  ✅ Service 없음"
echo "PVCs:"
kubectl get pvc -n "$NS" 2>/dev/null || echo "  ✅ PVC 없음"
echo "Secrets:"
kubectl get secret -n "$NS" | grep kubox 2>/dev/null || echo "  ✅ Kubox Secret 없음"
echo "HPA:"
kubectl get hpa -n "$NS" 2>/dev/null || echo "  ✅ HPA 없음"