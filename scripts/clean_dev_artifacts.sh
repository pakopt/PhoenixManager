#!/usr/bin/env bash
# Liberta espaço em disco — caches de dev Flutter/Gradle e lixo local.
# Por omissão mantém build/release/mobile + store (AAB/gráficos Play).
#
# Uso:
#   ./scripts/clean_dev_artifacts.sh
#   CLEAN_GRADLE=1 ./scripts/clean_dev_artifacts.sh   # + ~/.gradle/caches
#   CLEAN_RELEASE=1 ./scripts/clean_dev_artifacts.sh   # apaga também build/release/*
#   CLEAN_ALL=1 ./scripts/clean_dev_artifacts.sh      # release + steam + gradle
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/apps/phoenix_manager"

CLEAN_GRADLE="${CLEAN_GRADLE:-0}"
CLEAN_RELEASE="${CLEAN_RELEASE:-0}"
CLEAN_ALL="${CLEAN_ALL:-0}"
if [[ "$CLEAN_ALL" == "1" ]]; then
  CLEAN_GRADLE=1
  CLEAN_RELEASE=1
fi

human_size() {
  local bytes="${1:-0}"
  if command -v numfmt >/dev/null 2>&1; then
    numfmt --to=iec --suffix=B "$bytes" 2>/dev/null || echo "${bytes}B"
  elif (( bytes >= 1073741824 )); then
    awk -v b="$bytes" 'BEGIN { printf "%.1f GiB", b/1073741824 }'
  elif (( bytes >= 1048576 )); then
    awk -v b="$bytes" 'BEGIN { printf "%.0f MiB", b/1048576 }'
  elif (( bytes >= 1024 )); then
    awk -v b="$bytes" 'BEGIN { printf "%.0f KiB", b/1024 }'
  else
    echo "${bytes}B"
  fi
}

dir_bytes() {
  local path="$1"
  if [[ -e "$path" ]]; then
    du -sk "$path" 2>/dev/null | awk '{print $1 * 1024}'
  else
    echo 0
  fi
}

rm_path() {
  local path="$1"
  local label="${2:-$path}"
  if [[ ! -e "$path" ]]; then
    return 0
  fi
  local bytes
  bytes="$(dir_bytes "$path")"
  rm -rf "$path"
  echo "  − $label ($(human_size "$bytes"))"
  FREED=$((FREED + bytes))
}

stop_gradle_daemons() {
  if [[ -x "$APP/android/gradlew" ]]; then
    (cd "$APP/android" && ./gradlew --stop) 2>/dev/null || true
  fi
}

FREED=0

echo "════════════════════════════════════════"
echo "  Limpeza — Phoenix Manager"
echo "════════════════════════════════════════"
echo "  CLEAN_GRADLE=$CLEAN_GRADLE  CLEAN_RELEASE=$CLEAN_RELEASE"
echo ""

echo "==> Flutter clean ($APP)"
if [[ -d "$APP" ]] && command -v flutter >/dev/null 2>&1; then
  (cd "$APP" && flutter clean) || true
else
  echo "  (flutter indisponível — a apagar build/ à mão)"
  rm_path "$APP/build" "apps/phoenix_manager/build"
fi

echo ""
echo "==> Builds de packages / caches Dart"
rm_path "$ROOT/packages/phoenix_ui/build" "packages/phoenix_ui/build"
rm_path "$ROOT/packages/phoenix_core/.dart_tool" "packages/phoenix_core/.dart_tool"
rm_path "$ROOT/packages/phoenix_data/.dart_tool" "packages/phoenix_data/.dart_tool"
rm_path "$ROOT/packages/phoenix_engine/.dart_tool" "packages/phoenix_engine/.dart_tool"
rm_path "$ROOT/packages/phoenix_tools/.dart_tool" "packages/phoenix_tools/.dart_tool"
rm_path "$ROOT/packages/phoenix_ui/.dart_tool" "packages/phoenix_ui/.dart_tool"
rm_path "$APP/.dart_tool" "apps/phoenix_manager/.dart_tool"
# Mantém package_config da raiz (workspace) — só limpa caches pesados se existirem
rm_path "$ROOT/.dart_tool/pub" "raiz .dart_tool/pub"
rm_path "$ROOT/.dart_tool/test" "raiz .dart_tool/test"

echo ""
echo "==> Android / IDE local"
rm_path "$APP/android/.gradle" "android/.gradle"
rm_path "$APP/android/.idea" "android/.idea"
rm_path "$APP/android/local.properties" "android/local.properties"
rm_path "$APP/phoenix_manager.iml" "phoenix_manager.iml"
rm_path "$APP/android/phoenix_manager_android.iml" "android/*.iml"

echo ""
echo "==> Steam / release regeneráveis"
rm_path "$ROOT/build/steam" "build/steam"
rm_path "$ROOT/steam/generated" "steam/generated"
# macOS duplicado: Contents solto + .app
if [[ -d "$ROOT/build/release/macos/Contents" && -d "$ROOT/build/release/macos/phoenix_manager.app" ]]; then
  rm_path "$ROOT/build/release/macos/Contents" "build/release/macos/Contents (duplicado)"
fi
rm_path "$ROOT/build/release/web" "build/release/web"
rm_path "$ROOT/build/release/site" "build/release/site"

if [[ "$CLEAN_RELEASE" == "1" ]]; then
  echo ""
  echo "==> build/release completo (CLEAN_RELEASE=1)"
  rm_path "$ROOT/build/release" "build/release"
else
  echo ""
  echo "==> Mantido: build/release/mobile + store + beta + macos.app"
fi

if [[ "$CLEAN_GRADLE" == "1" ]]; then
  echo ""
  echo "==> Gradle global (~/.gradle/caches)"
  stop_gradle_daemons
  rm_path "$HOME/.gradle/caches" "~/.gradle/caches"
  rm_path "$APP/android/.gradle" "android/.gradle"
  echo "    Próximo build Android re-download caches."
fi

echo ""
echo "==> .DS_Store"
while IFS= read -r -d '' f; do
  rm -f "$f"
  FREED=$((FREED + 8192))
  echo "  − $f"
done < <(find "$ROOT" -name .DS_Store -print0 2>/dev/null)

echo ""
echo "════════════════════════════════════════"
echo "  Recuperados ≈ $(human_size "$FREED")"
echo "════════════════════════════════════════"
echo ""
echo "Mantido (útil):"
echo "  docs/, packages/, scripts/, data/, steam/*.md + templates"
echo "  build/release/mobile · store · beta (salvo CLEAN_RELEASE=1)"
echo ""
echo "Opções:"
echo "  CLEAN_GRADLE=1 $0"
echo "  CLEAN_RELEASE=1 $0"
echo "  CLEAN_ALL=1 $0"
echo "  flutter pub get   # após limpar .dart_tool dos packages"
