# Phoenix Manager — Marco 3 Saves & Mods (Design)

**Date:** 2026-07-20  
**Status:** Approved (sections 1–3)  
**Depends on:** [Marco 2 Desktop](2026-07-20-marco-2-desktop-design.md)

## Intent

Persist career progress as **runtime deltas** over core data, and support **data pack mods** that override entities by slug — without duplicating the full world in each save.

## Decisions

| Topic | Choice |
|-------|--------|
| Scope | Saves + minimal mods (example rename pack) + desktop UI |
| Save model | Manifest + runtime deltas (matchday, table, lastResults, seed, modIds) |
| Save location | Dev: `<repo>/saves`; packaged: `userData/saves` |
| Entity patches | Out of scope (later when players mutate) |

## Save format

`saves/<slotId>/save.json`:

```json
{
  "version": 1,
  "savedAt": 0,
  "slotId": "career-01",
  "label": "Career 01",
  "seed": 42,
  "modIds": ["rename-pack"],
  "competitionId": "phoenix-premier-en",
  "matchday": 3,
  "table": [],
  "lastResults": []
}
```

Load: `loadWorld(core + modIds)` → regenerate fixtures from seed → restore matchday/table/lastResults.

## API

- `GameSession.save(slotId, label?)` / `load(slotId)` / `listSaves()`
- `listMods()` from `database/mods/*/manifest.json`
- `start({ seed, modIds })`
- Injected `savesRoot` + fs helpers for tests

## UI

Guardar, Carregar (lista), Nova sessão com checkboxes de mods.

## Done when

Save → new session → load restores state; rename-pack changes club names; `pnpm test` / `typecheck` / season / desktop still work.

## Out of scope

Per-entity patch files, cloud saves, Flutter migration.
