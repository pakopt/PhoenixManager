# Phoenix Platform — Three-Level Event Buses (Design)

**Date:** 2026-07-22  
**Status:** Approved — docs delivery planned in `docs/superpowers/plans/2026-07-22-three-level-event-buses.md`  
**Scope of first delivery:** Documentation / contract only (no TypeScript, no Flutter migration)

## Intent

Replace the single conceptual Event Bus with **three physical event buses** (Domain, Application, Infrastructure), each with a typed event contract and **strict per-layer publish/subscribe rules**. This prevents mixing football-domain facts with app session/UI facts and technical infrastructure signals.

## Decisions

| Topic | Choice |
|-------|--------|
| Physical topology | **A — three buses** (`DomainEventBus`, `ApplicationEventBus`, `InfrastructureEventBus`) |
| Access rules | **A — strict by layer** (no cross-bus publish/subscribe; no implicit bridging) |
| Delivery now | **A — documentation only** |
| Shared ownership | Approach **1**: transport APIs live in **Shared / Events**; event contracts documented per level |
| Bridging | Out of scope; forbidden by default |
| Flutter legacy `EventBus` | Out of scope for this delivery |

## Architecture

```
Shared (transporte)
├── DomainEventBus
├── ApplicationEventBus
└── InfrastructureEventBus

Contratos (imutáveis, past-tense, sem lógica)
├── Domain Events          → docs/17-events/01-domain-events.md
├── Application Events     → docs/17-events/02-application-events.md (novo)
└── Infrastructure Events  → docs/17-events/03-infrastructure-events.md (novo)
```

### Access matrix (strict)

| Bus | May publish | May subscribe |
|-----|-------------|---------------|
| Domain | Domain Systems / Aggregates | Domain Systems |
| Application | Application Services (+ app adapters) | Application Services / app UI adapters |
| Infrastructure | Infrastructure packages | Infrastructure packages |

Rules:

- No layer publishes on another layer’s bus.
- No layer subscribes to another layer’s bus.
- Cross-cutting needs require an **explicit** future bridge design (not part of this delivery).
- Domain Events still **inform only**; they do not mutate entities. State changes remain **World Changes**.
- Application and Infrastructure events must not mutate World State through their buses.

### Placement in Module Map

- **Shared / Events** owns the three transport types (not a single `EventBus`).
- Domain / Application / Infrastructure own their event catalogs and who may use each bus.
- Volume 6 (Event-Driven Architecture) indexes all three contracts; Domain remains the primary inter-Bounded-Context channel.

## Event contracts

### Shared conventions (all three levels)

- Past-tense PascalCase names (`PlayerTransferred`, `SaveLoaded`, `DatabaseCompiled`)
- Immutable after creation
- No business logic; no entity mutation
- Typed payloads; version the contract when the payload shape changes
- New events enter the level’s inventory **before** code

### Domain Events

Canonical doc: [01-domain-events.md](../../17-events/01-domain-events.md).

Purpose: communication between Domain Systems / Bounded Contexts during simulation.

Examples: `PlayerTransferred`, `ContractExpired`, `MatchFinished`, `DayAdvanced`, `SalaryPaid`.

Semantics (contract for future implementation):

- Synchronous delivery within a Tick
- Causal ordering respected
- Normal lifetime = current Tick (debug/replay may retain a Domain Event Log)

### Application Events

New doc: `docs/17-events/02-application-events.md`.

Purpose: application/session/UI lifecycle facts — not football rules.

Initial inventory:

- `SaveLoaded` · `SaveSaved` · `CareerStarted` · `CareerAbandoned`
- `SettingsChanged` · `ThemeChanged` · `LocaleChanged`

Commands stay commands (imperative). Only facts that already happened are events.

Semantics: synchronous by default; no mandatory replay; not written to the Domain Event Log.

### Infrastructure Events

New doc: `docs/17-events/03-infrastructure-events.md`.

Purpose: technical platform signals.

Initial inventory:

- `DatabaseCompiled` · `DatabaseValidated`
- `CacheInvalidated` · `BackupCompleted` · `ModPackMounted`

Semantics: synchronous by default; no mandatory replay; not written to the Domain Event Log.

## Legacy Flutter classification (reference only)

When the Flutter `PhoenixEvent` hierarchy is eventually migrated, classify as:

| Legacy event | Level |
|--------------|-------|
| `MatchPlayedEvent`, `SalariesPaidEvent`, `DayAdvancedEvent`, transfer/injury/etc. domain signals | Domain |
| `WorldSavedEvent`, `WorldInitializedEvent` | Application |
| Future compile / cache / backup signals | Infrastructure |

No Flutter code changes in this delivery.

## Documentation deliverables

Update or create:

1. `docs/10-architecture/07-event-system.md` — three buses + access matrix
2. `docs/bible/06-event-driven-architecture.md` — index all three contracts
3. `docs/17-events/01-domain-events.md` — clarify Domain Bus only
4. `docs/17-events/02-application-events.md` — **create**
5. `docs/17-events/03-infrastructure-events.md` — **create**
6. `docs/10-architecture/19-module-map.md` — Shared/Events = three buses
7. `docs/10-architecture/01-overview.md` — diagram reflects three buses
8. `docs/AGENTS.md` — Domain Systems communicate via **Domain Event Bus**
9. `docs/DECISIONS.md` — ADR entry for three-level buses

## Out of scope

- TypeScript packages / EventBus implementations
- Flutter `EventBus` migration
- Implicit or automatic bridging between buses
- Persistence, telemetry, or replay for Application/Infrastructure events
- Changing World Changes / Simulation Cycle mechanics beyond clarifying event vs change

## Success criteria

- Docs consistently describe three buses and the strict access matrix
- Domain / Application / Infrastructure each have a contract doc with initial inventory
- Module Map and Platform Overview no longer imply a single global Event Bus
- ADR records the decision and rejected alternatives (typed single bus; hybrid)

## Follow-up (after this doc delivery)

Implementation plan will update the documentation files listed above. A later milestone may add TypeScript transports in Shared and migrate consumers.
