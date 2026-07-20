#!/usr/bin/env bash
# Testes + builds release para a plataforma actual (pré-lançamento).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OS="$(uname -s)"
TARGET="${1:-auto}"

usage() {
  echo "Usage: $0 [auto|desktop|mobile|steam|all]"
  echo ""
  echo "  auto    — testes + builds adequados ao OS actual"
  echo "  desktop — web (+ macOS no Mac)"
  echo "  mobile  — Android + iOS (iOS só no Mac)"
  echo "  steam   — stage Steam content"
  echo "  all     — tudo o que o OS suporta"
}

run_tests() {
  echo "==> Testes"
  "$ROOT/scripts/test_all.sh"
}

run_desktop() {
  echo "==> Desktop release"
  "$ROOT/scripts/build_release.sh"
}

run_mobile() {
  echo "==> Mobile release"
  "$ROOT/scripts/build_mobile.sh" all
}

run_steam() {
  echo "==> Steam staging"
  case "$OS" in
    Darwin) "$ROOT/scripts/build_steam.sh" macos ;;
    Linux) "$ROOT/scripts/build_steam.sh" linux ;;
    MINGW*|MSYS*|CYGWIN*) "$ROOT/scripts/build_steam.sh" windows ;;
    *)
      echo "Steam build: passa windows|macos|linux explicitamente"
      exit 1
      ;;
  esac
}

case "$TARGET" in
  auto)
    run_tests
    run_desktop
    if [[ "$OS" == "Darwin" ]]; then
      run_mobile
      run_steam
    fi
    ;;
  desktop)
    run_tests
    run_desktop
    ;;
  mobile)
    run_tests
    run_mobile
    ;;
  steam)
    run_tests
    run_steam
    ;;
  all)
    run_tests
    run_desktop
    if [[ "$OS" == "Darwin" ]]; then
      run_mobile
    fi
    run_steam
    ;;
  -h|--help|help) usage; exit 0 ;;
  *) usage; exit 1 ;;
esac

echo ""
echo "Build completo. Artefactos:"
echo "  build/release/         — web, macOS"
echo "  build/release/mobile/  — APK, AAB, Runner.app"
echo "  build/steam/content/   — Steam depots"
