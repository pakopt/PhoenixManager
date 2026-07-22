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
