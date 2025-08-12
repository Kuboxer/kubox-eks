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
kubectl delete -f secret-provider-class.yaml --ignore-not-found=true
kubectl delete pvc --all
kubectl delete -f secrets-test.yaml

# CSI Driver 권한 부여
kubectl apply -f csi-driver-rbac.yaml

# CSI Driver 재시작
kubectl rollout restart daemonset/csi-secrets-store-secrets-store-csi-driver -n kube-system

# 2. 올바른 SecretProviderClass 적용
kubectl apply -f secret-provider-class.yaml
kubectl get SecretProviderClass

# 3. 시크릿 생성 테스트 Job
kubectl apply -f secrets-test.yaml
kubectl get pod -w
# running -> completed 확인 후 다음 진행

# 4. 시크릿 생성 확인
kubectl get secrets | grep kubox

# 5. 인프라 서비스 배포
kubectl apply -f mysql.yaml
kubectl apply -f redis.yaml

# 6. 애플리케이션 서비스 배포
kubectl apply -f user-service.yaml
kubectl apply -f product-service.yaml
kubectl apply -f cart-service.yaml
kubectl apply -f order-service.yaml
kubectl apply -f payment-service.yaml

# 7. 인그레스 배포
kubectl apply -f ingress.yaml

# 8. 최종 상태 확인
kubectl get pods

kubectl get svc

kubectl get secrets | grep kubox
