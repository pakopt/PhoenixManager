#!/usr/bin/env bash
# Liberta espaço em disco — caches de dev Flutter/Gradle (mantém build/release/*).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/apps/phoenix_manager"

stop_gradle_daemons() {
  if [[ -x "$APP/android/gradlew" ]]; then
    (cd "$APP/android" && ./gradlew --stop) 2>/dev/null || true
  fi
}

echo "════════════════════════════════════════"
echo "  Limpeza dev — Phoenix Manager"
echo "════════════════════════════════════════"

before="$(df -k /System/Volumes/Data 2>/dev/null | awk 'NR==2 {print $4}')"

echo ""
echo "==> flutter clean ($APP)"
(cd "$APP" && flutter clean)

if [[ -d "$APP/android/.gradle" ]]; then
  echo ""
  echo "==> Gradle local (.gradle do projecto)"
  rm -rf "$APP/android/.gradle"
fi

if [[ "${CLEAN_GRADLE:-0}" == "1" ]]; then
  echo ""
  echo "==> Gradle global (~/.gradle/caches)"
  stop_gradle_daemons
  rm -rf "$HOME/.gradle/caches"
  rm -rf "$APP/android/.gradle"
  echo "    Próximo build Android re-download caches (pode demorar)."
  echo "    Se falhar: ./scripts/repair_gradle.sh"
fi

echo ""
echo "==> Mantido (não apagado)"
echo "  build/release/     — APK, AAB, beta, lojas"
echo "  /Applications/Phoenix Manager.app"

after="$(df -k /System/Volumes/Data 2>/dev/null | awk 'NR==2 {print $4}')"
if [[ -n "$before" && -n "$after" ]]; then
  freed=$(( (after - before) / 1024 ))
  echo ""
  echo "Espaço livre agora: ~$(( after / 1024 / 1024 )) GiB (${freed} MiB recuperados nesta corrida)"
fi

echo "Caches globais (opcional):"
echo "  CLEAN_GRADLE=1 $0   # inclui ~/.gradle/caches (~vários GiB)"
echo "  flutter pub cache clean   # pub cache — usar com cuidado"
