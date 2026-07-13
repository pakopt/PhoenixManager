#!/usr/bin/env bash
# Resumo copy-paste para App Store Connect (quando tiveres Apple Developer).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PRIVACY_URL="https://pakopt.github.io/PhoenixManager/privacy.html"
CONTACT="pakopt7@gmail.com"
BUNDLE="com.phoenix.manager"

echo "════════════════════════════════════════"
echo "  App Store Connect — brief"
echo "════════════════════════════════════════"
echo ""
echo "==> Identidade"
cat <<EOF
  Bundle ID:     $BUNDLE
  Nome:          Project Phoenix Manager
  Versão:        0.8.1 (build 2)
  Categoria:     Jogos → Desporto (ou Simulação)
  Preço:         Gratuito
  Contacto:      $CONTACT
  Privacidade:   $PRIVACY_URL
EOF

echo ""
echo "==> Descrição (App Store)"
cat <<'EOF'

Project Phoenix Manager é um jogo de gestão de futebol offline-first para iPhone e iPad.

Assume o comando do teu clube: plantel, tácticas, mercado, finanças e calendário numa liga completa com taça. Tudo corre no dispositivo — sem conta, sem servidor, sem anúncios.

• Modo Express — simula jornadas rapidamente
• Carreira completa — temporadas, taças e estatísticas
• Motor Phoenix Simulation Engine (PSE v0.8)
• Saves locais — continua quando quiseres
• Sem recolha de dados pessoais

Contacto: pakopt7@gmail.com

EOF

echo "==> App Privacy (App Store Connect)"
cat <<EOF
  Dados recolhidos:     Nenhum
  Dados ligados a ti:   Não
  Tracking:             Não
  Política privacidade: $PRIVACY_URL

EOF

echo "==> Build iOS"
cat <<EOF
  1. Conta Apple Developer (~99 USD/ano)
  2. Xcode → Signing & Capabilities → Team + $BUNDLE
  3. cd apps/phoenix_manager && flutter build ipa
  4. Xcode Organizer ou Transporter → TestFlight
  5. Screenshots: capturar no simulador iPhone/iPad

  Build local (sem signing): ./scripts/build_mobile.sh ios
  Dev simulador:           ./scripts/run_dev.sh ios
  Guia:                    docs/STORE.md § App Store

EOF

if [[ -d "$ROOT/build/release/ios/Runner.app" ]] || [[ -d "$ROOT/apps/phoenix_manager/build/ios/iphoneos/Runner.app" ]]; then
  echo "  OK   Runner.app disponível localmente"
else
  echo "  --   Runner.app — corre ./scripts/build_mobile.sh ios"
fi
