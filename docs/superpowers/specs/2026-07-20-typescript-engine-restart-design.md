# Phoenix Manager — TypeScript Engine Restart (Design)

**Date:** 2026-07-20  
**Status:** Approved  
**Scope:** Marco 1 — monorepo TS + database + simulation mínima + CLI headless

## Intent

Recomeçar o Project Phoenix Manager como um **Simulation Engine** extremamente rápido em TypeScript. O objectivo não é clonar Football Manager; é uma arquitectura Engine First onde a UI nunca alimenta a engine ao contrário.

```
UI → Application Layer → Simulation Engine → Database
```

O código Flutter v0.8 fica arquivado em `legacy/flutter/` (branch snapshot `legacy/flutter-v0.8`).

## Decisions

| Topic | Choice |
|-------|--------|
| Language | TypeScript everywhere |
| Desktop (future) | Electron + React + Tailwind + shadcn |
| Monorepo | pnpm workspaces + Turborepo |
| Approach | Thin vertical slice (no ghost packages) |
| Data | JSON shards + indexes + slug IDs + data packs |
| Marco 1 deliverable | Database loader + calendar + match L3 + season CLI |
| Flutter | Archived under `legacy/flutter/` |

## Section 1 — Repo transition

1. Branch `legacy/flutter-v0.8` snapshots the pre-restart tree.
2. Flutter code lives in `legacy/flutter/` on the TypeScript line of development.
3. Root monorepo is TypeScript only for active development.

Target tree (Marco 1):

```
legacy/flutter/
apps/cli/
packages/{contracts,shared,database,calendar,match-engine,simulation}/
database/core/
docs/superpowers/
```

## Section 2 — Database

- **Format:** JSON shards (~1000 entities/file), validated with Zod.
- **IDs:** slugs only (`london-fc-en`, `striker-01-london-fc-en`).
- **Refs:** IDs only (`clubId`, `nationId`) — never embedded objects.
- **Load:** `core/manifest.json` → shards → optional mods (override by slug) → in-memory `Map<string, T>` + indexes.
- **Seed (Marco 1):** 1 nation, 1 league, 20 clubs, ~20 players/club (~400 players), fictional names.
- **Saves:** contracts may stub patch shapes; runtime patches out of scope for Marco 1.

```
database/core/
  manifest.json
  nations/
  clubs/
  players/
  competitions/
database/mods/   # empty in Marco 1
```

## Section 3 — Simulation stack

| Package | Role |
|---------|------|
| `calendar` | Round-robin home/away fixtures; day iteration |
| `match-engine` | Layer-3 statistical results only (`homeGoals`/`awayGoals`) |
| `simulation` | `runSeason` orchestration + league table |
| `apps/cli` | `pnpm season -- --seed 42` |

- Goals at club level only (no individual scorers in Marco 1).
- Seeded RNG; same seed → same results.
- Performance target: full season (380 matches) &lt; 2s.

Layers 1–2, transfers, finance, club-ai, Electron UI: later marcos.

## Section 4 — Tooling

- Node 22+, TypeScript strict (`noUncheckedIndexedAccess`)
- Vitest, Zod, ESLint flat + Prettier
- Packages built with tsc/tsup; no React in engine packages
- Root scripts: `pnpm test`, `pnpm typecheck`, `pnpm season`

## Future marcos (reference only)

1. Electron + minimal “advance day” UI  
2. Saves/patches + mod packs  
3. Match layer 1 + richer competition engine  
4. Transfer, finance, club-ai, database editor  

## Out of scope (Marco 1)

Electron, editor, save patches runtime, transfer/finance/club-ai, match layers 1–2, individual scorers, Flutter save migration.
