#!/usr/bin/env bash
# Generates SteamPipe VDF files from steam.env + build/steam/content layout.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
STEAM_DIR="$ROOT/steam"
ENV_FILE="${STEAM_ENV:-$STEAM_DIR/steam.env}"
GEN_DIR="$STEAM_DIR/generated"
CONTENT="$ROOT/build/steam/content"
OUTPUT="$ROOT/build/steam/output"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE — copy steam/steam.env.example to steam/steam.env"
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

STEAM_PLATFORMS="${STEAM_PLATFORMS:-windows,macos,linux}"
STEAM_PLATFORMS="${STEAM_PLATFORMS// /}"

required=(STEAM_APP_ID STEAM_BUILD_DESC STEAM_BRANCH)
for key in "${required[@]}"; do
  if [[ -z "${!key:-}" ]]; then
    echo "Missing $key in $ENV_FILE"
    exit 1
  fi
done

platform_enabled() {
  local platform="$1"
  [[ ",$STEAM_PLATFORMS," == *",$platform,"* ]]
}

depot_var_for_platform() {
  case "$1" in
    windows) echo "STEAM_DEPOT_WINDOWS" ;;
    macos) echo "STEAM_DEPOT_MACOS" ;;
    linux) echo "STEAM_DEPOT_LINUX" ;;
    *) echo "" ;;
  esac
}

for platform in windows macos linux; do
  if platform_enabled "$platform"; then
    depot_key="$(depot_var_for_platform "$platform")"
    if [[ -z "${!depot_key:-}" ]]; then
      echo "Missing $depot_key in $ENV_FILE (required for STEAM_PLATFORMS=$STEAM_PLATFORMS)"
      exit 1
    fi
  fi
done

mkdir -p "$GEN_DIR" "$OUTPUT" "$CONTENT/windows" "$CONTENT/macos" "$CONTENT/linux"

substitute() {
  local template="$1"
  local output="$2"
  sed \
    -e "s/{{STEAM_APP_ID}}/$STEAM_APP_ID/g" \
    -e "s/{{STEAM_DEPOT_WINDOWS}}/${STEAM_DEPOT_WINDOWS:-0}/g" \
    -e "s/{{STEAM_DEPOT_MACOS}}/${STEAM_DEPOT_MACOS:-0}/g" \
    -e "s/{{STEAM_DEPOT_LINUX}}/${STEAM_DEPOT_LINUX:-0}/g" \
    -e "s/{{STEAM_BUILD_DESC}}/$STEAM_BUILD_DESC/g" \
    -e "s/{{STEAM_BRANCH}}/$STEAM_BRANCH/g" \
    -e "s|{{CONTENT_ROOT}}|$CONTENT|g" \
    -e "s|{{OUTPUT_ROOT}}|$OUTPUT|g" \
    -e "s|{{WINDOWS_CONTENT}}|$CONTENT/windows|g" \
    -e "s|{{MACOS_CONTENT}}|$CONTENT/macos|g" \
    -e "s|{{LINUX_CONTENT}}|$CONTENT/linux|g" \
    "$template" > "$output"
}

generate_app_build() {
  local output="$GEN_DIR/app_build.vdf"
  {
    echo '"AppBuild"'
    echo '{'
    echo "	\"AppID\"		\"$STEAM_APP_ID\""
    echo "	\"Desc\"		\"$STEAM_BUILD_DESC\""
    echo "	\"ContentRoot\"	\"$CONTENT\""
    echo "	\"BuildOutput\"	\"$OUTPUT\""
    echo "	\"SetLive\"	\"$STEAM_BRANCH\""
    echo ''
    echo '	"Depots"'
    echo '	{'
    if platform_enabled windows; then
      echo "		\"$STEAM_DEPOT_WINDOWS\" \"depot_build_windows.vdf\""
    fi
    if platform_enabled macos; then
      echo "		\"$STEAM_DEPOT_MACOS\" \"depot_build_macos.vdf\""
    fi
    if platform_enabled linux; then
      echo "		\"$STEAM_DEPOT_LINUX\" \"depot_build_linux.vdf\""
    fi
    echo '	}'
    echo '}'
  } > "$output"
}

generate_app_build

if platform_enabled windows; then
  substitute "$STEAM_DIR/scripts/depot_build_windows.vdf.template" "$GEN_DIR/depot_build_windows.vdf"
fi
if platform_enabled macos; then
  substitute "$STEAM_DIR/scripts/depot_build_macos.vdf.template" "$GEN_DIR/depot_build_macos.vdf"
fi
if platform_enabled linux; then
  substitute "$STEAM_DIR/scripts/depot_build_linux.vdf.template" "$GEN_DIR/depot_build_linux.vdf"
fi

echo "Generated VDFs in $GEN_DIR"
echo "  App ID: $STEAM_APP_ID"
echo "  Branch: $STEAM_BRANCH"
echo "  Platforms: $STEAM_PLATFORMS"
if platform_enabled windows; then
  echo "  Windows depot ($STEAM_DEPOT_WINDOWS): $CONTENT/windows"
fi
if platform_enabled macos; then
  echo "  macOS depot ($STEAM_DEPOT_MACOS):   $CONTENT/macos"
fi
if platform_enabled linux; then
  echo "  Linux depot ($STEAM_DEPOT_LINUX):   $CONTENT/linux"
fi
