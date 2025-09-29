#!/bin/bash
kubectl delete -f argocd-application.yaml
kubectl delete rollout -n app-services --all

kubectl delete -f app-services/secret-provider-class.yaml
kubectl delete secret -n app-services --all 

kubectl delete -f istio/gateway.yaml
kubectl delete -f istio/virtual-service.yaml
kubectl delete -f istio/destination-rules.yaml

echo ""
echo "====제거 완료!!!!!!===="




