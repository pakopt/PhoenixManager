# Monorepo Architecture

Como está (e como deve ficar) o monorepo da Phoenix Platform?

**Âmbito:** documentação do layout alvo. Nenhum package novo é criado nesta entrega — ver [Vol. 21](../bible/21-development-architecture.md) e [ADR-0035](../DECISIONS.md#adr-0035).

## Princípios

1. **Um workspace pnpm** (`apps/*`, `packages/*`) — builds e testes partilham lockfile.
2. **Diamond de dependências:** Application depende de Domain **e** Runtime; Runtime **não** depende de Domain.
3. **Apps finas:** Electron/CLI só shell + wiring; regras de futebol em Domain; ciclo de tick em Runtime.
4. **Contrato antes de código:** package novo exige [Package Contract](22-package-contracts.md) aprovado.
5. **Migração incremental:** packages actuais continuam; mapeamento actual→alvo abaixo; moves físicos só em milestones com ADR.

## Tech stack (workspace)

| Camada | Tecnologia |
|--------|------------|
| Linguagem | TypeScript (strict) |
| Packages | pnpm workspaces |
| Validação | Zod |
| Testes | Vitest (+ gates em [Testing Strategy](../80-testing/00-testing-strategy.md)) |
| Desktop | Electron + React (só apps / `packages/ui`) |
| Dados | JSON packs → Compiled Database (Infrastructure) |

## Grafo diamond (canónico)

```
                    ┌─────────────┐
                    │    Apps     │
                    │ desktop/cli │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │ Application │  (use cases; wiring)
                    └──┬───────┬──┘
                       │       │
              ┌────────▼─┐   ┌─▼────────┐
              │  Domain  │   │ Runtime  │
              └─────┬────┘   └────┬─────┘
                    │             │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │Infrastructure│
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │   Shared    │
                    └─────────────┘
```

**Regra de ouro:** `packages/runtime` **nunca** importa `packages/domain` (nem futuros `domain/*`). O Application injeta Domain Systems no Runtime (scheduler, commit, buses).

Rejeitado: Runtime → Domain (acoplava o motor genérico a futebol). Ver [05-dependencies.md](05-dependencies.md).

## Árvore alvo (docs only)

```
Phoenix Platform/
├── apps/
│   ├── desktop/                 # hoje: carreira + editor Mods embutido
│   ├── database-editor/         # futuro (hoje: painel Mods)
│   ├── cli/                     # simulação headless / época
│   └── launcher/                # futuro
├── packages/
│   ├── application/             # use cases; wiring Domain + Runtime
│   ├── domain/                  # ALVO — BCs de futebol (ainda não em disco)
│   ├── runtime/                 # ALVO — tick, scheduler, commit (ainda não em disco)
│   ├── ui/                      # ALVO — design system (ainda não em disco)
│   ├── shared/                  # tipos, IDs, utilitários sem I/O
│   ├── contracts/               # schemas Zod partilhados (hoje)
│   ├── database/                # loaders / WorldDatabase (hoje)
│   ├── match-engine/            # hoje; futuro → domain/competition + runtime pipeline
│   ├── simulation/              # hoje; futuro → runtime + domain systems
│   ├── calendar/                # hoje; futuro → domain
│   ├── competition/             # hoje; futuro → domain
│   ├── testing/                 # ALVO — helpers de teste (ainda não em disco)
│   └── tooling/                 # ALVO — scripts/CLI internos (ainda não em disco)
├── database/
│   ├── core/
│   ├── mods/
│   ├── indexes/                 # alvo
│   └── schemas/                 # alvo (hoje parte em contracts)
├── docs/
├── saves/
└── tools/
```

## Mapeamento actual → alvo

| Actual (disco) | Alvo (conceito) | Notas |
|----------------|-----------------|-------|
| `apps/desktop` | `apps/desktop` (+ extract editor) | Renomear para `manager-desktop` só com ADR |
| `apps/cli` | `apps/cli` / `tools/` | Headless até M3 |
| `packages/application` | `packages/application` + extract | Wiring; extrair Domain Systems aos poucos |
| `packages/match-engine` | `domain/*` + Runtime pipeline | Sem move nesta fase |
| `packages/simulation` | `packages/runtime` (núcleo) + Domain | Sem move nesta fase |
| `packages/calendar` | `domain/calendar` (BC) | Sem move nesta fase |
| `packages/competition` | `domain/competition` | Sem move nesta fase |
| `packages/contracts` | `shared` / `database/schemas` | Manter até migração |
| `packages/shared` | `packages/shared` | Base do diamond |
| `packages/database` | Infrastructure | Loaders; sem React |
| — | `packages/domain` | Só após Package Contract + M1 |
| — | `packages/runtime` | Só após Package Contract + M2 |
| — | `packages/ui` | Só com Desktop Client (M4) |

## Apps

| App | Papel | Milestone |
|-----|-------|-----------|
| CLI / headless | Época, benches, regressão | M1–M3 |
| Desktop | Phoenix Manager (carreira) | M4 |
| Database Editor | Packs / mods | M5 |
| Launcher | Selecção de carreira/mods | pós-M5 |

## Convenções de package

- Nome: `@phoenix/<name>` (ou escopo actual do repo — manter consistência).
- Entrada pública única (`src/index.ts`); internals não exportados.
- Cada package: `README.md` + [Package Contract](22-package-contracts.md) linkado.
- Testes no próprio package; gates em [00-testing-strategy.md](../80-testing/00-testing-strategy.md).

## Regras de import (resumo)

| Sempre | Nunca |
|--------|-------|
| Apps → Application, UI | Domain → UI / React / Electron |
| Application → Domain, Runtime, Infra, Shared | Runtime → Domain |
| Domain → Shared (+ Infra via ports) | Domain → outro Domain (chamada directa) |
| Runtime → Shared, Infra (ports) | Match/Domain → React |
| Tudo → Shared (tipos puros) | Circulares entre packages |

## Evolução

1. Docs + contratos (esta entrega).
2. M1 Foundation: Shared + contracts + database loaders estáveis.
3. M2 Runtime package (sem Domain).
4. M3 Football Engine em Domain, wired por Application.
5. M4 Desktop Client sobre Application.
6. Moves físicos de engines → Domain só com ADR + Package Contract actualizado.

Ver também: [04-folder-structure.md](04-folder-structure.md) · [05-dependencies.md](05-dependencies.md) · [Vol. 21](../bible/21-development-architecture.md) · [Platform Milestones](../90-roadmap/00-platform-milestones.md)
