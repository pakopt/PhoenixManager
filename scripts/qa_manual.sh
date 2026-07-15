#!/usr/bin/env bash
# Imprime roteiro QA manual (beta local, sem lojas).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=read_app_version.sh
source "$ROOT/scripts/read_app_version.sh"

cat <<EOF
════════════════════════════════════════
  QA manual — Project Phoenix Manager
  Versão: $VERSION_FULL
════════════════════════════════════════

Corre em Mac, Android ou iOS (dev) antes de lojas.

  [ ] 1. Menu carreira → Jogar agora / Continuar
  [ ] 2. Dashboard carrega (motor PSE boot)
  [ ] 3. Plantel — lista, pesquisa, ordenação
  [ ] 4. Classificação e calendário
  [ ] 5. Simular jornada (Express) — animação e resultado
  [ ] 6. Guardar → fechar → reabrir → dados restaurados
  [ ] 7. Definições → Política de privacidade abre
  [ ] 8. Conquistas / palmarés (se visível)
  [ ] 9. Finanças — resultado época, transferências
  [ ] 10. Calendário — scroll próximo jogo, filtro «Só os meus»
  [ ] 11. Treino — filtro margem, toque abre ficha
  [ ] 12. Detalhe jogo — «Ver relato completo»
  [ ] 13. Dashboard — dica «Primeiros passos» (carreira nova)
  [ ] 14. Dashboard — alertas «Antes do próximo jogo» (Diretor)
  [ ] 15. Dashboard — «Forma recente» (vazia no início ou após jogos)
  [ ] 16. Android — barras sistema não tapam botões (edge-to-edge; ver MOBILE.md)
  [ ] 17. Rodapé menu — versão PSE visível (ex. v$VERSION_NAME)

Automático (saves):
  ./scripts/test_mac.sh
  ./scripts/test_android.sh

Beta local:
  ./scripts/local_beta.sh       # ZIP APK para testadores
  docs/BETA.md

EOF

if [[ -d "/Applications/Phoenix Manager.app" ]]; then
  echo "Mac release: open -a \"Phoenix Manager\""
else
  echo "Mac release: ./scripts/install_local.sh"
fi

echo "Dev: ./scripts/run_dev.sh macos|android|ios"
