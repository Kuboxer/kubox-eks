#!/bin/bash

set -e

echo "=== Kubox 완전 자동화 배포 (시크릿 직접 생성) ==="

# 1. 기존 리소스 정리
kubectl delete -f ingress.yaml
kubectl delete jobs --all --ignore-not-found=true
kubectl delete -f mysql.yaml --ignore-not-found=true
kubectl delete -f redis.yaml --ignore-not-found=true
kubectl delete -f user-service.yaml --ignore-not-found=true
kubectl delete -f product-service.yaml --ignore-not-found=true
kubectl delete -f cart-service.yaml --ignore-not-found=true
kubectl delete -f order-service.yaml --ignore-not-found=true
kubectl delete -f payment-service.yaml --ignore-not-found=true
kubectl delete secrets --all --ignore-not-found=true
kubectl delete configmaps --all --ignore-not-found=true
kubectl delete -f secret-provider-class.yaml --ignore-not-foud=true
kubectl delete pvc --all

# 2. 올바른 SecretProviderClass 적용
kubectl apply -f secret-provider-class-correct.yaml

# 3. 시크릿 생성 테스트 Job
kubectl apply -f secrets-test.yaml

# 4. 시크릿 생성 확인
kubectl get secrets | grep kubox

# 5. 인프라 서비스 배포
kubectl apply -f mysql-secrets.yaml
kubectl apply -f redis-simple.yaml

# 6. 애플리케이션 서비스 배포
kubectl apply -f user-service-secrets.yaml
kubectl apply -f product-service-secrets.yaml
kubectl apply -f cart-service-secrets.yaml
kubectl apply -f order-service-secrets.yaml
kubectl apply -f payment-service-secrets.yaml

# 7. 인그레스 배포
kubectl apply -f ingress.yaml

# 8. 최종 상태 확인
kubectl get pods

kubectl get svc

kubectl get secrets | grep kubox
