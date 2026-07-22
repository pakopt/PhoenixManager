# Event Buses

**Módulo 8** da [Platform Overview](01-overview.md).

A plataforma tem **três** Event Buses físicos (transporte em Shared / Events). Não existe um bus global único.

| Bus | Contrato | Quem publica | Quem consome |
|-----|----------|--------------|--------------|
| Domain Event Bus | [Domain Events](../17-events/01-domain-events.md) | Domain Systems / Aggregates | Domain Systems |
| Application Event Bus | [Application Events](../17-events/02-application-events.md) | Application Services (+ adapters de app) | Application Services / UI adapters da app |
| Infrastructure Event Bus | [Infrastructure Events](../17-events/03-infrastructure-events.md) | Packages de Infrastructure | Packages de Infrastructure |

Transporte (cada bus): receber · distribuir · ordenar · monitorizar · guardar (opcional, conforme o nível).

## Regras de acesso (estritas)

- Cada camada **só** publica no seu bus.
- Cada camada **só** consome do seu bus.
- **Proibido** bridging implícito entre buses. Cruzamentos futuros exigem design explícito (ADR).
- Ninguém chama outro Domain System directamente — só **Domain Event Bus**.
- Application / Infrastructure **não** mutam World State via o seu bus.

## Domain

Única via de comunicação entre **Domain Systems**.

Alterações de estado: systems propõem **World Changes**. O Domain Event Bus propaga *notificações* (Domain Events) — eventos **não** mutam entidades.

```
Transfer System → Domain Event → Domain Event Bus → Finance, Media, Morale, History, …
```

O Simulation Runtime + **Simulation Scheduler** decidem *quando* os systems correm; o Domain Event Bus propaga *efeitos* entre eles.

Semântica: entrega síncrona dentro do Tick; ordenação causal; vida útil normal = Tick (debug/replay pode reter Domain Event Log).

## Application

Acontecimentos de sessão / app / UI (não regras de futebol). Ex.: `SaveLoaded`, `SettingsChanged`.

Semântica: síncrono por omissão; sem replay obrigatório; **não** entra no Domain Event Log.

## Infrastructure

Sinais técnicos. Ex.: `DatabaseCompiled`, `CacheInvalidated`, `BackupCompleted`.

Semântica: síncrono por omissão; sem replay obrigatório; **não** entra no Domain Event Log.

## Princípios (todos os níveis)

- Eventos tipados, imutáveis, no passado (`PlayerTransferred`, não `TransferPlayer`)
- Consumidores registam-se sem conhecer o emissor
- Sem mutação directa do World State — só World Changes (domínio)
- Eventos ≠ World Changes
- Novos eventos entram no inventário do nível **antes** do código

Ver: [Domain Events](../17-events/01-domain-events.md) · [Application Events](../17-events/02-application-events.md) · [Infrastructure Events](../17-events/03-infrastructure-events.md) · [World Changes](../16-processes/02-world-changes.md) · [Volume 6](../bible/06-event-driven-architecture.md) · [Volume 5](../bible/05-core-business-processes.md)

Ver também: [Platform Overview](01-overview.md) · [Fluxo de dados](06-data-flow.md) · [Design](../superpowers/specs/2026-07-22-three-level-event-buses-design.md)
