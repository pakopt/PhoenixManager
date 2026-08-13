# Package Contracts

O que deve documentar cada package antes (e depois) de existir código?

## Sempre

1. Escrever o contrato **antes** da primeira linha de código do package ([ADR-0035](../DECISIONS.md#adr-0035)).
2. Guardar o contrato em `docs/` (este ficheiro + secção por package, ou `docs/packages/<name>.md` linkada aqui).
3. Incluir: purpose, non-goals, consumers, events in/out, public API, dependências permitidas.
4. Actualizar o contrato quando a API pública mudar (breaking = bump + nota de migração).
5. Respeitar o diamond ([05-dependencies.md](05-dependencies.md)).

## Nunca

1. Criar `packages/<name>` só com `index.ts` vazio sem contrato.
2. Exportar “tudo” pelo `index.ts` — API pública mínima.
3. Listar consumers inventados; só apps/packages reais ou milestones planeados.
4. Domain package a declarar dependência de Runtime (ou o inverso).

## Template

```markdown
# Package: @phoenix/<name>

## Purpose
Uma frase: o que este package existe para fazer.

## Non-goals
O que **não** faz (evita scope creep).

## Consumers
Quem pode importar (apps / packages).

## Dependencies (allowed)
Lista explícita alinhada ao diamond.

## Events
| Direcção | Bus | Exemplos |
|----------|-----|----------|
| In | Domain / Application / Infrastructure / — | … |
| Out | … | … |

## Public API
- `functionOrType` — responsabilidade

## Failure modes
Como falha (erros tipados → 23-error-handling.md).

## Milestone
Quando pode ser criado em disco (ex.: M2).
```

## Exemplo: `packages/shared` (existe)

### Purpose

Tipos, IDs, utilitários **sem I/O** e contratos de transporte partilhados (ex. shapes de eventos) usados por Domain, Runtime, Application e Infrastructure.

### Non-goals

- Regras de futebol
- Leitura de filesystem / rede
- React / Electron
- Orquestração de ticks

### Consumers

Todos os packages e apps (folha do diamond).

### Dependencies (allowed)

Nenhuma dependência interna de outros `@phoenix/*` de domínio/runtime (só deps npm puras se necessário).

### Events

| Direcção | Bus | Exemplos |
|----------|-----|----------|
| In | — | Não consome |
| Out | — | Pode **definir tipos** de eventos; não publica |

### Public API (ilustrativo)

- Tipos de ID / helpers `{type}:{ulid}`
- Tipos base de Domain/Application/Infrastructure events (sem lógica)
- Utilitários puros (ex. result helpers)

### Failure modes

N/A em runtime de jogo; erros = misuse de tipos em compile-time.

### Milestone

Já em disco; evoluir sem quebrar consumers sem ADR.

---

## Exemplo: `packages/domain` (alvo — ainda não em disco)

### Purpose

Bounded Contexts e Domain Systems de futebol: policies, handlers que **propõem World Changes** e publicam **Domain Events**.

### Non-goals

- Tick / scheduler / commit (Runtime)
- Use cases de UI (Application)
- Loaders de database / saves (Infrastructure)
- Componentes React

### Consumers

- `packages/application` (wiring)
- Testes de simulação / Domain
- **Não** Runtime, **não** UI

### Dependencies (allowed)

- `shared`
- Ports de Infrastructure (interfaces), não loaders concretos se evitável
- **Proibido:** `runtime`, `ui`, React, Electron

### Events

| Direcção | Bus | Exemplos |
|----------|-----|----------|
| In | Domain Event Bus | `MatchFinished`, `ContractSigned`, … |
| Out | Domain Event Bus | factos past-tense do BC |

### Public API (ilustrativo)

- Systems registáveis: `TransferSystem`, `FinanceSystem`, …
- Schemas Zod de entidades do BC
- Factories de propostas de World Changes

### Failure modes

Ver [23-error-handling.md](23-error-handling.md) — invariantes de Aggregate, eventos inconsistentes.

### Milestone

M3 Football Engine (scaffold só com contrato + ADR).

---

## Checklist ao criar package

- [ ] Contrato preenchido e linkado no README do package
- [ ] ADR se for package de topo novo
- [ ] Entrada na tabela actual→alvo em [03-monorepo.md](03-monorepo.md)
- [ ] Gates de teste definidos

Ver também: [Vol. 21](../bible/21-development-architecture.md) · [20-coding-standards.md](20-coding-standards.md)
