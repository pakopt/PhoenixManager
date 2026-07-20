#!/usr/bin/env bash
# Regenera ícones e splash nativos a partir de assets/branding/*.png
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/apps/phoenix_manager"
ICON_SRC="$APP/assets/branding/icon.png"
LINUX_ICON="$APP/linux/icons/app_icon.png"

cd "$APP"
flutter pub get
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create

# Linux — flutter_launcher_icons ainda não gera; copiar/redimensionar manualmente
mkdir -p "$(dirname "$LINUX_ICON")"
if command -v sips >/dev/null 2>&1; then
  sips -z 256 256 "$ICON_SRC" --out "$LINUX_ICON" >/dev/null
else
  cp "$ICON_SRC" "$LINUX_ICON"
fi

echo ""
echo "Branding regenerado em todas as plataformas:"
echo "  Android  → res/mipmap-* + adaptive icon"
echo "  iOS      → AppIcon.appiconset"
echo "  macOS    → AppIcon.appiconset"
echo "  Windows  → runner/resources/app_icon.ico"
echo "  Web      → web/icons/ + manifest.json"
echo "  Linux    → linux/icons/app_icon.png"
echo ""
echo "Ver apps/phoenix_manager/BRANDING.md"
