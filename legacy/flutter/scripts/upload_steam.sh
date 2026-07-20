#!/usr/bin/env bash
# Upload staged Steam content via steamcmd + ContentBuilder.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STEAM_DIR="$ROOT/steam"
ENV_FILE="${STEAM_ENV:-$STEAM_DIR/steam.env}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE"
  exit 1
fi

# shellcheck disable=SC1090
set -a
source "$ENV_FILE"
set +a

if [[ -z "${STEAM_SDK_ROOT:-}" || ! -d "$STEAM_SDK_ROOT/tools/ContentBuilder" ]]; then
  echo ""
  echo "ERRO: STEAM_SDK_ROOT inválido."
  echo "  Valor actual: ${STEAM_SDK_ROOT:-(não definido)}"
  echo ""
  echo "  1. Descarrega Steamworks SDK em partner.steamgames.com (Downloads)"
  echo "  2. Extrai para uma pasta, ex.: ~/steamworks_sdk"
  echo "  3. Em steam/steam.env define:"
  echo '     STEAM_SDK_ROOT="$HOME/steamworks_sdk"'
  echo ""
  echo "  Corre ./scripts/steam_doctor.sh para diagnóstico completo."
  exit 1
fi

if [[ -z "${STEAM_USERNAME:-}" ]]; then
  echo "Set STEAM_USERNAME in steam/steam.env"
  exit 1
fi

"$STEAM_DIR/scripts/generate_vdfs.sh"

CB="$STEAM_SDK_ROOT/tools/ContentBuilder"
RUN_SCRIPT="$CB/run_build.bat"
if [[ "$(uname -s)" != MINGW* && "$(uname -s)" != MSYS* && "$(uname -s)" != CYGWIN* ]]; then
  RUN_SCRIPT="$CB/builder_osx/run_build.sh"
  if [[ ! -x "$RUN_SCRIPT" ]]; then
    RUN_SCRIPT="$CB/builder_linux/run_build.sh"
  fi
fi

if [[ ! -f "$RUN_SCRIPT" && ! -f "$CB/run_build.bat" ]]; then
  echo "ContentBuilder script not found under $CB"
  echo "Install Steamworks SDK from partner.steamgames.com"
  exit 1
fi

GEN="$STEAM_DIR/generated"
STEAM_PLATFORMS="${STEAM_PLATFORMS:-windows,macos,linux}"
STEAM_PLATFORMS="${STEAM_PLATFORMS// /}"

cp "$GEN/app_build.vdf" "$CB/scripts/app_build.vdf"
if [[ ",$STEAM_PLATFORMS," == *",windows,"* ]]; then
  cp "$GEN/depot_build_windows.vdf" "$CB/scripts/depot_build_windows.vdf"
fi
if [[ ",$STEAM_PLATFORMS," == *",macos,"* ]]; then
  cp "$GEN/depot_build_macos.vdf" "$CB/scripts/depot_build_macos.vdf"
fi
if [[ ",$STEAM_PLATFORMS," == *",linux,"* ]]; then
  cp "$GEN/depot_build_linux.vdf" "$CB/scripts/depot_build_linux.vdf"
fi

echo "Uploading build to Steam (App $STEAM_APP_ID, branch $STEAM_BRANCH)..."
echo "You will be prompted for your Steam Guard code if needed."

if [[ -x "$CB/builder_osx/run_build.sh" ]]; then
  (cd "$CB/builder_osx" && ./run_build.sh "$STEAM_USERNAME" "$STEAM_APP_ID" ../scripts/app_build.vdf)
elif [[ -x "$CB/builder_linux/run_build.sh" ]]; then
  (cd "$CB/builder_linux" && ./run_build.sh "$STEAM_USERNAME" "$STEAM_APP_ID" ../scripts/app_build.vdf)
else
  (cd "$CB" && ./run_build.bat "$STEAM_USERNAME" "$STEAM_APP_ID" scripts/app_build.vdf)
fi

echo "Upload complete. Verify in Steamworks → Builds → set live on branch '$STEAM_BRANCH'."
