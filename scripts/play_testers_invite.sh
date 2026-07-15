#!/usr/bin/env bash
# Checklist + mensagem de convite para o requisito Google: 12 testadores × 14 dias.
# Uso:
#   ./scripts/play_testers_invite.sh
#   ./scripts/play_testers_invite.sh 'https://play.google.com/apps/testing/com.phoenix.manager'
#   PLAY_OPT_IN_URL='https://...' ./scripts/play_testers_invite.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=read_app_version.sh
source "$ROOT/scripts/read_app_version.sh"

LINK="${1:-${PLAY_OPT_IN_URL:-}}"
CONTACT="pakopt7@gmail.com"
PACKAGE="com.phoenix.manager"

if [[ -z "$LINK" ]]; then
  LINK="[cola aqui o link de adesão: Play Console → Teste fechado → Testadores]"
fi

echo "════════════════════════════════════════"
echo "  Play — convite teste fechado (12 × 14)"
echo "  Versão: $VERSION_FULL  ·  $PACKAGE"
echo "════════════════════════════════════════"
echo ""
echo "==> Checklist (tu)"
cat <<EOF
  [ ] Lista com 14–16 emails na faixa de teste fechado
  [ ] Link de adesão copiado da Play Console (não APK)
  [ ] Enviar mensagem abaixo (WhatsApp / email)
  [ ] Confirmar na Console ≥12 com estado opted-in / joined
  [ ] Contagem: 14 dias contínuos com ≥12 opted-in
  [ ] Dashboard → candidatar acesso a produção
  Guia: docs/STORE.md §9c
EOF

echo ""
echo "==> Mensagem (copiar)"
echo "────────────────────────────────────────"
cat <<EOF
Olá — podes testar o Project Phoenix Manager (jogo de gestão de futebol offline)?

1) Abre este link no telemóvel Android (com o teu Gmail):
   $LINK

2) Toca em «Tornar-me testador» e instala pela Play Store
   (não uses APK — tem de ser pela loja)

3) Joga 5–10 min. Se algo falhar: $CONTACT
   (indica modelo do telemóvel + versão $VERSION_NAME)

Obrigado — a Google exige ~12 pessoas opted-in durante 14 dias
antes de deixar publicar na Play Store.
EOF
echo "────────────────────────────────────────"
echo ""
echo "==> Notas"
cat <<EOF
  • Só emails na lista NÃO conta — têm de aceitar o link.
  • Sideload APK NÃO conta para o requisito.
  • Mantém buffer: se alguém sair, o relógio pode reiniciar.
  • QA opcional: ./scripts/qa_manual.sh · docs/BETA.md
EOF

if [[ "$(uname -s)" == "Darwin" ]] && command -v pbcopy >/dev/null 2>&1; then
  if [[ "$LINK" != \[* ]]; then
    {
      cat <<EOF
Olá — podes testar o Project Phoenix Manager (jogo de gestão de futebol offline)?

1) Abre este link no telemóvel Android (com o teu Gmail):
   $LINK

2) Toca em «Tornar-me testador» e instala pela Play Store
   (não uses APK — tem de ser pela loja)

3) Joga 5–10 min. Se algo falhar: $CONTACT
   (indica modelo do telemóvel + versão $VERSION_NAME)

Obrigado — a Google exige ~12 pessoas opted-in durante 14 dias
antes de deixar publicar na Play Store.
EOF
    } | pbcopy
    echo ""
    echo "Mensagem copiada para a área de transferência (pbcopy)."
  else
    echo ""
    echo "Dica: passa o link como argumento para copiar a mensagem pronta:"
    echo "  ./scripts/play_testers_invite.sh 'https://play.google.com/apps/testing/...'"
  fi
fi
