#!/usr/bin/env bash
# Guia interactivo para o primeiro upload na Play Console (quando a conta activar).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STORE="$ROOT/build/release/store/android"
AAB="$ROOT/build/release/mobile/android/phoenix_manager.aab"
PRIVACY="https://pakopt.github.io/PhoenixManager/privacy.html"
# shellcheck source=read_app_version.sh
source "$ROOT/scripts/read_app_version.sh"

echo "════════════════════════════════════════"
echo "  Play Console — Dia 1 (teste interno)"
echo "  Versão: $VERSION_FULL  ·  Package: com.phoenix.manager"
echo "════════════════════════════════════════"
echo ""
echo "Pré-requisito: conta Play Developer APROVADA (não em verificação)."
echo ""

"$ROOT/scripts/phase_e_status.sh" 2>&1 | sed -n '1,22p'

echo ""
echo "==> Assets"
for f in "$AAB" "$STORE/icon-512.png" "$STORE/feature-graphic.png"; do
  [[ -f "$f" ]] && echo "  OK   $f" || echo "  !!   em falta: $f"
done
n=0
[[ -d "$STORE/screenshots" ]] && n=$(ls "$STORE/screenshots"/*.png 2>/dev/null | wc -l | tr -d ' ')
echo "  OK   $n screenshots"

if [[ ! -f "$STORE/phoenix-manager-play-upload.zip" ]]; then
  echo ""
  echo "==> A gerar ZIP de upload..."
  "$ROOT/scripts/package_play_store.sh" 2>&1 | tail -2
fi

echo ""
echo "==> Passos na Play Console (ordem)"
cat <<EOF

  (Se a app / teste fechado já existir, salta 1–6 e vai ao 7–9.)

  1. https://play.google.com/console
     → Criar app → Jogo, gratuito, PT
     → Package: com.phoenix.manager (fixo na 1.ª release)

  2. Política → Política de privacidade
     → $PRIVACY

  3. Testar e lançar → Teste fechado (ou interno) → Criar versão
     → Carregar: $AAB

  4. Presença na loja → Ficha principal
     → Textos: ./scripts/play_console_brief.sh
     → Gráficos: $STORE/

  5. Política → Classificação de conteúdo (IARC)
     → Respostas: docs/STORE.md §6

  6. Política → Segurança dos dados
     → Não recolhe dados — docs/STORE.md §8

  7. Teste fechado → Testadores → 14–16 emails + link de adesão
     → Convite: ./scripts/play_testers_invite.sh 'URL_DO_LINK'
     → Cada um: «Tornar-me testador» + instalar pela Play Store

  8. Manter ≥12 opted-in durante 14 dias contínuos (docs/STORE.md §9c)

  9. Dashboard → candidatar acesso a produção → depois promover (§10)

  Guia completo: docs/STORE.md

EOF

if [[ "$(uname -s)" == "Darwin" ]]; then
  echo "==> Abrir pastas no Finder"
  open "$STORE" 2>/dev/null || true
  open "$(dirname "$AAB")" 2>/dev/null || true
fi

if [[ -t 0 ]]; then
  echo "Copiar textos agora? [s/N]"
  read -r ans
  # Bash 3.2 (macOS) não tem ${var,,} — normalizar com tr.
  ans_lc="$(printf '%s' "$ans" | tr '[:upper:]' '[:lower:]')"
  if [[ "$ans_lc" == "s" || "$ans_lc" == "sim" || "$ans_lc" == "y" || "$ans_lc" == "yes" ]]; then
    "$ROOT/scripts/play_console_brief.sh"
  fi
else
  echo "Textos: ./scripts/play_console_brief.sh"
fi
