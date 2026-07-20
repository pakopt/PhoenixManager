#!/usr/bin/env bash
# Repara cache Gradle corrompido (ex. após CLEAN_GRADLE=1 com daemons activos).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/apps/phoenix_manager/android"

echo "==> Reparar Gradle (Android)"

if [[ -x "$APP/gradlew" ]]; then
  echo "    Parar Gradle daemons..."
  (cd "$APP" && ./gradlew --stop) 2>/dev/null || true
fi

echo "    Limpar estado local do projecto..."
rm -rf "$APP/.gradle" "$APP/build"

if [[ "${RESET_GRADLE_CACHE:-0}" == "1" ]]; then
  echo "    Apagar ~/.gradle/caches (completo)..."
  rm -rf "$HOME/.gradle/caches"
else
  echo "    Apagar transforms/caches parciais..."
  rm -rf "$HOME/.gradle/caches/"*/transforms 2>/dev/null || true
fi

echo ""
echo "Próximo passo (re-download do cache — pode demorar):"
echo "  cd \"$ROOT/apps/phoenix_manager\" && flutter build apk --release"
echo ""
echo "Ou: BUILD_ANDROID=1 INSTALL_MAC=0 ./scripts/install_local.sh"
