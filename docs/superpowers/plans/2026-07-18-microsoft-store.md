# Microsoft Store (MSIX) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Empacotar o cliente Windows do Phoenix Manager como MSIX para Microsoft Store, com scripts, guia Partner Center e checklist no roadmap (espelho Play Store).

**Architecture:** Dev dependency `msix` + `msix_config` no `pubspec` da app; scripts bash no root (`build_msix`, `package_msix_store`, `msix_doctor`, `msix_partner_brief`); documentação em `docs/STORE.md` e referências no plano/roadmap. Build real só em Windows; noutros OS os scripts validam config e imprimem instruções.

**Tech Stack:** Flutter Windows, pacote [`msix`](https://pub.dev/packages/msix), bash (padrão `scripts/`), Partner Center.

**Spec:** [`docs/superpowers/specs/2026-07-18-microsoft-store-design.md`](../specs/2026-07-18-microsoft-store-design.md)

## Global Constraints

- `identity_name`: `PhoenixManager.PhoenixManager`
- `publisher`: `CN=4402D5F1-A78E-42D6-B8A3-BAEBB8F0513B`
- `publisher_display_name`: `Phoenix Manager`
- `display_name`: `Project Phoenix Manager`
- `store: true` para builds de publicação Partner Center
- `msix_version`: Major ≥ 1; mapear `0.8.48+49` → `1.8.48.49` (se Flutter major = 0, usar `1.minor.patch.versionCode`)
- Privacidade: `https://pakopt.github.io/PhoenixManager/privacy.html`
- Contacto: `pakopt7@gmail.com`
- Artefactos: `build/release/store/windows/`
- Commits: só quando o utilizador pedir explicitamente (regra do repo)
- Sem alterações de gameplay/UI

## File map

| Ficheiro | Responsabilidade |
|----------|------------------|
| `apps/phoenix_manager/pubspec.yaml` | `msix` + `msix_config` |
| `scripts/msix_version.sh` | Função partilhada: Flutter version → `msix_version` |
| `scripts/msix_doctor.sh` | Validar config/identidade/logo/OS |
| `scripts/build_msix.sh` | Build Windows + `msix:create --store` ou instruções |
| `scripts/package_msix_store.sh` | ZIP + README para upload |
| `scripts/msix_partner_brief.sh` | Textos copy-paste Partner Center |
| `docs/STORE.md` | Guia Microsoft Store |
| `docs/BETA.md`, `docs/README.md`, `docs/plano.md`, `docs/roadmap/master-roadmap-v1.md`, `README.md`, `MOBILE.md`, `phase_e_status.sh` | Referências / checklist |

---

### Task 1: `msix` no pubspec + helper de versão

**Files:**
- Modify: `apps/phoenix_manager/pubspec.yaml`
- Create: `scripts/msix_version.sh`
- Test: `bash -n scripts/msix_version.sh` + source + echo

**Interfaces:**
- Consumes: `scripts/read_app_version.sh` (`VERSION_NAME`, `VERSION_CODE`)
- Produces: `msix_version_from_flutter` → stdout `Major.Minor.Build.Revision`; env `MSIX_VERSION`

- [ ] **Step 1: Adicionar `msix` e `msix_config` ao pubspec**

Em `apps/phoenix_manager/pubspec.yaml`, sob `dev_dependencies`:

```yaml
  msix: ^3.16.8
```

No fim do ficheiro (após `flutter_native_splash`):

```yaml
msix_config:
  display_name: Project Phoenix Manager
  publisher_display_name: Phoenix Manager
  identity_name: PhoenixManager.PhoenixManager
  publisher: CN=4402D5F1-A78E-42D6-B8A3-BAEBB8F0513B
  msix_version: 1.8.48.49
  logo_path: assets/branding/icon.png
  languages: pt-pt, en-us
  store: true
  # capabilities: omitir extras (offline); msix aplica defaults Flutter full-trust
```

Ajustar `msix_version` à versão actual do `version:` no mesmo ficheiro (regra: se major Flutter é 0 → `1.<minor>.<patch>.<code>`).

- [ ] **Step 2: Criar `scripts/msix_version.sh`**

```bash
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
```

- [ ] **Step 3: Verificar helper**

Run (a partir da raiz do repo):

```bash
chmod +x scripts/msix_version.sh
./scripts/msix_version.sh
```

Expected: imprime algo como `1.8.48.49` (alinhado ao `version:` actual).

- [ ] **Step 4: `flutter pub get` na app**

```bash
cd apps/phoenix_manager && flutter pub get
```

Expected: resolve `msix` sem erro.

---

### Task 2: `msix_doctor.sh`

**Files:**
- Create: `scripts/msix_doctor.sh`

**Interfaces:**
- Consumes: `pubspec.yaml` strings de identidade; `msix_version.sh`
- Produces: exit `0` se config OK em qualquer OS; exit ≠ 0 se identidade em falta

- [ ] **Step 1: Criar o script**

```bash
#!/usr/bin/env bash
# Valida configuração MSIX / Microsoft Store.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PUBSPEC="$ROOT/apps/phoenix_manager/pubspec.yaml"
LOGO="$ROOT/apps/phoenix_manager/assets/branding/icon.png"
OK=0
WARN=0
FAIL=0

pass() { echo "  OK   $1"; OK=$((OK + 1)); }
warn() { echo "  WARN $1"; WARN=$((WARN + 1)); }
fail() { echo "  FAIL $1"; FAIL=$((FAIL + 1)); }

echo "==> msix_doctor — Project Phoenix Manager"
echo ""

echo "==> pubspec"
if grep -qE '^[[:space:]]*msix:' "$PUBSPEC"; then
  pass "dev_dependency msix"
else
  fail "msix em falta em dev_dependencies"
fi

check_cfg() {
  local key="$1" expect="$2"
  if grep -q "$expect" "$PUBSPEC"; then
    pass "$key = $expect"
  else
    fail "$key deve conter: $expect"
  fi
}

check_cfg identity_name "PhoenixManager.PhoenixManager"
check_cfg publisher "CN=4402D5F1-A78E-42D6-B8A3-BAEBB8F0513B"
check_cfg publisher_display_name "Phoenix Manager"
check_cfg display_name "Project Phoenix Manager"
if grep -qE 'store:[[:space:]]*true' "$PUBSPEC"; then
  pass "store: true"
else
  fail "store: true em falta (builds Partner Center)"
fi

if [[ -f "$LOGO" ]]; then
  pass "logo $LOGO"
else
  fail "logo em falta: assets/branding/icon.png"
fi

# shellcheck source=msix_version.sh
source "$ROOT/scripts/msix_version.sh"
pass "msix_version derivado: $MSIX_VERSION"

echo ""
echo "==> OS / build"
OS="$(uname -s)"
case "$OS" in
  MINGW*|MSYS*|CYGWIN*)
    pass "Windows — podes correr ./scripts/build_msix.sh"
    if command -v flutter >/dev/null 2>&1; then
      pass "flutter no PATH"
    else
      fail "flutter não encontrado"
    fi
    ;;
  *)
    warn "OS=$OS — MSIX só se gera em Windows (VS Build Tools)"
    echo "       Em Windows: ./scripts/build_msix.sh"
    ;;
esac

echo ""
echo "Resumo: OK=$OK WARN=$WARN FAIL=$FAIL"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0
```

- [ ] **Step 2: Correr doctor**

```bash
chmod +x scripts/msix_doctor.sh
./scripts/msix_doctor.sh
```

Expected: `FAIL=0`; em macOS pelo menos um `WARN` sobre OS.

---

### Task 3: `build_msix.sh` + `package_msix_store.sh`

**Files:**
- Create: `scripts/build_msix.sh`
- Create: `scripts/package_msix_store.sh`

**Interfaces:**
- Consumes: `msix_version.sh`, `msix_doctor.sh`, Flutter Windows
- Produces: `build/release/store/windows/phoenix_manager.msix` (Windows); ZIP em package

- [ ] **Step 1: Criar `scripts/build_msix.sh`**

```bash
#!/usr/bin/env bash
# Build MSIX para Microsoft Store (requer Windows).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/apps/phoenix_manager"
OUT="$ROOT/build/release/store/windows"
# shellcheck source=msix_version.sh
source "$ROOT/scripts/msix_version.sh"

"$ROOT/scripts/msix_doctor.sh" || true

OS="$(uname -s)"
case "$OS" in
  MINGW*|MSYS*|CYGWIN*) ;;
  *)
    echo "ERRO: build MSIX só em Windows." >&2
    echo "Neste Mac/Linux a config foi validada por msix_doctor." >&2
    echo "Em Windows:" >&2
    echo "  cd \"$ROOT\"" >&2
    echo "  ./scripts/build_msix.sh" >&2
    echo "Versão MSIX prevista: $MSIX_VERSION" >&2
    exit 1
    ;;
esac

cd "$APP"
flutter pub get
flutter build windows --release
dart run msix:create --store --version "$MSIX_VERSION"

mkdir -p "$OUT"
# msix coloca o .msix sob build/windows/... — procurar e copiar
MSIX_SRC="$(find build -name '*.msix' -type f | head -1)"
if [[ -z "$MSIX_SRC" ]]; then
  echo "ERRO: .msix não encontrado após msix:create" >&2
  exit 1
fi
cp "$MSIX_SRC" "$OUT/phoenix_manager.msix"
echo "OK   $OUT/phoenix_manager.msix"
echo "     msix_version=$MSIX_VERSION"
ls -lh "$OUT/phoenix_manager.msix"
```

- [ ] **Step 2: Criar `scripts/package_msix_store.sh`**

Espelhar `package_play_store.sh`:

```bash
#!/usr/bin/env bash
# ZIP com MSIX + README para upload Partner Center.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/build/release/store/windows"
ZIP="$OUT/phoenix-manager-msix-upload.zip"
MSIX="$OUT/phoenix_manager.msix"
STAGE="$OUT/_upload_staging"
# shellcheck source=msix_version.sh
source "$ROOT/scripts/msix_version.sh"
# shellcheck source=read_app_version.sh
source "$ROOT/scripts/read_app_version.sh"

rm -rf "$STAGE" "$ZIP"
mkdir -p "$STAGE"

[[ -f "$MSIX" ]] || { echo "ERRO: MSIX em falta — ./scripts/build_msix.sh (Windows)" >&2; exit 1; }
cp "$MSIX" "$STAGE/phoenix_manager.msix"

cat > "$STAGE/README.txt" <<EOF
Phoenix Manager — upload Microsoft Partner Center
Identity: PhoenixManager.PhoenixManager
Publisher: CN=4402D5F1-A78E-42D6-B8A3-BAEBB8F0513B
Publisher display: Phoenix Manager
Flutter: $VERSION_NAME+$VERSION_CODE
msix_version: $MSIX_VERSION
Privacidade: https://pakopt.github.io/PhoenixManager/privacy.html
Contacto: pakopt7@gmail.com

phoenix_manager.msix → Partner Center → Packages → Upload

Notas da versão (exemplo):
v$VERSION_NAME — actualização Microsoft Store (msix $MSIX_VERSION).
- Saves locais · sem conta · sem anúncios

Textos: ./scripts/msix_partner_brief.sh
Guia: docs/STORE.md (Microsoft Store)
EOF

(
  cd "$STAGE"
  zip -r "$ZIP" . -x "._*" >/dev/null
)
rm -rf "$STAGE"
echo "OK   $ZIP"
ls -lh "$ZIP"
```

- [ ] **Step 3: chmod + dry-run em Mac**

```bash
chmod +x scripts/build_msix.sh scripts/package_msix_store.sh
./scripts/build_msix.sh; echo exit=$?
```

Expected: exit ≠ 0 com mensagem a explicar que precisa de Windows; menciona `MSIX_VERSION`.

```bash
./scripts/package_msix_store.sh; echo exit=$?
```

Expected: exit ≠ 0 com “MSIX em falta” (até haver build Windows).

---

### Task 4: `msix_partner_brief.sh`

**Files:**
- Create: `scripts/msix_partner_brief.sh`

**Interfaces:**
- Consumes: `read_app_version.sh`, `msix_version.sh`
- Produces: stdout com textos PT para Partner Center

- [ ] **Step 1: Criar brief** (adaptar `play_console_brief.sh` para Windows/PC)

Incluir:
- Identidade (Name, Publisher, PublisherDisplayName, msix_version)
- Título / descrição curta / descrição completa (mesma proposta de valor que Play, mas “para PC Windows”)
- Privacidade URL + contacto
- Checklist: MSIX, screenshots desktop (`./scripts/capture_desktop_screenshots.sh`), age rating, submission
- Notas de versão exemplo

- [ ] **Step 2: Correr**

```bash
chmod +x scripts/msix_partner_brief.sh
./scripts/msix_partner_brief.sh | head -40
```

Expected: cabeçalho + identidade sem erros.

---

### Task 5: Documentação (`STORE.md`, `BETA.md`, índices)

**Files:**
- Modify: `docs/STORE.md` (append secção Microsoft Store)
- Modify: `docs/BETA.md`
- Modify: `docs/README.md`
- Modify: `docs/plano.md`
- Modify: `docs/roadmap/master-roadmap-v1.md`
- Modify: `README.md`
- Modify: `apps/phoenix_manager/MOBILE.md`
- Modify: `scripts/phase_e_status.sh`
- Modify: `docs/superpowers/specs/2026-07-18-microsoft-store-design.md` (estado → implementado quando Tasks 1–5 OK)

- [ ] **Step 1: Secção Microsoft Store em `docs/STORE.md`**

Após App Store / macOS, adicionar secção com:
1. Pré-requisitos (Partner Center, identidade tabela da spec, Windows + VS Build Tools)
2. Build: `./scripts/msix_doctor.sh` → em Windows `./scripts/build_msix.sh` → `./scripts/package_msix_store.sh`
3. Product identity (valores exactos)
4. Upload Packages no Partner Center
5. Assets (screenshots desktop, ícone)
6. Privacidade URL
7. Age rating / declarações (offline, sem IAP, 13+)
8. Actualizações: bump `version` no pubspec → rebuild MSIX com `msix_version` maior
9. Checklist final

- [ ] **Step 2: `BETA.md` — Windows**

Após secção Mac/Android:

```markdown
## Windows (desktop)

**Microsoft Store (recomendado para updates):** ver [`docs/STORE.md`](STORE.md) — MSIX.
Quem instala pela Store recebe actualizações automáticas.

**Partilha manual (sem updates automáticos):**
1. Em Windows: `flutter build windows --release`
2. ZIP da pasta `build/windows/x64/runner/Release/`
3. Amigo descompacta e corre `phoenix_manager.exe`

**MSIX `store: true`:** só para Partner Center (não é sideload fiável).
```

- [ ] **Step 3: Checklists e índices**

- `docs/README.md`: linha Microsoft Store → `STORE.md`
- `docs/plano.md`: tabela “Lojas — Microsoft Store” com scripts ✅ / publicação ⏳
- `master-roadmap-v1.md`: item Microsoft Store no MVP checklist
- `README.md` raiz: bloco comandos MSIX junto a Steam/Play
- `MOBILE.md`: uma linha a apontar `STORE.md` Microsoft Store
- `phase_e_status.sh`: secção Microsoft Store (doctor + existência do MSIX)

- [ ] **Step 4: Verificar docs localmente**

```bash
./scripts/msix_doctor.sh
./scripts/msix_partner_brief.sh >/dev/null
grep -n "Microsoft Store" docs/STORE.md docs/BETA.md docs/plano.md
```

Expected: doctor OK; grep encontra as secções.

---

### Task 6: Smoke final

**Files:** nenhum novo

- [ ] **Step 1: Doctors + version**

```bash
./scripts/msix_version.sh
./scripts/msix_doctor.sh
bash -n scripts/build_msix.sh scripts/package_msix_store.sh scripts/msix_partner_brief.sh scripts/msix_version.sh
```

Expected: version impressa; doctor FAIL=0; `bash -n` silencioso.

- [ ] **Step 2: (Só em Windows) build real**

```bash
./scripts/build_msix.sh
./scripts/package_msix_store.sh
ls -lh build/release/store/windows/
```

Expected: `phoenix_manager.msix` + ZIP.

- [ ] **Step 3: Actualizar estado do spec**

No design doc, mudar estado para `implementado` e marcar critérios de sucesso cumpridos (excepto upload Partner Center real, que fica ⏳).

---

## Spec coverage (self-review)

| Spec | Task |
|------|------|
| `msix` + identidade | 1 |
| `msix_version` mapping | 1 (`msix_version.sh`) + 3 |
| Scripts build/package/doctor/brief | 2–4 |
| `STORE.md` + BETA + roadmap/README | 5 |
| Artefacto `build/release/store/windows/` | 3 |
| Build só Windows / Mac valida | 2–3 |
| Sem gameplay | — respeitado |

**Placeholder scan:** nenhum TBD.  
**Nota commits:** omitidos por regra do utilizador; pedir commit no fim se quiser.
