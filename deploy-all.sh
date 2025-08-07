#!/bin/bash

# Kubox 쇼핑몰 서비스 전체 배포 스크립트

echo "🚀 Kubox 쇼핑몰 서비스 배포 시작..."

echo "⚙️ 1. ConfigMap, Secret, PVC 배포..."
kubectl apply -f configmap.yaml
kubectl apply -f secrets.yaml
kubectl apply -f pvc.yaml

echo "📦 2. 데이터베이스 및 캐시 배포..."
kubectl apply -f mysql-db.yaml
kubectl apply -f redis-cache.yaml

echo "⏳ 데이터베이스 준비 대기 (60초)..."
sleep 60

echo "🛍️ 3. 마이크로서비스 배포..."
kubectl apply -f user-service.yaml
kubectl apply -f product-service.yaml

echo "⏳ 기본 서비스 시작 대기 (30초)..."
sleep 30

kubectl apply -f cart-service.yaml
kubectl apply -f order-service.yaml
kubectl apply -f payment-service.yaml

echo "⏳ 전체 서비스 시작 대기 (60초)..."
sleep 60

echo "📊 4. 배포 상태 확인..."
echo "================================"
echo "Pods:"
kubectl get pods
echo ""
echo "Services:"
kubectl get services
echo ""
echo "PVCs:"
kubectl get pvc

echo ""
echo "✅ 배포 완료!"
echo ""
echo "📋 서비스 확인 명령어:"
echo "  kubectl get pods"
echo "  kubectl get services"
echo "  kubectl logs <pod-name>"
echo ""
echo "🧹 삭제 명령어:"
echo "  ./cleanup.sh"
