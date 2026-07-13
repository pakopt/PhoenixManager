#!/usr/bin/env bash
# Guia interactivo para o primeiro upload na Play Console (quando a conta activar).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STORE="$ROOT/build/release/store/android"
AAB="$ROOT/build/release/mobile/android/phoenix_manager.aab"
PRIVACY="https://pakopt.github.io/PhoenixManager/privacy.html"

echo "════════════════════════════════════════"
echo "  Play Console — Dia 1 (teste interno)"
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

  1. https://play.google.com/console
     → Criar app → Jogo, gratuito, PT
     → Package: com.phoenix.manager (fixo na 1.ª release)

  2. Política → Política de privacidade
     → $PRIVACY

  3. Testar e lançar → Teste interno → Criar versão
     → Carregar: $AAB

  4. Presença na loja → Ficha principal
     → Textos: ./scripts/play_console_brief.sh
     → Gráficos: $STORE/

  5. Política → Classificação de conteúdo (IARC)
     → Respostas: docs/STORE.md §6

  6. Política → Segurança dos dados
     → Não recolhe dados — docs/STORE.md §8

  7. Testadores → Lista de emails → Link de adesão no telemóvel

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
  if [[ "${ans,,}" == "s" || "${ans,,}" == "sim" ]]; then
    "$ROOT/scripts/play_console_brief.sh"
  fi
else
  echo "Textos: ./scripts/play_console_brief.sh"
fi
