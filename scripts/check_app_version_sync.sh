#!/usr/bin/env bash
# Garante que AppVersion (UI) e privacy in-app batem certo com o pubspec da app.
# Uso: ./scripts/check_app_version_sync.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=read_app_version.sh
source "$ROOT/scripts/read_app_version.sh"

APP_VERSION_FILE="$ROOT/packages/phoenix_ui/lib/src/util/app_version.dart"
PRIVACY_FILE="$ROOT/packages/phoenix_ui/lib/src/legal/app_privacy_policy.dart"
UI_PUBSPEC="$ROOT/packages/phoenix_ui/pubspec.yaml"

fail=0

check_contains() {
  local file="$1"
  local needle="$2"
  local label="$3"
  if ! grep -q "$needle" "$file"; then
    echo "FAIL  $label — esperado «$needle» em $file" >&2
    fail=1
  else
    echo "OK    $label"
  fi
}

echo "════════════════════════════════════════"
echo "  Sync versão · $VERSION_FULL"
echo "════════════════════════════════════════"

check_contains "$APP_VERSION_FILE" "static const label = '$VERSION_NAME';" "AppVersion.label"
check_contains "$APP_VERSION_FILE" "static const buildNumber = $VERSION_CODE;" "AppVersion.buildNumber"
check_contains "$APP_VERSION_FILE" "static const engineLabel = 'PSE v$VERSION_NAME';" "AppVersion.engineLabel"
check_contains "$PRIVACY_FILE" "static const version = '$VERSION_NAME';" "AppPrivacyPolicy.version"
check_contains "$UI_PUBSPEC" "version: $VERSION_NAME" "phoenix_ui pubspec"

if [[ "$fail" -ne 0 ]]; then
  echo "" >&2
  echo "Actualiza AppVersion / privacy / phoenix_ui pubspec para $VERSION_FULL" >&2
  exit 1
fi

echo ""
echo "Tudo alinhado com apps/phoenix_manager/pubspec.yaml"
