#!/usr/bin/env bash
# Atalho — delega para o script na raiz do monorepo.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
exec "$ROOT/scripts/regenerate_branding.sh"
