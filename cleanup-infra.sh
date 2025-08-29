#!/bin/bash
kubectl delete -f argocd-application.yaml

kubectl delete -f istio/gateway.yaml
kubectl delete -f istio/virtual-service.yaml
kubectl delete -f istio/destination-rules.yaml

kubectl delete -f app-services/mysql.yaml
kubectl delete -f app-services/redis.yaml
kubectl delete pvc -n app-services --all

kubectl delete svc -n app-services --all
kubectl delete rollout -n app-services --all

kubectl delete -f app-services/secret-provider-class.yaml


echo "====제거 완료!!!!!!===="




