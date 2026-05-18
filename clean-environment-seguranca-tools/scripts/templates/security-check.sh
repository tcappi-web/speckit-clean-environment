#!/usr/bin/env bash
# ============================================================
# Clean Environment — scripts/security-check.sh
# Verificações de segurança automatizadas
# Instalado por /speckit.security-setup
# Executado por: pre-commit hook e hook after_implement
# ============================================================

set -uo pipefail   # 'e' deliberadamente omitido — queremos coletar TODOS os erros

ERRORS=0
WARNINGS=0

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

POST_IMPLEMENT=false
FEATURE_DIR=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --post-implement) POST_IMPLEMENT=true; shift ;;
    --feature) FEATURE_DIR="$2"; shift 2 ;;
    --feature=*) FEATURE_DIR="${1#*=}"; shift ;;
    *) shift ;;
  esac
done

echo -e "${BLUE}🔍 Clean Environment — Security Check${NC}"
echo "    Modo: $([ "$POST_IMPLEMENT" = true ] && echo 'post-implement' || echo 'pre-commit')"
[ -n "$FEATURE_DIR" ] && echo "    Feature: $FEATURE_DIR"
echo

# Detecta diretório raiz do projeto
ROOT="${PWD}"
[ -d "$ROOT/.git" ] || ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")

# Lista de paths a auditar
if [ "$POST_IMPLEMENT" = true ] && [ -n "$FEATURE_DIR" ]; then
  # Pós-implement: apenas arquivos modificados desde HEAD~ (último commit)
  TARGET=$(git diff --name-only HEAD~ 2>/dev/null | grep -E "\\.(ts|tsx|js|jsx|py|go|rs|java|rb|php)$" || true)
  [ -z "$TARGET" ] && TARGET=$(find src/ -type f 2>/dev/null | head -200)
else
  TARGET="src"
fi

# ============================================
# 1. .env files no stage
# ============================================
echo -e "${BLUE}→ [1/10] .env não está no stage…${NC}"
if git diff --cached --name-only 2>/dev/null | grep -E "^\.env$|^\.env\.local$|^\.env\..*\.local$|^\.env\.production$" >/dev/null; then
  echo -e "${RED}  ❌ CRÍTICO: tentando commitar arquivo .env real!${NC}"
  git diff --cached --name-only | grep -E "^\.env"
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}  ✓ OK${NC}"
fi

# ============================================
# 2. Secrets hardcoded
# ============================================
echo -e "${BLUE}→ [2/10] Secrets hardcoded…${NC}"
SECRETS_FOUND=$(grep -rnE "(sk_live|sk-ant-|sk-proj-|AIza[0-9A-Za-z\-_]{35}|ghp_[0-9a-zA-Z]{36}|github_pat_|glpat-|xoxb-|AKIA[0-9A-Z]{16})" $TARGET 2>/dev/null | grep -v ".env.example" || true)
if [ -n "$SECRETS_FOUND" ]; then
  echo -e "${RED}  ❌ CRÍTICO: padrões de secret detectados:${NC}"
  echo "$SECRETS_FOUND" | head -5
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}  ✓ OK${NC}"
fi

# ============================================
# 3. console.log
# ============================================
echo -e "${BLUE}→ [3/10] console.log…${NC}"
CONSOLE_COUNT=$(grep -rnE "console\\.(log|debug|info)" $TARGET --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null | wc -l | tr -d ' ')
if [ "$CONSOLE_COUNT" -gt 0 ]; then
  echo -e "${YELLOW}  ⚠️  $CONSOLE_COUNT console statements encontrados${NC}"
  grep -rnE "console\\.(log|debug|info)" $TARGET --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null | head -5
  WARNINGS=$((WARNINGS + 1))
else
  echo -e "${GREEN}  ✓ OK${NC}"
fi

# ============================================
# 4. dangerouslySetInnerHTML
# ============================================
echo -e "${BLUE}→ [4/10] XSS patterns…${NC}"
XSS_FOUND=$(grep -rn "dangerouslySetInnerHTML" $TARGET --include="*.tsx" --include="*.jsx" 2>/dev/null | grep -v "DOMPurify\\.sanitize" || true)
if [ -n "$XSS_FOUND" ]; then
  echo -e "${YELLOW}  ⚠️  dangerouslySetInnerHTML sem DOMPurify:${NC}"
  echo "$XSS_FOUND" | head -5
  WARNINGS=$((WARNINGS + 1))
else
  echo -e "${GREEN}  ✓ OK${NC}"
fi

# ============================================
# 5. localStorage com auth
# ============================================
echo -e "${BLUE}→ [5/10] localStorage inseguro…${NC}"
LS_FOUND=$(grep -rnE "(localStorage|sessionStorage)\\.(setItem|getItem)[^)]*?(token|auth|jwt|password|secret|session)" $TARGET --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null || true)
if [ -n "$LS_FOUND" ]; then
  echo -e "${RED}  ❌ Token/auth em localStorage (Cláusula I.1):${NC}"
  echo "$LS_FOUND" | head -5
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}  ✓ OK${NC}"
fi

# ============================================
# 6. URLs hardcoded
# ============================================
echo -e "${BLUE}→ [6/10] URLs hardcoded…${NC}"
URLS_FOUND=$(grep -rnE "['\"]https?://[a-z0-9.-]+\\.(com|net|org|io|app|dev)" $TARGET --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null | grep -vE "localhost|example\\.(com|org)|w3\\.org|placeholder" | head -10 || true)
if [ -n "$URLS_FOUND" ]; then
  echo -e "${YELLOW}  ⚠️  URLs hardcoded (considere env vars):${NC}"
  echo "$URLS_FOUND" | head -5
  WARNINGS=$((WARNINGS + 1))
else
  echo -e "${GREEN}  ✓ OK${NC}"
fi

# ============================================
# 7. SQL Injection patterns
# ============================================
echo -e "${BLUE}→ [7/10] SQL injection…${NC}"
SQL_FOUND=$(grep -rnE "(query|execute|raw)\\s*\\(\\s*[\"'\\\`].*\\\$\\{" $TARGET --include="*.ts" --include="*.js" 2>/dev/null || true)
if [ -n "$SQL_FOUND" ]; then
  echo -e "${RED}  ❌ Possível SQLi (Cláusula II.2):${NC}"
  echo "$SQL_FOUND" | head -5
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}  ✓ OK${NC}"
fi

# ============================================
# 8. Hash fraco em senhas
# ============================================
echo -e "${BLUE}→ [8/10] Hash fraco…${NC}"
WEAK_HASH=$(grep -rnE "createHash\\([\"'](md5|sha1|sha256)[\"']\\).*password|(md5|sha1|sha256)\\([^)]*password" $TARGET 2>/dev/null || true)
if [ -n "$WEAK_HASH" ]; then
  echo -e "${RED}  ❌ Hash fraco em senha (Cláusula I.2):${NC}"
  echo "$WEAK_HASH" | head -5
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}  ✓ OK${NC}"
fi

# ============================================
# 9. CORS wildcard
# ============================================
echo -e "${BLUE}→ [9/10] CORS wildcard…${NC}"
CORS_FOUND=$(grep -rnE "origin\\s*:\\s*['\"]\\*['\"]" $TARGET --include="*.ts" --include="*.js" 2>/dev/null || true)
if [ -n "$CORS_FOUND" ]; then
  echo -e "${YELLOW}  ⚠️  CORS com '*' (Cláusula III.4):${NC}"
  echo "$CORS_FOUND" | head -5
  WARNINGS=$((WARNINGS + 1))
else
  echo -e "${GREEN}  ✓ OK${NC}"
fi

# ============================================
# 10. Audit de dependências
# ============================================
echo -e "${BLUE}→ [10/10] npm audit…${NC}"
if [ -f "package.json" ] && command -v npm >/dev/null 2>&1; then
  AUDIT_JSON=$(npm audit --json 2>/dev/null || echo '{}')
  CRITICAL=$(echo "$AUDIT_JSON" | grep -oE '"critical":[0-9]+' | head -1 | grep -oE '[0-9]+' || echo "0")
  HIGH=$(echo "$AUDIT_JSON" | grep -oE '"high":[0-9]+' | head -1 | grep -oE '[0-9]+' || echo "0")
  if [ "$CRITICAL" -gt 0 ]; then
    echo -e "${RED}  ❌ $CRITICAL vulnerabilidades CRÍTICAS (Cláusula V.6)${NC}"
    ERRORS=$((ERRORS + 1))
  elif [ "$HIGH" -gt 0 ]; then
    echo -e "${YELLOW}  ⚠️  $HIGH vulnerabilidades ALTAS${NC}"
    WARNINGS=$((WARNINGS + 1))
  else
    echo -e "${GREEN}  ✓ OK${NC}"
  fi
elif [ -f "pyproject.toml" ] && command -v pip-audit >/dev/null 2>&1; then
  if pip-audit -q 2>/dev/null; then
    echo -e "${GREEN}  ✓ OK${NC}"
  else
    echo -e "${YELLOW}  ⚠️  pip-audit detectou vulnerabilidades${NC}"
    WARNINGS=$((WARNINGS + 1))
  fi
else
  echo -e "${YELLOW}  ⚠️  Audit de dependências não disponível (ferramenta ausente)${NC}"
fi

# ============================================
# Resultado
# ============================================
echo
echo "================================================"
if [ "$ERRORS" -gt 0 ]; then
  echo -e "${RED}❌ $ERRORS erro(s) crítico(s)${NC}"
  echo -e "${RED}❌ BLOQUEADO${NC}"
  echo
  echo "Para análise detalhada: /speckit.security-audit --mode=delta"
  exit 1
elif [ "$WARNINGS" -gt 0 ]; then
  echo -e "${YELLOW}⚠️  $WARNINGS aviso(s) — revise antes de commitar${NC}"
  echo -e "${GREEN}✓ Sem erros bloqueantes${NC}"
  exit 0
else
  echo -e "${GREEN}✅ Todos os checks passaram${NC}"
  exit 0
fi
