#!/usr/bin/env bash
# Lê version name e versionCode de apps/phoenix_manager/pubspec.yaml.
# Uso: source scripts/read_app_version.sh
set -euo pipefail

_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
_PUBSPEC="$_ROOT/apps/phoenix_manager/pubspec.yaml"

if [[ ! -f "$_PUBSPEC" ]]; then
  echo "read_app_version: pubspec em falta: $_PUBSPEC" >&2
  exit 1
fi

_version_line="$(grep -E '^version:' "$_PUBSPEC" | head -1 | sed 's/^version:[[:space:]]*//')"
VERSION_NAME="${_version_line%%+*}"
VERSION_CODE="${_version_line#*+}"
VERSION_FULL="${_version_line}"

if [[ -z "$VERSION_NAME" || "$VERSION_NAME" == "$_version_line" ]]; then
  VERSION_CODE=""
fi

export VERSION_NAME VERSION_CODE VERSION_FULL
