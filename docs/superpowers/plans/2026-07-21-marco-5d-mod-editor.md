# Marco 5d Mod Editor — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Desktop mod pack writer for clubs/players under `database/mods/`, with create/override/remove, Zod validation, and Mods-panel UI; career picks up changes via existing “Aplicar mods / reiniciar”.

**Architecture:** Pure `mod-editor.ts` in `@phoenix/application` using `SaveFs` + existing shard shape; IPC `modEditor:*` in Electron; extend Mods section in `App.tsx`. Core remains read-only; loader unchanged.

**Tech Stack:** Existing TS monorepo, Zod (`clubSchema`/`playerSchema`/`slugSchema`/`modInfoSchema`), Vitest, Electron + React/Zustand, `@phoenix/database` `loadWorld` for integration checks.

## Global Constraints

- Architecture: UI → Application → Database; renderer never imports DB/fs
- Edit mods only (`database/mods/`), never `database/core/`
- Entities: clubs + players only; full Zod entities in shards (not partial patches)
- Layout: `mods/<id>/manifest.json`, `clubs/clubs-00001.json`, `players/players-00001.json`
- `source`: `core` | `mod` | `new` as defined in the spec
- Career refresh only via restart with mod selected (keep auto-start)
- Spec: `docs/superpowers/specs/2026-07-21-marco-5d-mod-editor-design.md`

## File map

| Path | Responsibility |
|------|----------------|
| `packages/application/src/mod-editor.ts` | create/load/upsert/remove mod entities |
| `packages/application/src/mod-editor.test.ts` | Unit + loadWorld integration |
| `packages/application/src/index.ts` | Exports |
| `apps/desktop/electron/main.ts` | IPC handlers |
| `apps/desktop/electron/preload.ts` | Bridge |
| `apps/desktop/src/vite-env.d.ts` | Types |
| `apps/desktop/src/store.ts` | Editor state/actions |
| `apps/desktop/src/App.tsx` | Mods + Editor UI |
| `docs/plano.md` | Marco 5d ✅ |

---

### Task 1: mod-editor helpers + tests

**Files:**
- Create: `packages/application/src/mod-editor.ts`
- Create: `packages/application/src/mod-editor.test.ts`
- Modify: `packages/application/src/index.ts`

**Interfaces:**
- Consumes: `SaveFs` from `./persistence.js`; `clubSchema`, `playerSchema`, `slugSchema`, `modInfoSchema`, types from `@phoenix/contracts`; optionally `loadWorld` from `@phoenix/database` in tests only
- Produces:

```ts
export type EditorSource = 'core' | 'mod' | 'new';

export type EditorClub = Club & { source: EditorSource };
export type EditorPlayer = Player & { source: EditorSource };

export type EditorWorld = {
  modId: string;
  clubs: EditorClub[];
  players: EditorPlayer[];
  nationIds: Slug[]; // from core (for player form)
};

export function createMod(
  fs: SaveFs,
  databaseRoot: string,
  input: { id: string; name: string },
): Promise<ModInfo>;

export function updateModManifest(
  fs: SaveFs,
  databaseRoot: string,
  modId: string,
  patch: { name: string; version?: string },
): Promise<ModInfo>;

export function loadEditorWorld(
  fs: SaveFs,
  databaseRoot: string,
  modId: string,
): Promise<EditorWorld>;

export function upsertModClub(
  fs: SaveFs,
  databaseRoot: string,
  modId: string,
  club: Club,
): Promise<EditorWorld>;

export function upsertModPlayer(
  fs: SaveFs,
  databaseRoot: string,
  modId: string,
  player: Player,
): Promise<EditorWorld>;

export function removeModClub(
  fs: SaveFs,
  databaseRoot: string,
  modId: string,
  clubId: Slug,
): Promise<EditorWorld>;

export function removeModPlayer(
  fs: SaveFs,
  databaseRoot: string,
  modId: string,
  playerId: Slug,
): Promise<EditorWorld>;
```

**Implementation notes:**

```ts
const CLUBS_SHARD = 'clubs-00001.json';
const PLAYERS_SHARD = 'players-00001.json';

async function assertModExists(fs: SaveFs, modRoot: string): Promise<void> {
  try {
    await fs.readFile(fs.joinPath(modRoot, 'manifest.json'));
  } catch {
    throw new Error('Mod não encontrado');
  }
}

async function readShardEntities<T>(
  fs: SaveFs,
  filePath: string,
  parseOne: (raw: unknown) => T,
): Promise<T[]> {
  try {
    const raw = JSON.parse(await fs.readFile(filePath)) as unknown;
    const entities = (raw as { entities?: unknown }).entities;
    if (!Array.isArray(entities)) return [];
    return entities.map(parseOne);
  } catch {
    return [];
  }
}

async function writeShardEntities<T extends { id: string }>(
  fs: SaveFs,
  dir: string,
  fileName: string,
  entities: T[],
): Promise<void> {
  await fs.mkdir(dir, { recursive: true });
  const path = fs.joinPath(dir, fileName);
  await fs.writeFile(path, `${JSON.stringify({ entities }, null, 2)}\n`);
}
```

For `loadEditorWorld`:
1. Verify mod exists.
2. Load core clubs/players/nations via reading `databaseRoot/core/...` shards (same parse as above) — do **not** mutate core.
3. Load mod clubs/players shards.
4. Build maps; annotate source; return sorted arrays by id.

For `upsertModPlayer`: after parse, ensure `nationId` ∈ core nations and `clubId` ∈ effective clubs (core∪mod after applying this player’s club if upserting club first is caller’s job — validate against world loaded **before** write, including current mod clubs).

Errors (PT):
- `Mod não encontrado`
- `Mod já existe`
- `Slug inválido` (from Zod message ok)
- `Clube de referência inválido` / `Nação de referência inválida`
- `Entidade não existe neste mod` (remove)

- [ ] **Step 1: Failing tests** in `mod-editor.test.ts` using `mkdtemp` + minimal core+mods tree (copy pattern from `packages/database/src/loader.test.ts`).

```ts
it('createMod writes manifest', async () => { /* … */ });
it('createMod throws if exists', async () => { /* … */ });
it('upsertModClub overrides core club in editor world as source mod', async () => { /* … */ });
it('upsertModClub can create new club as source new', async () => { /* … */ });
it('removeModClub restores core-only source', async () => { /* … */ });
it('upsertModPlayer rejects unknown clubId', async () => { /* … */ });
it('loadWorld with modIds sees upserted club name', async () => {
  // after upsert, call loadWorld from @phoenix/database
});
```

- [ ] **Step 2:** `pnpm --filter @phoenix/application test` — FAIL on missing module.

- [ ] **Step 3: Implement** `mod-editor.ts`; tests PASS; typecheck PASS.

- [ ] **Step 4: Export** from `packages/application/src/index.ts`.

- [ ] **Step 5: Commit**

```bash
git add packages/application/src/mod-editor.ts packages/application/src/mod-editor.test.ts packages/application/src/index.ts
git commit -m "$(cat <<'EOF'
feat(application): add mod-editor create/upsert/remove helpers

EOF
)"
```

---

### Task 2: Desktop IPC + Mods Editor UI

**Files:**
- Modify: `apps/desktop/electron/main.ts`
- Modify: `apps/desktop/electron/preload.ts`
- Modify: `apps/desktop/src/vite-env.d.ts`
- Modify: `apps/desktop/src/store.ts`
- Modify: `apps/desktop/src/App.tsx`

**Interfaces:**
- Consumes: Task 1 exports
- Produces: `window.phoenix.modEditor` API + UI

**main.ts** (use existing `nodeFs` + `databaseRoot()`):

```ts
import {
  createMod,
  loadEditorWorld,
  removeModClub,
  removeModPlayer,
  updateModManifest,
  upsertModClub,
  upsertModPlayer,
} from '@phoenix/application';

ipcMain.handle('modEditor:create', (_e, input: { id: string; name: string }) =>
  createMod(nodeFs, databaseRoot(), input),
);
ipcMain.handle('modEditor:loadWorld', (_e, modId: string) =>
  loadEditorWorld(nodeFs, databaseRoot(), modId),
);
ipcMain.handle('modEditor:upsertClub', (_e, modId: string, club: Club) =>
  upsertModClub(nodeFs, databaseRoot(), modId, club),
);
// upsertPlayer, removeClub, removePlayer, updateManifest similarly
```

**preload + vite-env:** nest under `modEditor: { create, loadWorld, upsertClub, upsertPlayer, removeClub, removePlayer, updateManifest }`.

**store.ts** state additions:

```ts
editingModId: string | null;
editorWorld: EditorWorld | null;
editorTab: 'clubs' | 'players';
editorError: string | null;
// actions: openEditor, closeEditor, createModPack, saveClub, savePlayer, removeClub, removePlayer, refreshEditor
```

After create/upsert/remove: set `editorWorld` from return value; call `refreshLists()` so mods list updates.

**App.tsx** — in Mods section:
- Inputs + button **Criar mod**.
- Each mod row: checkbox + **Editar** → `openEditor(mod.id)`.
- If `editingModId` and `editorWorld`: panel with tabs, list, form fields matching Club/Player schemas, Guardar / Remover / Novo.
- Exhaustive switch on `source` for badge labels: Core / Mod / Novo.
- Keep **Aplicar mods / reiniciar**.

- [ ] **Step 1: Wire IPC + preload + types**

- [ ] **Step 2: Store + App UI**

- [ ] **Step 3:** `pnpm --filter @phoenix/desktop typecheck` — PASS

- [ ] **Step 4: Commit**

```bash
git add apps/desktop
git commit -m "$(cat <<'EOF'
feat(desktop): mod editor UI for clubs and players

EOF
)"
```

---

### Task 3: Docs plano

**Files:**
- Modify: `docs/plano.md` — version/fase **Marco 5d**; row **5d** ✅; note mod editor clubs/players; optional note 5d.2 out of scope

- [ ] **Step 1: Update plano**

- [ ] **Step 2: Commit**

```bash
git commit -m "$(cat <<'EOF'
docs: mark Marco 5d mod editor complete in plano

EOF
)"
```

---

## Self-review (plan vs spec)

| Spec | Task |
|------|------|
| createMod / manifest | 1 |
| loadEditorWorld + source badges | 1, 2 |
| upsert/remove club & player | 1 |
| Zod + ref checks | 1 |
| loadWorld sees override | 1 |
| IPC + Mods UI | 2 |
| Aplicar mods path unchanged | 2 |
| plano 5d | 3 |
| Out of scope (core edit, nations UI, lobby) | not scheduled |

No TBD. Types `EditorWorld` / `EditorSource` consistent across tasks.
