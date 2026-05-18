#!/bin/sh
# ============================================================
# Clean Environment — Husky pre-commit
# Instalado por /speckit.security-setup
# ============================================================
. "$(dirname "$0")/_/husky.sh"

# 1. Security check (Constituição V.5)
if [ -f scripts/security-check.sh ]; then
  bash scripts/security-check.sh || exit 1
else
  echo "⚠️  scripts/security-check.sh não encontrado. Execute /speckit.security-setup."
fi

# 2. lint-staged (se configurado)
if [ -f package.json ] && grep -q '"lint-staged"' package.json; then
  npx lint-staged || exit 1
fi

exit 0
