# Volume 6 — Event-Driven Architecture

**Como a comunicação interna da plataforma acontece?**

Há **três** Event Buses (Domain · Application · Infrastructure). Domain Systems não se chamam uns aos outros — publicam e consomem **Domain Events** via **Domain Event Bus**.

Não confundir com [Volume 2 — Platform Architecture](02-platform-architecture.md) (módulo Event Buses), [Volume 5 — Core Business Processes](05-core-business-processes.md) (Tick / World Changes) nem [Volume 7 — Software Architecture](07-software-architecture.md) (packages).

| # | Título | Documento |
|---|--------|-----------|
| 01 | Domain Events | [01-domain-events.md](../17-events/01-domain-events.md) |
| 02 | Application Events | [02-application-events.md](../17-events/02-application-events.md) |
| 03 | Infrastructure Events | [03-infrastructure-events.md](../17-events/03-infrastructure-events.md) |

Transporte (módulo 8): [Event Buses](../10-architecture/07-event-system.md). Design: [three-level event buses](../superpowers/specs/2026-07-22-three-level-event-buses-design.md).

← [Architecture Bible](README.md)
