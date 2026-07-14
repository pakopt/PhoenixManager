#!/usr/bin/env bash
# Liberta espaço em disco — caches de dev Flutter/Gradle (mantém build/release/*).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/apps/phoenix_manager"

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

echo ""
echo "Caches globais (opcional, manual):"
echo "  rm -rf ~/.gradle/caches   # Gradle — pode ser vários GiB"
echo "  flutter pub cache clean   # pub cache — usar com cuidado"
