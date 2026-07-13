#!/usr/bin/env bash
# Resumo copy-paste para Play Console + verificação de assets locais.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
AAB="$ROOT/build/release/mobile/android/phoenix_manager.aab"
STORE="$ROOT/build/release/store/android"
PRIVACY_URL="https://pakopt.github.io/PhoenixManager/privacy.html"
CONTACT="pakopt7@gmail.com"
PACKAGE="com.phoenix.manager"
VERSION_NAME="0.8.0-alpha"
VERSION_CODE="1"

ok=0
warn=0
pass() { echo "  OK   $1"; ok=$((ok + 1)); }
fail_msg() { echo "  !!   $1"; warn=$((warn + 1)); }

echo "════════════════════════════════════════"
echo "  Play Console — brief (Project Phoenix Manager)"
echo "════════════════════════════════════════"
echo ""

echo "==> Ficheiros locais"
if [[ -f "$AAB" ]]; then
  pass "AAB $(ls -lh "$AAB" | awk '{print $5}') — $AAB"
else
  fail_msg "AAB em falta — ./scripts/build_mobile.sh android"
fi
if [[ -f "$STORE/icon-512.png" ]]; then pass "icon-512.png"; else fail_msg "icon-512 — ./scripts/capture_play_screenshots_auto.sh"; fi
if [[ -f "$STORE/feature-graphic.png" ]]; then pass "feature-graphic.png"; else fail_msg "feature graphic — ./scripts/export_feature_graphic.sh"; fi
shots=0
if [[ -d "$STORE/screenshots" ]]; then
  shots=$(ls "$STORE/screenshots"/*.png 2>/dev/null | wc -l | tr -d ' ')
fi
if [[ "$shots" -ge 2 ]]; then
  pass "$shots screenshots"
else
  fail_msg "screenshots ($shots) — ./scripts/capture_play_screenshots_auto.sh"
fi

echo ""
echo "==> Identidade da app (fixo na 1.ª release)"
cat <<EOF
  Package:       $PACKAGE
  Version name:  $VERSION_NAME
  Version code:  $VERSION_CODE
  Tipo:          Jogo, gratuito
  Contacto:      $CONTACT
  Privacidade:   $PRIVACY_URL
  GitHub:        https://github.com/pakopt/PhoenixManager
EOF

echo ""
echo "==> Ficha da loja (copiar para Presença na loja)"
cat <<'EOF'

Título:
Project Phoenix Manager

Descrição curta:
Gestão de futebol offline com motor Phoenix Simulation Engine.

Descrição completa:
Project Phoenix Manager é um jogo de gestão de futebol offline-first para telemóvel e tablet.

Assume o comando do teu clube: plantel, tácticas, mercado, finanças e calendário numa liga completa com taça. Tudo corre no dispositivo — sem conta, sem servidor, sem anúncios.

DESTAQUES
• Modo Express — simula jornadas rapidamente e vê resultados animados
• Carreira completa — temporadas, promoções, taças e estatísticas
• Motor Phoenix Simulation Engine (PSE v0.8) — partidas credíveis e finanças simuladas
• Saves locais — continua a carreira quando quiseres
• Política de privacidade transparente — não recolhemos dados pessoais

IDEAL PARA
• Fãs de manager games que querem jogar offline
• Sessões curtas no telemóvel ou partidas mais longas no tablet

Requisitos: Android 5.0+. Funciona sem ligação à Internet após instalação.

Contacto: pakopt7@gmail.com

Categoria sugerida: Jogos → Desporto (ou Simulação)
EOF

echo ""
echo "==> Notas da versão (teste interno)"
cat <<EOF

v0.8.0-alpha — primeira build pública de teste.
- Modo Express e carreira completa
- Saves locais offline
- Motor Phoenix Simulation Engine v0.8

EOF

echo "==> Data safety (resumo)"
cat <<EOF
  Recolhe/partilha dados?     Não
  Analytics / anúncios?        Não
  Compras in-app?              Não
  Saves:                       Só no dispositivo (SharedPreferences)
  Eliminação:                  Definições → Apps → Limpar dados
  Detalhe:                     docs/STORE.md §8

EOF

echo "==> IARC (resumo)"
cat <<EOF
  Violência:     desporto simulado, sem violência realista
  Sexualidade:   nenhuma
  Chat/redes:    nenhuma (offline)
  Apostas $:      nenhuma (sem dinheiro real)
  Público-alvo:  13+; não dirigida a crianças
  Detalhe:       docs/STORE.md §6–7

EOF

echo "==> Ordem na Play Console (quando conta activa)"
cat <<EOF
  1. Criar app → package $PACKAGE
  2. Política → URL privacidade: $PRIVACY_URL
  3. Teste interno → upload AAB
  4. Presença na loja → textos + gráficos ($STORE/)
  5. IARC + Data safety + público-alvo
  6. Testadores → teu Gmail → link de adesão no telemóvel

  Guia completo: docs/STORE.md
  Pacote ZIP (opcional): ./scripts/package_play_store.sh

EOF

echo "────────────────────────────────────────"
if [[ $warn -eq 0 ]]; then
  echo "Assets: $ok OK — pronto para upload quando a conta activar."
else
  echo "Assets: $ok OK, $warn em falta — corre os scripts indicados."
fi
