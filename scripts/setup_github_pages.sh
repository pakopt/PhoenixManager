#!/usr/bin/env bash
# Inicializa git, valida segredos, e mostra passos para GitHub Pages (privacidade Play Store).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

RED='\033[0;31m'
GRN='\033[0;32m'
YLW='\033[1;33m'
NC='\033[0m'

fail=0
warn_secret() {
  echo -e "${RED}SEGREDO:${NC} $1"
  fail=$((fail + 1))
}

if [[ ! -d .git ]]; then
  echo "==> git init"
  git init -b main
else
  echo "==> Repositório git já existe ($(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?'))"
fi

echo ""
echo "==> Verificar ficheiros sensíveis (não devem ir para o GitHub)"
SENSITIVE_PATTERNS=(
  "apps/phoenix_manager/android/key.properties"
  "apps/phoenix_manager/android/keystore"
  "steam/steam.env"
  ".env"
  ".env.local"
)
for path in "${SENSITIVE_PATTERNS[@]}"; do
  if [[ -e "$ROOT/$path" ]]; then
    if git check-ignore -q "$path" 2>/dev/null; then
      echo -e "  ${GRN}OK${NC}   $path (ignorado pelo .gitignore)"
    else
      warn_secret "$path existe mas NÃO está no .gitignore"
    fi
  fi
done

if [[ $fail -gt 0 ]]; then
  echo ""
  echo "Corrige o .gitignore antes de fazer push."
  exit 1
fi

REMOTE="${GITHUB_REMOTE:-}"
USER="${GITHUB_USER:-}"
REPO="${GITHUB_REPO:-Project-Phoenix-Manager}"

if [[ -z "$REMOTE" && -n "$USER" ]]; then
  REMOTE="https://github.com/${USER}/${REPO}.git"
fi

echo ""
echo "==> Próximos passos (manual)"
cat <<EOF

1. Criar repo vazio no GitHub (sem README/licença se já tens código local):
   https://github.com/new
   Nome sugerido: ${REPO}

2. Primeiro commit e push:
   git add -A
   git status   # confirmar que key.properties / keystore NÃO aparecem
   git commit -m "chore: v0.8.0-alpha — Fase E lançamento"
   git remote add origin ${REMOTE:-https://github.com/<utilizador>/${REPO}.git}
   git push -u origin main

3. GitHub Pages (Settings → Pages → Build: GitHub Actions)
   O workflow .github/workflows/pages.yml publica docs/site/ em cada push.

4. URL privacidade (project site):
   https://<utilizador>.github.io/${REPO}/privacy.html

5. Colar URL na Play Console e actualizar docs/STORE.md

Variáveis opcionais para este script:
   GITHUB_USER=teuuser GITHUB_REPO=${REPO} ./scripts/setup_github_pages.sh

EOF

if git rev-parse HEAD >/dev/null 2>&1; then
  echo "Estado: $(git log -1 --oneline)"
else
  echo -e "${YLW}Ainda sem commits — corre os comandos acima.${NC}"
fi

if [[ -d "$ROOT/build/release/store/android/screenshots" ]]; then
  n=$(ls "$ROOT/build/release/store/android/screenshots"/*.png 2>/dev/null | wc -l | tr -d ' ')
  echo ""
  echo "Assets loja: $n screenshots em build/release/store/android/"
fi
