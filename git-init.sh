#!/bin/bash

# Kubox EKS Git 저장소 초기화 스크립트

echo "🔧 Kubox EKS Git 저장소 초기화..."

# Git 저장소 초기화
if [ ! -d ".git" ]; then
    git init
    echo "✅ Git 저장소 초기화 완료"
else
    echo "📁 Git 저장소가 이미 존재합니다"
fi

# 모든 파일 추가
git add .

# 첫 커밋
git commit -m "🚀 Initial commit: Kubox EKS Kubernetes configurations

- Add ConfigMap and Secret for environment variables
- Add PVC for data persistence (MySQL 10Gi, Redis 1Gi)
- Add MySQL with initialization script
- Add Redis cache
- Add 5 microservices with proper ports and IRSA
- Add deployment and cleanup scripts
- Add comprehensive documentation"

echo ""
echo "✅ 초기 커밋 완료!"
echo ""
echo "📋 다음 단계:"
echo "  1. GitHub에서 새 저장소 생성"
echo "  2. 원격 저장소 연결:"
echo "     git remote add origin https://github.com/choiyunha/kubox-eks.git"
echo "  3. 푸시:"
echo "     git push -u origin main"
echo ""
echo "🔄 향후 업데이트:"
echo "  git add ."
echo "  git commit -m \"업데이트 내용\""
echo "  git push"
