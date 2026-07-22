# Three Engineering Pillars — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add three Architecture Bible pillars (Simulation Runtime, Data Architecture, Domain Architecture) as canonical indexes above the 20 volumes, plus rules so future docs reference pillars instead of redefining core concepts.

**Architecture:** Structure-only indexes in `docs/bible/pillars/`; Bible README leads with pillars; volumes stay satellites; AGENTS / ARCHITECTURE_RULES / STYLE_GUIDE / ADR enforce the rule. No volume body merges.

**Tech Stack:** Markdown under `docs/` (no code).

## Global Constraints

- Spec: `docs/superpowers/specs/2026-07-22-three-engineering-pillars-design.md`
- Layer above volumes 1–20; volumes become satellites (do not renumber or delete volumes)
- Structure only — pillar docs are indexes (question, boundaries, concept links, official docs, satellite rule); do not paste full volume prose
- Do not rewrite Vol. 5 / 3–4 / 9 / 16 bodies; do not scrub Club/Match/Transfer docs
- Portuguese narrative; English type/concept names where already used
- **Prerequisite branch:** Prefer base that already has `docs/AGENTS.md`, `docs/DECISIONS.md`, and Volume 6 / event docs (e.g. merge `main` after [PR #5](https://github.com/pakopt/PhoenixManager/pull/5) or rebase onto `feat/three-level-event-buses`). If those files are missing, Task 3 creates minimal stubs rather than inventing unrelated content.

## File map

| Path | Responsibility |
|------|----------------|
| `docs/bible/pillars/README.md` | Pillar vs satellite; obligation for new docs |
| `docs/bible/pillars/simulation-runtime.md` | Simulation Runtime index |
| `docs/bible/pillars/data-architecture.md` | Data Architecture index |
| `docs/bible/pillars/domain-architecture.md` | Domain Architecture index |
| `docs/bible/README.md` | Lead with pillars; label volumes as satellites |
| `docs/AGENTS.md` | Engineering spine = three pillars |
| `docs/ARCHITECTURE_RULES.md` | Docs must not redefine pillar concepts |
| `docs/STYLE_GUIDE.md` | New docs declare pillars first |
| `docs/DECISIONS.md` | ADR 2026-07-22 three pillars |
| `docs/README.md` | Optional one-line Bible → pillars |
| Spec status line | Point to this plan |

---

### Task 1: Create `docs/bible/pillars/` (README + three indexes)

**Files:**
- Create: `docs/bible/pillars/README.md`
- Create: `docs/bible/pillars/simulation-runtime.md`
- Create: `docs/bible/pillars/data-architecture.md`
- Create: `docs/bible/pillars/domain-architecture.md`

**Interfaces:**
- Consumes: pillar map from design spec
- Produces: four files linked by later Bible/agents tasks

- [ ] **Step 1: Create directory and `docs/bible/pillars/README.md`**

```markdown
# Engineering Pillars

A Architecture Bible organiza-se em **três pilares** (fonte de verdade de engenharia) e **satélites** (volumes 1–20 e docs temáticos).

| Pilar | Pergunta | Documento |
|-------|----------|-----------|
| Simulation Runtime | Como o motor executa a simulação? | [simulation-runtime.md](simulation-runtime.md) |
| Data Architecture | Como os dados vivem, persistem e se consultam? | [data-architecture.md](data-architecture.md) |
| Domain Architecture | Como as regras de futebol se organizam? | [domain-architecture.md](domain-architecture.md) |

## Pilar vs satélite

- **Pilar:** índice canónico — pergunta, fronteiras, conceitos com links, documentos oficiais. Não duplica o corpo dos volumes.
- **Satélite:** volume da Bible ou doc temático (Club, Match, Transfer, Finance, …). Explica o tema; **referencia** o(s) pilar(es); **não** redefine Tick, World State, World Changes, Event Buses, IDs `{type}:{ulid}`, Aggregate de vínculo, nem a estrutura de Bounded Contexts.

## Obrigação para docs novos

No topo do satélite, declarar:

```markdown
**Pilares:** [Simulation Runtime](../pillars/simulation-runtime.md) · …
```

(Ajustar o caminho relativo conforme a pasta do satélite.)

Só depois desenvolver o conteúdo específico do tema.

Índice da Bible: [../README.md](../README.md). Design: [../../superpowers/specs/2026-07-22-three-engineering-pillars-design.md](../../superpowers/specs/2026-07-22-three-engineering-pillars-design.md).
```

- [ ] **Step 2: Create `docs/bible/pillars/simulation-runtime.md`**

```markdown
# Simulation Runtime

## Pergunta

Como o motor executa a simulação?

## Fronteiras

Este pilar **não** é:

- regras de futebol / Bounded Contexts → [Domain Architecture](domain-architecture.md)
- persistência, IDs, saves, compiled DB → [Data Architecture](data-architecture.md)
- UI, Electron, React → satélites Vol. 13 / Platform Overview

## Conceitos canónicos

Ligar — não redefinir aqui:

| Conceito | Onde |
|----------|------|
| Simulation Tick / ciclo | [Vol. 5](../05-core-business-processes.md) · [01-simulation-cycle.md](../../16-processes/01-simulation-cycle.md) |
| World Changes / Commit | [02-world-changes.md](../../16-processes/02-world-changes.md) |
| World State (após Commit) | [Platform Overview](../../10-architecture/01-overview.md) |
| Simulation Scheduler | Vol. 5 · Module Map |
| RandomService / determinismo | Vol. 5 · `01-simulation-cycle.md` |
| Domain Event Bus (efeitos entre systems) | [Vol. 6](../06-event-driven-architecture.md) · [Event Buses](../../10-architecture/07-event-system.md) |
| Events ≠ World Changes | Vol. 5 · Vol. 6 |

## Documentos oficiais

- [Volume 5 — Core Business Processes](../05-core-business-processes.md)
- [Volume 6 — Event-Driven Architecture](../06-event-driven-architecture.md)
- `docs/16-processes/`
- Platform Overview — Simulation Runtime / Event Buses ([01-overview.md](../../10-architecture/01-overview.md))

## Regra para satélites

Docs de Match day, advance day, simulação automática, etc. **ligam a este pilar**; não reexplicam o Tick nem World Changes.
```

- [ ] **Step 3: Create `docs/bible/pillars/data-architecture.md`**

```markdown
# Data Architecture

## Pergunta

Como os dados vivem, são persistidos e consultados?

## Fronteiras

Este pilar **não** é:

- ciclo de Tick / Scheduler → [Simulation Runtime](simulation-runtime.md)
- regras de futebol / Aggregates de domínio → [Domain Architecture](domain-architecture.md)
- layouts de UI → Vol. 13

## Conceitos canónicos

| Conceito | Onde |
|----------|------|
| IDs `{type}:{ulid}` | [12-ids.md](../../20-database/12-ids.md) |
| Compiled Database | Vol. 9 · Platform Overview |
| Schemas / packs | [Vol. 9](../09-database.md) · `docs/20-database/` |
| Saves (deltas, não DB completa) | [Vol. 16](../16-save-system.md) · `docs/60-save-system/` |
| Mods / data packs | Vol. 15 · `20-database` / modding docs |
| Referências só por ID (nunca objectos) | `ARCHITECTURE_RULES.md` · Vol. 9 |

## Documentos oficiais

- [Volume 9 — Database](../09-database.md)
- [Volume 16 — Save System](../16-save-system.md)
- `docs/20-database/`
- `docs/60-save-system/` (se existir)

## Regra para satélites

Docs de schema de Club/Player, save format, compiler, etc. **ligam a este pilar**; não redefinem o formato de ID nem a filosofia Compiled DB vs save.
```

- [ ] **Step 4: Create `docs/bible/pillars/domain-architecture.md`**

```markdown
# Domain Architecture

## Pergunta

Como as regras de futebol estão organizadas?

## Fronteiras

Este pilar **não** é:

- orquestração do Tick → [Simulation Runtime](simulation-runtime.md)
- ficheiros / saves / IDs wire format → [Data Architecture](data-architecture.md)
- ecrãs do Manager → Vol. 13

## Conceitos canónicos

| Conceito | Onde |
|----------|------|
| Taxonomias Human / Organization / Place / Competition | [Vol. 3](../03-domain-model.md) · [15-domain/01-overview.md](../../15-domain/01-overview.md) |
| Relationships-first · Aggregate de vínculo | `15-domain/01-overview.md` · ARCHITECTURE_RULES |
| Contract Aggregate | `15-domain/05-contract.md` · `06-contract-aggregate.md` |
| Bounded Contexts / Domain Systems | [Module Map](../../10-architecture/19-module-map.md) |
| Entity Specification | [Vol. 4](../04-entity-specification.md) |
| Ubiquitous Language | `15-domain/03-ubiquitous-language.md` |
| Player = união de BCs (não god-object) | `15-domain/04-player.md` |
| Motores de domínio (satélites) | [Vol. 10](../10-game-engine.md) · `docs/30-engines/` |

## Documentos oficiais

- [Volume 3 — Domain Model](../03-domain-model.md)
- [Volume 4 — Entity Specification](../04-entity-specification.md)
- [Volume 10 — Game Engine](../10-game-engine.md)
- `docs/15-domain/`
- Module Map — Domain / BCs

## Regra para satélites

Docs Club, Competition, Match, Transfer, Finance, Youth, Media, etc. **ligam a este pilar** (e a Runtime/Data se tocarem ciclo ou persistência); não redefinem Aggregate de vínculo nem a estrutura de BCs.
```

- [ ] **Step 5: Verify files and headings**

Run:

```bash
test -f docs/bible/pillars/README.md
test -f docs/bible/pillars/simulation-runtime.md
test -f docs/bible/pillars/data-architecture.md
test -f docs/bible/pillars/domain-architecture.md
rg -n "^# (Simulation Runtime|Data Architecture|Domain Architecture|Engineering Pillars)" docs/bible/pillars/
```

Expected: all four exist; four title hits.

- [ ] **Step 6: Commit**

```bash
git add docs/bible/pillars/
git commit -m "$(cat <<'EOF'
docs: add three engineering pillar indexes

EOF
)"
```

---

### Task 2: Update Architecture Bible README (+ optional docs/README)

**Files:**
- Modify: `docs/bible/README.md`
- Modify: `docs/README.md` (optional one-liner if Bible is mentioned; if `docs/README.md` is still the legacy mobile index without Bible, skip or add a single row for `bible/pillars/`)

**Interfaces:**
- Consumes: paths from Task 1
- Produces: Bible entry point that leads with pillars

- [ ] **Step 1: Rewrite the opening of `docs/bible/README.md`**

Replace the first paragraph and insert a **Pilares** section **before** `## Regras`, so the file starts like this:

```markdown
# Architecture Bible

Índice lógico da documentação da **Phoenix Platform** (o jogo Phoenix Manager é um cliente).

## Pilares de engenharia

Fonte de verdade estável. Docs novos e satélites **referenciam** estes pilares — não redefinem os conceitos-base.

| Pilar | Pergunta | Documento |
|-------|----------|-----------|
| Simulation Runtime | Como o motor executa a simulação? | [pillars/simulation-runtime.md](pillars/simulation-runtime.md) |
| Data Architecture | Como os dados vivem, persistem e se consultam? | [pillars/data-architecture.md](pillars/data-architecture.md) |
| Domain Architecture | Como as regras de futebol se organizam? | [pillars/domain-architecture.md](pillars/domain-architecture.md) |

Visão geral: [pillars/README.md](pillars/README.md).

Planta: **10 macro-módulos** — [Platform Overview](../10-architecture/01-overview.md). A localização física dos ficheiros continua nas pastas numeradas (`00-project/` … `90-roadmap/`) e em `specs/`.

## Regras
```

Keep the existing Regras content, but change the line:

`**Platform Architecture** ≠ **Domain Model** ≠ …`

to also mention pillars:

`**Pilares** (Runtime · Data · Domain) ≠ volumes satélite. Platform Architecture ≠ Domain Model ≠ Entity Specification ≠ Core Business Processes ≠ Event-Driven Architecture ≠ Software Architecture.`

- [ ] **Step 2: Relabel the volumes table**

Change the sentence before the table from:

`Cada volume responde à pergunta: que documentos cobrem este tema?`

to:

`## Satélites (volumes)`

`Cada volume é um **satélite**: responde “que documentos cobrem este tema?” e deve apontar para o(s) pilar(es) quando tocar Runtime, Data ou Domain.`

Keep the 20-row table unchanged.

- [ ] **Step 3: Optional `docs/README.md`**

If `docs/README.md` has a table of doc folders, add:

`| [bible/pillars/](bible/pillars/README.md) | Três pilares de engenharia (Runtime · Data · Domain) |`

If the file is still only the legacy mobile docs index with no Bible section, **skip** this step (do not rewrite the whole README).

- [ ] **Step 4: Verify**

Run:

```bash
rg -n "Pilares de engenharia|Satélites \(volumes\)|pillars/simulation-runtime" docs/bible/README.md
```

Expected: hits for all three patterns.

- [ ] **Step 5: Commit**

```bash
git add docs/bible/README.md
# only if Step 3 applied:
# git add docs/README.md
git commit -m "$(cat <<'EOF'
docs: lead Architecture Bible with engineering pillars

EOF
)"
```

---

### Task 3: Enforce rules in AGENTS, ARCHITECTURE_RULES, STYLE_GUIDE + ADR

**Files:**
- Modify or create: `docs/AGENTS.md`
- Modify: `docs/ARCHITECTURE_RULES.md`
- Modify: `docs/STYLE_GUIDE.md`
- Modify or create: `docs/DECISIONS.md`
- Modify: `docs/superpowers/specs/2026-07-22-three-engineering-pillars-design.md` (status line)

**Interfaces:**
- Consumes: pillar paths from Task 1
- Produces: enforceable agent/style/ADR rules

- [ ] **Step 1: `docs/AGENTS.md`**

If the file **exists**, insert near the top (after the first short rules, before or inside the long Domain paragraph) this sentence:

`Pilares de engenharia (fonte de verdade): Simulation Runtime · Data Architecture · Domain Architecture — \`docs/bible/pillars/\`. Docs satélite referenciam pilares; não redefinem Tick, World State, World Changes, Event Buses, IDs, Aggregate de vínculo, nem BCs.`

If the file **does not exist**, create a minimal `docs/AGENTS.md` containing at least that sentence plus a pointer to `ARCHITECTURE_RULES.md` and `bible/pillars/README.md` (do not invent a full second copy of ARCHITECTURE_RULES). Prefer merging PR #5 first so the fuller AGENTS from that branch is the base.

- [ ] **Step 2: Patch `docs/ARCHITECTURE_RULES.md`**

After the first plant/module-map bullet block (near the top), add a new paragraph:

```markdown
**Pilares de engenharia:** [Simulation Runtime](bible/pillars/simulation-runtime.md) · [Data Architecture](bible/pillars/data-architecture.md) · [Domain Architecture](bible/pillars/domain-architecture.md) (`bible/pillars/README.md`). Documentação nova ou satélite **referencia** estes pilares; **proibido** redefinir Tick, World State, World Changes, Event Buses, formato de ID `{type}:{ulid}`, Aggregate de vínculo, ou a organização em Bounded Contexts — só link ao pilar e depois ao volume/pasta oficial.
```

- [ ] **Step 3: Patch `docs/STYLE_GUIDE.md` under `## Documentação`**

After “Se um rascunho misturar duas perguntas…”, add:

```markdown
**Pilares:** docs novos (Club, Match, Transfer, Finance, …) declaram no topo qual(is) pilar(es) tocam — [bible/pillars/README.md](bible/pillars/README.md) — e não redefinem conceitos dos pilares.
```

Also update the line:

`Organização lógica: Architecture Bible (20 volumes em \`bible/\`).`

to:

`Organização lógica: Architecture Bible — **3 pilares** (\`bible/pillars/\`) + satélites (20 volumes em \`bible/\`).`

- [ ] **Step 4: ADR in `docs/DECISIONS.md`**

If `DECISIONS.md` **exists**, insert after the Formato/`---` header (top of entries):

```markdown
## 2026-07-22

Decisão:

Três **pilares de engenharia** na Architecture Bible — Simulation Runtime, Data Architecture, Domain Architecture — como camada acima dos volumes 1–20 (satélites). Índices em `docs/bible/pillars/`.

Motivo:

Evitar dezenas de documentos isolados que redefinem Tick, World State, IDs e Bounded Contexts; manter a Bible como manual de engenharia consistente.

Alternativas:

- Consolidar volumes existentes dentro dos pilares (fundir Vol. 5/3–4/9) nesta fase
- Substituir a grelha 1–20 pelos três pilares sem satélites numerados
- Um único ficheiro `00-engineering-pillars.md` com três secções

Consequências futuras:

Docs novos obrigam cabeçalho de pilares; fases B/C podem fundir prosa e limpar satélites. Spec: [2026-07-22-three-engineering-pillars-design.md](superpowers/specs/2026-07-22-three-engineering-pillars-design.md).

Resultado:

Camada de pilares + regra operacional adoptadas (estrutura nesta entrega).
```

If `DECISIONS.md` **does not exist**, create it with the Formato section from the design culture (`Data`, `Decisão`, `Motivo`, `Alternativas`, `Consequências futuras`, `Resultado`) plus this ADR only. Prefer merging PR #5 first if that branch already has a full DECISIONS.md.

- [ ] **Step 5: Update design status**

In the spec file, set:

`**Status:** Approved — docs delivery planned in \`docs/superpowers/plans/2026-07-22-three-engineering-pillars.md\``

- [ ] **Step 6: Verify**

Run:

```bash
rg -n "bible/pillars|Pilares de engenharia" docs/AGENTS.md docs/ARCHITECTURE_RULES.md docs/STYLE_GUIDE.md docs/DECISIONS.md
test -f docs/bible/pillars/simulation-runtime.md
```

Expected: hits in all four rule/ADR files; pillars still present.

- [ ] **Step 7: Commit**

```bash
git add docs/ARCHITECTURE_RULES.md docs/STYLE_GUIDE.md docs/superpowers/specs/2026-07-22-three-engineering-pillars-design.md
git add docs/AGENTS.md docs/DECISIONS.md 2>/dev/null || true
git commit -m "$(cat <<'EOF'
docs: enforce engineering pillars in agents, style, and ADR

EOF
)"
```

---

## Spec coverage (self-review)

| Spec requirement | Task |
|------------------|------|
| `pillars/README` + three indexes | 1 |
| Template sections on each pillar | 1 |
| Bible README pillars above volumes | 2 |
| Volumes labelled satellites | 2 |
| Optional docs/README | 2 |
| AGENTS + ARCHITECTURE_RULES + STYLE | 3 |
| ADR | 3 |
| Structure only / no volume merge | Global |
| Success criteria | Tasks 1–3 verifies |

## Placeholder scan

None — full markdown bodies and commands included.
