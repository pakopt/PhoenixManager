# Folder structure (alvo)

Qual é a árvore de pastas alvo do monorepo?

Reflecte o [Monorepo Architecture](03-monorepo.md). **Não** exige que todos os caminhos existam em disco hoje.

## Árvore de produto desejada

```
Phoenix Platform/
├── apps/
│   ├── desktop/                 → carreira (Electron) — Milestone 4
│   ├── database-editor/         → editor de packs — Milestone 5
│   ├── cli/                     → época / sim headless — M1–M3
│   └── launcher/                → arranque / mods — futuro
├── packages/
│   ├── application/             → use cases; wires Domain + Runtime
│   ├── domain/                  → Bounded Contexts (futebol) — alvo
│   ├── runtime/                 → tick, scheduler, commit, buses — alvo
│   ├── ui/                      → Design System — alvo (M4+)
│   ├── shared/                  → IDs, tipos, utils sem I/O
│   ├── contracts/               → Zod schemas (hoje)
│   ├── database/                → Infrastructure: loaders
│   ├── match-engine/            → legado → migra para domain/runtime
│   ├── simulation/              → legado → migra para runtime
│   ├── calendar/                → legado → domain
│   ├── competition/             → legado → domain
│   ├── testing/                 → helpers partilhados de teste — alvo
│   └── tooling/                 → codegen / scripts — alvo
├── database/
│   ├── core/
│   ├── mods/
│   ├── indexes/
│   └── schemas/
├── docs/                        → Architecture Bible + contratos
├── saves/
└── tools/
```

## Layout interno típico de um package

```
packages/<name>/
├── package.json
├── README.md                    → aponta para Package Contract
├── src/
│   ├── index.ts                 → API pública
│   └── internal/                → não exportar
└── tests/
```

Bounded Contexts em `domain/` (quando existir):

```
packages/domain/
├── src/
│   ├── identity/
│   ├── contracts/               → Aggregate Contract (domínio)
│   ├── competition/
│   └── ...
└── ...
```

Cada BC: policies / specifications / handlers de eventos — sem I/O directo.

## O que não vai na árvore de produto

- Artefactos de build (`dist/`, `out/`, `.electron-cache/`)
- Saves de utilizador versionados no git
- Packages “só para experimentar” sem Package Contract

Ver também: [03-monorepo.md](03-monorepo.md) · [05-dependencies.md](05-dependencies.md) · [22-package-contracts.md](22-package-contracts.md)
