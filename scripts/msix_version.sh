#!/usr/bin/env bash
# Calcula msix_version (Major.Minor.Build.Revision) a partir do pubspec Flutter.
# Uso: source scripts/msix_version.sh   → exporta MSIX_VERSION
#      ou: ./scripts/msix_version.sh     → imprime MSIX_VERSION
set -euo pipefail

_MSIX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=read_app_version.sh
source "$_MSIX_ROOT/scripts/read_app_version.sh"

msix_version_from_flutter() {
  local name="${VERSION_NAME:-0.0.0}"
  local code="${VERSION_CODE:-0}"
  local major minor patch
  IFS=. read -r major minor patch _ <<< "${name}."
  major="${major:-0}"
  minor="${minor:-0}"
  patch="${patch:-0}"
  if [[ "$major" == "0" ]]; then
    major="1"
  fi
  echo "${major}.${minor}.${patch}.${code}"
}

MSIX_VERSION="$(msix_version_from_flutter)"
export MSIX_VERSION

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "$MSIX_VERSION"
fi
