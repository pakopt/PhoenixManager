# Phoenix Manager — Marco 5d Database Mod Editor (Design)

**Date:** 2026-07-21  
**Status:** Approved  
**Depends on:** [Marco 5c Club AI](2026-07-21-marco-5c-club-ai-design.md), existing mod load in `@phoenix/database`

## Intent

Ship a **mod pack writer** in the desktop app: create and edit mods under `database/mods/` that override or add **clubs** and **players**. Core packs stay read-only. Changes apply to a career only when the user restarts with that mod selected (existing “Aplicar mods / reiniciar”).

## Decisions

| Topic | Choice |
|-------|--------|
| Approach | Helpers in `@phoenix/application` (`mod-editor.ts`) + IPC + Mods panel UI (no new package) |
| Target | Mod packs on disk, not core and not in-session save patches |
| Entities | Clubs + players only |
| Create | Override existing slugs **and** create new entities |
| UI surface | Extend **Mods (nova sessão)** panel; editor works on disk; career refreshes via restart |
| Auto-start | Keep current auto-`start`; no dedicated lobby in this marco |
| Shard layout | One shard file per entity type per mod (`clubs-00001.json`, `players-00001.json`) |

## Architecture

```
Desktop Mods panel
  → IPC modEditor:*
  → mod-editor.ts (SaveFs + Zod)
  → database/mods/<id>/{manifest,clubs,players}
Loader (unchanged): core then modIds override by slug
```

- Editor does **not** go through `GameSession` mutations.
- Reuse `listMods` / `modInfoSchema` / existing shard `{ entities: T[] }` shape (see `rename-pack`).

## Mod file layout

```
database/mods/<modId>/
  manifest.json                 # { id, name, version }
  clubs/clubs-00001.json        # { entities: Club[] }
  players/players-00001.json    # { entities: Player[] }
```

- `modId` must match `slugSchema`.
- Entities in the mod are **full** Zod objects (same as core), not partial patches.
- Removing an entity from the mod restores core behaviour for that slug on next load.
- Cannot delete or rewrite core files from the Editor.

## Effective world view

`loadEditorWorld(databaseRoot, modId)`:

1. Load core clubs + players.
2. Load mod shards (if present).
3. Merge by slug (mod wins).
4. Annotate each row: `source: 'core' | 'mod' | 'new'`
   - `core` — only in core  
   - `mod` — slug exists in core and overridden in mod  
   - `new` — slug only in mod  

## Application API (`mod-editor.ts`)

| Method | Behaviour |
|--------|-----------|
| `createMod(fs, root, { id, name })` | mkdir + `manifest.json` (`version: "0.1.0"`); throw if exists |
| `updateModManifest(fs, root, modId, { name, version? })` | Patch display fields |
| `loadEditorWorld(fs, root, modId)` | Merged clubs/players + source |
| `upsertModClub(fs, root, modId, club)` | `clubSchema.parse`; write into mod clubs shard |
| `upsertModPlayer(fs, root, modId, player)` | `playerSchema.parse`; `clubId` and `nationId` must exist in effective world (core∪mod clubs + core nations) |
| `removeModClub` / `removeModPlayer` | Remove from mod shard only; error if entity not in mod |

Writing strategy: read existing mod shard (or empty `entities: []`), upsert/remove by id, write pretty JSON + trailing newline (same style as saves).

## Desktop

- In **Mods (nova sessão)**:
  - **Criar mod** (id + name).
  - Per mod: checkbox (existing) + **Editar**.
- Editor panel (when a mod is open for edit):
  - Tabs Clubes | Jogadores.
  - List with source badge; select → form; Guardar no mod / Remover do mod.
  - Novo clube / Novo jogador (slug + fields).
- After edits: user runs **Aplicar mods / reiniciar** with the mod checked.
- IPC: `modEditor:create`, `modEditor:loadWorld`, `modEditor:upsertClub`, `modEditor:upsertPlayer`, `modEditor:removeClub`, `modEditor:removePlayer`, `modEditor:updateManifest` (names may be nested under `window.phoenix.modEditor`).

## Testing / success

- Unit: createMod; upsert override; upsert new; remove restores core-only view; reject bad slug / broken `clubId`; reject write when mod missing.
- Integration: after upsert, `loadWorld({ modIds: [id] })` (or session start) sees override.
- Desktop: create mod, edit club name, restart with mod → name visible.
- `pnpm test` + `pnpm typecheck` green.

## Out of scope

- Editing `database/core/`
- Nations / competitions UI
- Multi-shard splitting / pack compression
- Hot-reload without session restart
- In-session cheat editor (save `patches`)
- Dedicated pre-start lobby (disable auto-start)
- `@phoenix/mod-editor` package extraction

## Roadmap

Mark **5d** ✅ in `docs/plano.md` when done. Optional follow-ups: 5d.2 nations/competitions, lobby without auto-start.
