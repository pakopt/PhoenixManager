# Testing Strategy

Qual é a estratégia de testes da Phoenix Platform e que gates são obrigatórios?

Hub: [Volume 18](../bible/18-testing.md).

## Pirâmide

| Camada | O quê | Onde |
|--------|-------|------|
| **Unit** | Policies, schemas Zod, pure functions, Aggregates | `packages/*/tests` |
| **Integration** | Application + Runtime + Domain wired; loaders | tests de package application / futuros |
| **Simulation** | Época/tick determinístico com seed fixo | CLI / sim harness |
| **Regression** | Fixtures de save/época; golden outputs | `80-testing` + CI |
| **Performance** | Budgets de tick/match/load | [13-performance-tests.md](13-performance-tests.md) |

## Sempre

1. Todo package com lógica tem testes unitários.
2. Mudanças de Domain / Runtime: pelo menos um teste de **Simulation** com seed fixo.
3. Mudanças de save schema: teste de **migração** + load fail-closed.
4. Mudanças de índices/hot path: gate de **Performance** ou justificação no PR.
5. CI verde (`pnpm test`, `pnpm typecheck`) antes de merge.
6. Testes determinísticos — sem `Date.now()` / `Math.random()` no Domain.

## Nunca

1. “Testei à mão no Desktop” como único gate para mudanças de Domain/Runtime.
2. Snapshots gigantes opacos sem documentar o invariante.
3. Skip de testes flaky sem issue + quarantine.
4. Testes que dependem de ordem de ficheiros no disco sem fixture isolada.

## Gates por tipo de mudança

| Tipo de mudança | Unit | Integration | Simulation | Regression | Performance |
|-----------------|------|-------------|------------|------------|-------------|
| Pure refactor (mesmo comportamento) | ✓ afectados | — | — | opcional | — |
| Policy / Aggregate Domain | ✓ | opcional | ✓ se afecta tick | — | — |
| Runtime (tick/commit/buses) | ✓ | ✓ | ✓ | ✓ se contrato de época | opcional |
| Save schema / migration | ✓ schemas | ✓ load/save | — | ✓ fixtures antigas | — |
| Mod / DB validation | ✓ | ✓ compile/validate | — | ✓ packs amostra | — |
| UI only (React) | component se existir | — | — | — | — |
| Índice / hot path | ✓ | — | ✓ | — | ✓ |
| Package novo | ✓ smoke | ✓ wiring | conforme milestone | — | — |
| Docs only | — | — | — | — | — |

✓ = obrigatório para merge.

## Failure modes

| Sintoma | Causa | Fix |
|---------|-------|-----|
| CI verde, época diverge | Falta simulation gate | Adicionar seed fixture |
| Flaky match | Random sem seed | RandomService |
| Perf regrediu sem alerta | Sem budget test | Adicionar em 13-performance-tests |

## Comandos (hoje)

```bash
pnpm test
pnpm typecheck
pnpm season -- --seed 42
```

Ver também: [01-unit-tests.md](01-unit-tests.md) · [10-integration.md](10-integration.md) · [11-simulation-validation.md](11-simulation-validation.md) · [12-regression.md](12-regression.md) · [13-performance-tests.md](13-performance-tests.md)
