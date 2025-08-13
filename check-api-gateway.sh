#!/bin/bash

echo "🔗 API Gateway와 백엔드 연결 확인..."

# 1. Istio Gateway 상태 확인
echo "1️⃣ Istio Gateway 상태 확인:"
ISTIO_SVC=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
if [ -z "$ISTIO_SVC" ]; then
    ISTIO_SVC=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
fi

if [ -n "$ISTIO_SVC" ]; then
    echo "✅ Istio Gateway 사용 가능: $ISTIO_SVC"
    BACKEND_TYPE="istio"
else
    echo "❌ Istio Gateway 사용 불가"
    BACKEND_TYPE="alb"
fi

# 2. ALB 상태 확인
echo ""
echo "2️⃣ ALB 상태 확인:"
ALB_DNS=$(kubectl get ingress kubox-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
if [ -n "$ALB_DNS" ]; then
    echo "✅ ALB 사용 가능: $ALB_DNS"
else
    echo "❌ ALB 사용 불가"
fi

# 3. API Gateway Terraform 적용 추천
echo ""
echo "3️⃣ API Gateway 연결 설정:"
if [ "$BACKEND_TYPE" = "istio" ]; then
    echo "🎯 Istio Gateway가 감지되었습니다."
    echo "📋 다음 명령어로 API Gateway를 Istio Gateway에 연결하세요:"
    echo ""
    echo "cd /Users/ichungmin/Desktop/kubox-terraform/kubox-terraform/03-api-gateway"
    echo "terraform plan"
    echo "terraform apply"
    echo ""
    echo "🔗 연결 후 최종 접속 URL: https://api.kubox.shop"
else
    echo "🎯 ALB를 백엔드로 사용합니다."
    echo "📋 API Gateway가 기존 ALB에 연결됩니다."
fi

# 4. 연결 테스트 정보
echo ""
echo "4️⃣ 연결 테스트 정보:"
echo "Istio Gateway 직접 접속: http://$ISTIO_SVC (사용 가능 시)"
echo "ALB 직접 접속: http://$ALB_DNS (사용 가능 시)"
echo "API Gateway 접속: https://api.kubox.shop (terraform apply 후)"

# 5. 백엔드 우선순위 정보
echo ""
echo "5️⃣ API Gateway 백엔드 우선순위:"
echo "1순위: Istio Gateway (인터넷 직접 연결)"
echo "2순위: ALB (VPC Link 연결)"
echo ""
echo "현재 상태: $BACKEND_TYPE 사용"

echo ""
echo "🚀 API Gateway 연결을 위해 terraform apply를 실행하세요!"
