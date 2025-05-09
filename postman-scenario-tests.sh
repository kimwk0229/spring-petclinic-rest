#!/bin/zsh

# ------------------- Constants & Config ---------------------------------------------------
COLLECTION="./src/test/postman/petclinic-scenario-test.postman_collection.json"
ENVIRONMENT="./src/test/postman/petclinic-env.postman_environment.json"
REPORT_DIR="./src/test/postman/reports"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

REQUIRED_CMDS=("node" "jq")

mkdir -p "$REPORT_DIR"

# --------------------------- Checking required dependecies ------------------------------ 
for CMD in "${REQUIRED_CMDS[@]}"; do
  if ! command -v "$CMD" &>/dev/null; then
    echo -e "${RED}❌ 에러: '$CMD' 설치되지 않았습니다.${NC}"
    echo -e "${YELLOW}💡 아래 명령어로 설치:${NC}"
    echo -e "${YELLOW}  • brew install $CMD          # macOS${NC}"
    echo -e "${YELLOW}  • sudo apt install $CMD     # Debian/Ubuntu${NC}"
    echo -e "${YELLOW}  • sudo dnf install $CMD     # Fedora${NC}"
    echo -e "${YELLOW}  • sudo pacman -S $CMD       # Arch Linux${NC}"
    exit 1
  fi
done

# -------------- Getting folder (scenarios) names from collection ---------------------------
SCENARIOS=""
while IFS= read -r name; do
  SCENARIOS="${SCENARIOS}
${name}"
done <<EOF
$(jq -r '.item[].name' "$COLLECTION")
EOF

# ----------- Checking if there's folders (scenarios) in collection -------------------------
if [ ${#SCENARIOS[@]} -eq 0 ]; then
  echo -e "${RED}❌ Error: No folders (scenarios) found in collection.${NC}"
  exit 1
fi

# ---------------- Announce & list scenarios ---------------------------------------------
echo ""
echo -e "${GREEN}🐾 시작 Petclinic 시나리오 테스트 Newman...${NC}"
sleep 1
echo ""

echo "$SCENARIOS" | while IFS= read -r SCENARIO; do
  [ -z "$SCENARIO" ] && continue
  echo -e "${YELLOW}🔎 시나리오: $SCENARIO ${NC}"
  sleep 0.7
done

# ---------------- Running tests with Newman ------------------------------------
echo ""
echo -e "${GREEN}테스트 실행...${NC}"
echo ""

npx -p newman -p newman-reporter-htmlextra newman run "$COLLECTION" \
  -e "$ENVIRONMENT" \
  --reporters cli,htmlextra \
  --reporter-htmlextra-export "$REPORT_DIR/report.html" \
  --timeout-request 5000 \

  EXIT_CODE=$?

# --------------- Checking if the test failed  ----------------------------------------------------
if [ $EXIT_CODE -ne 0 ]; then
  echo -e "${RED}❌ Newman 테스트 실패. HTML 리포트: $REPORT_DIR/report.html${NC}"
  exit 1
fi

# -------------- Done when is success --------------------------------------------------------------------
echo ""
echo -e "${YELLOW}📄 HTML 리포트 생성됨: $REPORT_DIR/report.html${NC}"
echo ""
