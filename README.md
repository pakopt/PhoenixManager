# Project Phoenix Manager

**Engine First** — TypeScript simulation engine. The desktop UI comes later; the engine never depends on React.

## Active stack (Marco 1)

```
apps/cli                    ← headless season runner
        ↓
packages/simulation         ← orchestration
   ├── calendar
   ├── match-engine         ← layer-3 statistical results
   └── database             ← JSON shards + indexes + data packs
        ↓
packages/contracts + shared ← Zod schemas, seeded RNG
        ↓
database/core               ← game data files
```

| Package / App | Role |
|---------------|------|
| `@phoenix/contracts` | Zod schemas, slug IDs |
| `@phoenix/shared` | Seeded RNG, shared utils |
| `@phoenix/database` | Load packs → in-memory Maps |
| `@phoenix/calendar` | League fixtures |
| `@phoenix/match-engine` | Layer-3 match results |
| `@phoenix/simulation` | `runSeason` |
| `apps/cli` | `pnpm season` |

## Quick start

```bash
pnpm install
pnpm test
pnpm typecheck
pnpm season -- --seed 42
```

Requires **Node 22+** and **pnpm**.

## Architecture rules

1. Simulation packages must not import UI frameworks.
2. Entities reference each other by **slug IDs** only.
3. Lookups are `Map<string, T>` (O(1)).
4. World data lives in JSON shards under `database/`; mods override by slug.

Design: [`docs/superpowers/specs/2026-07-20-typescript-engine-restart-design.md`](docs/superpowers/specs/2026-07-20-typescript-engine-restart-design.md)

## Legacy Flutter

The previous Flutter/Dart game (PSE v0.8) is archived under [`legacy/flutter/`](legacy/flutter/). Snapshot branch: `legacy/flutter-v0.8`. Store/launch docs for that stack: [`docs/legacy/`](docs/legacy/).

Privacy policy (shared): [`docs/PRIVACY.md`](docs/PRIVACY.md)
