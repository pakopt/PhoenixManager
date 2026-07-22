# Domain Events

Como a comunicação interna da plataforma acontece.

Systems **não** comunicam directamente. Comunicam através de **Domain Events** via **Domain Event Bus**.

Volume: [Event-Driven Architecture](../bible/06-event-driven-architecture.md). Transporte: [Domain Event Bus](../10-architecture/07-event-system.md). Estado: [World Changes](../16-processes/02-world-changes.md).

## Objetivo

Definir o contrato de Domain Events: o que é um evento, quem publica/consome, ordem, versão, replay e o que um evento **nunca** faz.

## Filosofia

**Errado** — cadeia de chamadas:

```
Transfer → Finance → Media → Statistics → History → AI → UI
```

Incomportável a longo prazo.

**Correcto:**

```
Transfer Completed (Domain Event)
        │
        ▼
    Domain Event Bus
        │
        ▼
Todos os interessados recebem (sem se conhecerem)
```

## Arquitectura

```
Application Service
        │
        ▼
Domain Service / Aggregate
        │
        ├──► Domain Event ──► Domain Event Bus ──► Subscribers (Domain Systems)
        │
        └──► World Changes ──► Validação ──► Commit ──► World State
```

Eventos **informam**. World Changes **alteram** estado. Não se confundem.

Application Events e Infrastructure Events usam **outros** buses — ver [Application Events](02-application-events.md) e [Infrastructure Events](03-infrastructure-events.md). Não misturar níveis.

## O que é um Domain Event

Algo que **já aconteceu**. Nunca algo que vai acontecer.

| Correcto (evento) | Errado (comando) |
|-------------------|------------------|
| PlayerTransferred | TransferPlayer |
| ContractExpired | ExpireContract |
| MatchFinished | FinishMatch |

## Imutabilidade

Depois de criado, o evento **nunca** muda.

Exemplo `PlayerTransferred`: Player · OldClub · NewClub · Date · Fee — campos fixos.

## Categorias (inventário inicial)

### World

SeasonStarted · SeasonFinished · DayAdvanced · CompetitionOpened · CompetitionClosed

### Contract

ContractSigned · ContractActivated · ContractExpired · ContractRenewed · ContractTerminated · ContractExtended · ClauseTriggered

### Player

PlayerCreated · PlayerRetired · PlayerInjured · PlayerRecovered · PlayerAwarded · PlayerTransferred

### Match

MatchStarted · GoalScored · CardShown · HalfFinished · MatchFinished

### Club

ManagerHired · ManagerSacked · BudgetChanged · SponsorSigned

### Finance

SalaryPaid · TransferFeePaid · PrizeAwarded · TicketRevenueReceived

Novos eventos entram primeiro na [Ubiquitous Language](../15-domain/03-ubiquitous-language.md) (ou neste inventário) antes do código.

## Quem publica

Cada Aggregate publica **apenas** eventos do seu domínio.

| Aggregate | Exemplos |
|-----------|----------|
| Player | PlayerRetired · PlayerInjured |
| Contract | ContractExpired · ContractSigned |
| Competition | CompetitionFinished · CompetitionOpened |
| Match | MatchFinished · GoalScored |

## Quem consome

Exemplo `PlayerTransferred` pode interessar: Media · Finance · Statistics · History · Achievements · AI · UI.

Nenhum consumidor conhece os outros.

Consumidores **não** mutam o World directamente — propõem World Changes ou reagem no Scheduler.

## Domain Event Bus

O Domain Event Bus (Shared / Events) tem como responsabilidades: receber · distribuir · ordenar · monitorizar · guardar (opcional: debug/replay).

Nada mais. Spec de módulo: [07-event-system.md](../10-architecture/07-event-system.md).

## Event Ordering

Os eventos têm ordem causal. Exemplo:

```
TransferAccepted
  → ContractTerminated
  → ContractCreated
  → PlayerTransferred
  → MediaGenerated
```

Nunca Media antes da transferência estar commitada/publicada na ordem correcta.

## Event Versioning

Eventos têm versão (`PlayerTransferred` v1 → v2) sem quebrar saves antigos.

## Event Replay

Rebuild / debug: Save + Events ou Database + Events.

Útil para investigação de bugs e reprodutibilidade (com seed).

## Event Log

Histórico por Tick (debug / opcional):

```
Tick 1543
  → PlayerTransferred
  → ClubBudgetChanged
  → MediaArticleCreated
  → HistoryUpdated
```

## Performance

Em produção normal, eventos vivem **só durante o Tick** e depois são descartados.

Excepções: Debug Mode · persistência explícita para Replay.

## Regras

Eventos **nunca**:

- alteram entidades;
- executam lógica de negócio.

Apenas informam.

## Convenções

Sempre **passado** (PascalCase Past): `PlayerTransferred`, `ContractExpired`, `SeasonFinished`.

Nunca imperativo: `TransferPlayer`.

## Pontes

| Tema | Documento |
|------|-----------|
| Volume | [06-event-driven-architecture.md](../bible/06-event-driven-architecture.md) |
| Event Buses (módulo) | [07-event-system.md](../10-architecture/07-event-system.md) |
| Application Events | [02-application-events.md](02-application-events.md) |
| Infrastructure Events | [03-infrastructure-events.md](03-infrastructure-events.md) |
| World Changes | [02-world-changes.md](../16-processes/02-world-changes.md) |
| Simulation Cycle | [01-simulation-cycle.md](../16-processes/01-simulation-cycle.md) |
| Contract Aggregate | [06-contract-aggregate.md](../15-domain/06-contract-aggregate.md) |

Ver também: [ARCHITECTURE_RULES.md](../ARCHITECTURE_RULES.md) · [Platform Overview](../10-architecture/01-overview.md)
