# Phoenix Platform — Three Engineering Pillars (Design)

**Date:** 2026-07-22  
**Status:** Approved — docs delivery planned in `docs/superpowers/plans/2026-07-22-three-engineering-pillars.md`
**Scope of first delivery:** Documentation structure only (pillar indexes + Bible/agents rules; no content merge of volumes)

## Intent

Stop growing the Architecture Bible as a flat collection of independent volumes. Introduce **three engineering pillars** as the stable reference layer. All future topic docs (Club, Competition, Match, Transfer, Finance, Youth, Media, …) must **reference** these pillars instead of redefining core concepts. That reduces duplication and turns the Bible into an engineering manual.

## Decisions

| Topic | Choice |
|-------|--------|
| Relation to volumes 1–20 | **A — new layer above**: pillars first; volumes become satellites that link to pillars |
| Delivery depth | **A — structure only**: create pillar indexes + rules; do not rewrite/merge volume bodies yet |
| Physical layout | Approach **1**: `docs/bible/pillars/` with three canonical index docs + pillars README |

## Architecture

```
Architecture Bible
├── PILARES (fonte de verdade — índices canónicos)
│   ├── Simulation Runtime
│   ├── Data Architecture
│   └── Domain Architecture
└── SATÉLITES (volumes 1–20 + pastas temáticas)
    └── apontam para os pilares; não redefinem conceitos-base
```

### Pillar map

| Pillar | Question it answers | Official docs it indexes (existing) |
|--------|---------------------|-------------------------------------|
| **Simulation Runtime** | How does the engine run the simulation? | Vol. 5 · `16-processes/` · Vol. 6 (Event Buses) · World Changes · Scheduler · RandomService · Simulation Runtime in Platform Overview |
| **Data Architecture** | How do data live, persist, and get queried? | Vol. 9 · Vol. 16 · `20-database/` · IDs · Compiled Database · Saves / Mods |
| **Domain Architecture** | How are football rules organised? | Vol. 3–4 · `15-domain/` · Module Map (Bounded Contexts) · Vol. 10 (engines as domain satellites) |

### Outside the pillars (remain satellites)

Vision · Platform Overview · Software Architecture · Technology · UI · Editor · AI · Testing · Deployment · Roadmap — and domain topic docs (Club, Match, Transfer, …) that **must declare which pillars they touch**.

## Pillar document template

Each of `simulation-runtime.md`, `data-architecture.md`, `domain-architecture.md` contains only:

1. **Question** it answers  
2. **Boundaries** — what this pillar is *not*  
3. **Canonical concepts** — short list with links (no redefinition of full prose)  
4. **Official documents** — volumes + folders  
5. **Satellite rule** — “link here; do not copy”

`docs/bible/pillars/README.md` defines pillar vs satellite and the obligation for new docs.

## Operational rule for future docs

Every new satellite doc (e.g. Club, Match, Finance) must:

- State at the top which pillar(s) it touches  
- **Not** redefine: Tick, World State, World Changes, Event Bus / Domain Events, ID format `{type}:{ulid}`, Aggregate-de-vínculo rule, Bounded Context structure — only link to the relevant pillar (and then to the official volume/folder)

## Documentation deliverables

Create:

1. `docs/bible/pillars/README.md`  
2. `docs/bible/pillars/simulation-runtime.md`  
3. `docs/bible/pillars/data-architecture.md`  
4. `docs/bible/pillars/domain-architecture.md`

Update:

5. `docs/bible/README.md` — Pilares section above the volumes table; clarify volumes are satellites  
6. `docs/AGENTS.md` — reference pillars as the engineering spine  
7. `docs/ARCHITECTURE_RULES.md` — same rule (docs must not redefine pillar concepts)  
8. `docs/STYLE_GUIDE.md` — under Documentação: new docs declare pillars first  
9. `docs/DECISIONS.md` — ADR for three engineering pillars  

Optional light touch (same delivery if trivial):

10. `docs/README.md` — one line pointing to pillars when describing the Bible  

## Out of scope

- Rewriting or merging Vol. 5 / 3–4 / 9 / 16 content into the pillars  
- Deduplicating existing Club / Match / Transfer / Finance docs  
- Renumbering or deleting Bible volumes  
- Code / package changes  

## Success criteria

- Bible README leads with three pillars; volumes labelled as satellites  
- Three pillar indexes exist with the shared template  
- AGENTS + ARCHITECTURE_RULES (+ STYLE_GUIDE) enforce the reference rule  
- ADR records the decision and rejected alternatives  
- Volume bodies unchanged except via Bible README framing (no content merge)

## Follow-up (later milestones)

- Phase B: fold essential prose into pillars from Vol. 5 / 3–4 / 9–16  
- Phase C: scrub satellites to remove duplicated definitions and add pillar headers  
