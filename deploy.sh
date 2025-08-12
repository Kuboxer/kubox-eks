#!/bin/bash

# 1. SecretProviderClass 적용
kubectl apply -f secret-provider-class.yaml

# 2. 시크릿 생성 테스트 Job
kubectl apply -f first-init.yaml
kubectl get pod -w
# 1/1 Running 확인

# 3. 시크릿 생성 확인
kubectl get secrets | grep kubox

# 4. 인프라 서비스 배포
kubectl apply -f mysql.yaml
kubectl apply -f redis.yaml
kubectl get pod -w
# 1/1 Running 확인

# 5. 애플리케이션 서비스 배포
kubectl apply -f user-service.yaml
kubectl apply -f product-service.yaml
kubectl apply -f cart-service.yaml
kubectl apply -f order-service.yaml
kubectl apply -f payment-service.yaml
kubectl get pod -w
# 1/1 Running 확인

# 6. 인그레스 배포
kubectl apply -f ingress.yaml

# 7. 최종 상태 확인
kubectl get pods

kubectl get svc

kubectl get secrets | grep kubox
