#!/usr/bin/env bash
# Instala Android SDK Command-line Tools no SDK local (corrige aviso de debug symbols no AAB).
set -euo pipefail

SDK="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
TARGET="$SDK/cmdline-tools/latest"

echo "==> Android SDK: $SDK"
echo ""

if [[ -d "$TARGET/bin" && -x "$TARGET/bin/sdkmanager" ]]; then
  echo "OK: cmdline-tools já instalados em $TARGET"
  exit 0
fi

echo "Os cmdline-tools permitem ao Flutter remover símbolos de debug das libs nativas no AAB."
echo ""
echo "Opção A — Android Studio (recomendado)"
echo "  1. Abre Android Studio → Settings → Languages & Frameworks → Android SDK"
echo "  2. Separador SDK Tools → marca «Android SDK Command-line Tools (latest)»"
echo "  3. Apply → OK"
echo ""
echo "Opção B — Homebrew (macOS)"
echo "  brew install --cask android-commandlinetools"
echo "  mkdir -p \"$SDK/cmdline-tools\""
echo "  ln -sf /opt/homebrew/share/android-commandlinetools/cmdline-tools/latest \"$TARGET\""
echo ""
echo "Depois:"
echo "  flutter doctor --android-licenses   # aceitar licenças"
echo "  flutter doctor -v                   # confirmar cmdline-tools OK"
echo "  ./scripts/build_mobile.sh android   # AAB sem aviso de strip"
echo ""

if [[ -d /opt/homebrew/share/android-commandlinetools/cmdline-tools/latest/bin ]]; then
  echo "Detectado Homebrew android-commandlinetools — a criar symlink..."
  mkdir -p "$SDK/cmdline-tools"
  ln -sfn /opt/homebrew/share/android-commandlinetools/cmdline-tools/latest "$TARGET"
  echo "OK: symlink $TARGET"
  if command -v flutter >/dev/null 2>&1; then
    echo ""
    echo "Corre agora: flutter doctor --android-licenses"
  fi
  exit 0
fi

echo "Nenhuma instalação automática encontrada — segue Opção A ou B acima."
exit 1
