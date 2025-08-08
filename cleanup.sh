#!/bin/bash

# Kubox 쇼핑몰 서비스 정리 스크립트

echo "🧹 Kubox 쇼핑몰 서비스 정리 중..."

echo "🛍️ 마이크로서비스 삭제..."
kubectl delete -f user-service.yaml --ignore-not-found
kubectl delete -f product-service.yaml --ignore-not-found
kubectl delete -f cart-service.yaml --ignore-not-found
kubectl delete -f order-service.yaml --ignore-not-found
kubectl delete -f payment-service.yaml --ignore-not-found

echo "📦 데이터베이스 및 캐시 삭제..."
kubectl delete -f mysql.yaml --ignore-not-found
kubectl delete -f redis.yaml --ignore-not-found

echo "⏳ 정리 완료 대기..."
sleep 10

echo "📊 정리 상태 확인..."
echo "================================"
echo "Remaining Pods:"
kubectl get pods
echo ""
echo "Remaining Services:"
kubectl get services
echo ""
echo "Remaining PVCs:"
kubectl get pvc

echo ""
echo "✅ 정리 완료!"
