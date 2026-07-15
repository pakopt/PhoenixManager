#!/usr/bin/env bash
# Resumo copy-paste para Play Console + verificação de assets locais.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
AAB="$ROOT/build/release/mobile/android/phoenix_manager.aab"
STORE="$ROOT/build/release/store/android"
PRIVACY_URL="https://pakopt.github.io/PhoenixManager/privacy.html"
CONTACT="pakopt7@gmail.com"
PACKAGE="com.phoenix.manager"

# shellcheck source=read_app_version.sh
source "$ROOT/scripts/read_app_version.sh"

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
cat <<EOF

Título:
Project Phoenix Manager

Descrição curta (máx. 80 caracteres):
Gestor de futebol offline: liga, taça, mercado, plantel, treinos e finanças.

Descrição completa:
Project Phoenix Manager é um jogo de gestão de futebol para Android. Conduz um clube numa liga completa com taça eliminatória, temporadas, promoções e estatísticas. Tudo funciona no telemóvel ou tablet, sem conta de utilizador e sem ligação à Internet após a instalação.

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

O jogo usa o motor Phoenix Simulation Engine (PSE v$VERSION_NAME) para simular partidas, economia do clube e progressão da temporada. Os dados da carreira ficam guardados apenas no teu dispositivo — não enviamos informação para servidores externos.

CARACTERÍSTICAS

• Gratuito, sem anúncios
• Sem compras dentro da app
• Sem registo ou login
• Offline-first — joga em viagem ou sem Wi‑Fi
• Política de privacidade: não recolhemos dados pessoais

PARA QUEM É

Ideal para fãs de jogos de gestão desportiva (football manager) que preferem uma experiência simples, rápida e totalmente offline.

REQUISITOS

Android 5.0 ou superior.

CONTACTO

Questões ou feedback: $CONTACT

Categoria sugerida: Jogos → Desporto (ou Simulação)
EOF

echo ""
echo "==> Notas da versão (teste interno)"
cat <<EOF

v$VERSION_NAME — gestão offline com PSE; Sair no desktop; Android 15.
- Modo Express e Diretor · liga, taça, mercado, finanças
- Desktop: «Sair do jogo» no menu / drawer
- Edge-to-edge Android 15 (SDK 35) · datas legíveis · acessibilidade
- Empty states e forma recente no dashboard
- Saves locais · sem conta · sem anúncios
- Motor Phoenix Simulation Engine v$VERSION_NAME

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
