#!/usr/bin/env bash
# Resumo copy-paste para Microsoft Partner Center + verificação de assets locais.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MSIX="$ROOT/build/release/store/windows/phoenix_manager.msix"
STORE="$ROOT/build/release/store/desktop"
ICON="$ROOT/apps/phoenix_manager/assets/branding/icon.png"
PRIVACY_URL="https://pakopt.github.io/PhoenixManager/privacy.html"
CONTACT="pakopt7@gmail.com"
IDENTITY_NAME="PhoenixManager.PhoenixManager"
PUBLISHER="CN=4402D5F1-A78E-42D6-B8A3-BAEBB8F0513B"
PUBLISHER_DISPLAY="Phoenix Manager"
DISPLAY_NAME="Project Phoenix Manager"

# shellcheck source=read_app_version.sh
source "$ROOT/scripts/read_app_version.sh"
# shellcheck source=msix_version.sh
source "$ROOT/scripts/msix_version.sh"

ok=0
warn=0
pass() { echo "  OK   $1"; ok=$((ok + 1)); }
fail_msg() { echo "  !!   $1"; warn=$((warn + 1)); }

echo "════════════════════════════════════════"
echo "  Partner Center — brief (Project Phoenix Manager / Windows)"
echo "════════════════════════════════════════"
echo ""

echo "==> Ficheiros locais"
if [[ -f "$MSIX" ]]; then
  pass "MSIX $(ls -lh "$MSIX" | awk '{print $5}') — $MSIX"
else
  fail_msg "MSIX em falta — ./scripts/build_msix.sh (Windows)"
fi
if [[ -f "$ICON" ]]; then pass "icon.png (logo Store)"; else fail_msg "icon — apps/phoenix_manager/assets/branding/icon.png"; fi
shots=0
if [[ -d "$STORE/screenshots" ]]; then
  shots=$(ls "$STORE/screenshots"/*.png 2>/dev/null | wc -l | tr -d ' ')
fi
if [[ "$shots" -ge 2 ]]; then
  pass "$shots screenshots desktop"
else
  fail_msg "screenshots ($shots) — ./scripts/capture_desktop_screenshots.sh"
fi

echo ""
echo "==> Identidade da app (fixo na 1.ª release)"
cat <<EOF
  Identity Name:          $IDENTITY_NAME
  Publisher:              $PUBLISHER
  Publisher display name:   $PUBLISHER_DISPLAY
  Display name:             $DISPLAY_NAME
  msix_version:             $MSIX_VERSION
  Flutter version name:     $VERSION_NAME
  Flutter version code:     $VERSION_CODE
  Tipo:                     Jogo, gratuito
  Contacto:                 $CONTACT
  Privacidade:              $PRIVACY_URL
  GitHub:                   https://github.com/pakopt/PhoenixManager
EOF

echo ""
echo "==> Ficha da loja (copiar para Partner Center → Store listings)"
cat <<EOF

Título:
Project Phoenix Manager

Descrição curta (máx. ~100 caracteres):
Gestor de futebol offline para PC Windows: liga, taça, mercado, plantel, treinos e finanças.

Descrição completa:
Project Phoenix Manager é um jogo de gestão de futebol para PC Windows. Conduz um clube numa liga completa com taça eliminatória, temporadas, promoções e estatísticas. Tudo funciona no computador, sem conta de utilizador e sem ligação à Internet após a instalação.

O QUE PODES FAZER NO JOGO

• Escolher ou continuar uma carreira — vários slots de save locais
• Gerir o plantel — ver jogadores, atributos, forma, lesões e contratos
• Planear treinos e academia de jovens
• Negociar no mercado de transferências e renovar contratos
• Acompanhar finanças do clube — salários, receitas, resultado de época
• Ver calendário de jogos, classificação da liga e taça
• Jogar em Modo Express — simular jornadas rapidamente com resultados animados
• Jogar em Modo Diretor — gestão completa com alertas antes de cada jogo
• Ler relatos completos das partidas e acompanhar a simulação

COMO FUNCIONA

O jogo usa o motor Phoenix Simulation Engine (PSE v$VERSION_NAME) para simular partidas, economia do clube e progressão da temporada. Os dados da carreira ficam guardados apenas no teu PC — não enviamos informação para servidores externos.

CARACTERÍSTICAS

• Gratuito, sem anúncios
• Sem compras dentro da app
• Sem registo ou login
• Offline-first — joga em viagem ou sem Wi‑Fi
• Política de privacidade: não recolhemos dados pessoais

PARA QUEM É

Ideal para fãs de jogos de gestão desportiva (football manager) que preferem uma experiência simples, rápida e totalmente offline no PC.

REQUISITOS

Windows 10 versão 1809 ou superior (64 bits).

CONTACTO

Questões ou feedback: $CONTACT

Categoria sugerida: Jogos → Desporto (ou Simulação)
EOF

echo ""
echo "==> Notas da versão (exemplo para submission)"
cat <<EOF

v$VERSION_NAME — gestão offline com PSE para PC Windows; onboarding e novidades para beta.
- Roteiro beta auto-marca ao jogar / guardar / plantel / feedback
- Aviso ao carregar save com alterações por guardar
- «Novidades» ao actualizar · Express / Diretor
- Saves locais · sem conta · sem anúncios
- Motor Phoenix Simulation Engine v$VERSION_NAME
- msix_version: $MSIX_VERSION

EOF

echo "==> Privacidade e dados (resumo)"
cat <<EOF
  Recolhe/partilha dados?     Não
  Analytics / anúncios?        Não
  Compras in-app?              Não
  Saves:                       Só no PC (ficheiros locais)
  Eliminação:                  Definições → Apps → Desinstalar / limpar dados
  URL privacidade:             $PRIVACY_URL
  Detalhe:                     docs/STORE.md (secção Microsoft Store)

EOF

echo "==> Age rating (resumo)"
cat <<EOF
  Violência:     desporto simulado, sem violência realista
  Sexualidade:   nenhuma
  Chat/redes:    nenhuma (offline)
  Apostas $:      nenhuma (sem dinheiro real)
  Público-alvo:  13+; não dirigida a crianças
  Detalhe:       docs/STORE.md

EOF

echo "==> Ordem no Partner Center (quando conta activa)"
cat <<EOF
  1. Apps and games → criar/reservar app → nome: $DISPLAY_NAME
  2. Product identity → confirmar Name/Publisher (valores acima)
  3. Packages → upload MSIX (msix_version $MSIX_VERSION)
  4. Store listings → textos + screenshots ($STORE/screenshots/)
  5. Age ratings + privacy policy URL: $PRIVACY_URL
  6. Pricing → gratuito → Submit for certification

  Build MSIX (Windows): ./scripts/build_msix.sh
  ZIP upload (opcional): ./scripts/package_msix_store.sh
  Screenshots: ./scripts/capture_desktop_screenshots.sh
  Guia completo: docs/STORE.md (secção Microsoft Store)

EOF

echo "────────────────────────────────────────"
if [[ $warn -eq 0 ]]; then
  echo "Assets: $ok OK — pronto para upload quando o MSIX estiver buildado."
else
  echo "Assets: $ok OK, $warn em falta — corre os scripts indicados."
fi
