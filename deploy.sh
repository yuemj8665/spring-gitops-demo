#!/bin/bash

# ============================================
# 자동 배포 스크립트
# 사용법: ./deploy.sh [커밋 메시지]
# ============================================

set -e  # 에러 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 프로젝트 디렉토리로 이동
cd "$(dirname "$0")"

# 변수 설정
IMAGE_NAME="java-practice_20260125"
TAG=$(date +%Y%m%d_%H%M)
COMMIT_MSG="${1:-Deploy version $TAG}"

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  자동 배포 시작${NC}"
echo -e "${YELLOW}  이미지: ${IMAGE_NAME}:${TAG}${NC}"
echo -e "${YELLOW}========================================${NC}"

# 1. Docker 이미지 빌드
echo -e "\n${GREEN}[1/5] Docker 이미지 빌드 중...${NC}"
docker build -t ${IMAGE_NAME}:${TAG} .

# 2. kustomization.yaml 업데이트 (dev)
echo -e "\n${GREEN}[2/5] Dev 환경 이미지 태그 업데이트...${NC}"
sed -i '' "s/newTag: .*/newTag: \"${TAG}\"/" k8s/overlays/dev/kustomization.yaml
echo "  → k8s/overlays/dev/kustomization.yaml 업데이트 완료"

# 3. kustomization.yaml 업데이트 (prod) - 선택적
read -p "Prod 환경도 업데이트할까요? (y/N): " update_prod
if [[ "$update_prod" =~ ^[Yy]$ ]]; then
    sed -i '' "s/newTag: .*/newTag: \"${TAG}\"/" k8s/overlays/prod/kustomization.yaml
    echo "  → k8s/overlays/prod/kustomization.yaml 업데이트 완료"
fi

# 4. Git 커밋 & 푸시
echo -e "\n${GREEN}[3/5] Git 커밋 중...${NC}"
git add .
git commit -m "$COMMIT_MSG"

echo -e "\n${GREEN}[4/5] Git 푸시 중...${NC}"
git push

# 5. 완료 메시지
echo -e "\n${GREEN}[5/5] 배포 완료!${NC}"
echo -e "${YELLOW}========================================${NC}"
echo -e "  이미지 태그: ${GREEN}${TAG}${NC}"
echo -e "  커밋 메시지: ${COMMIT_MSG}"
echo -e "${YELLOW}========================================${NC}"
echo -e "\n${GREEN}ArgoCD가 자동으로 변경사항을 감지하여 배포합니다.${NC}"
echo -e "수동 동기화: ArgoCD UI → java-practice-dev → SYNC"
echo ""
