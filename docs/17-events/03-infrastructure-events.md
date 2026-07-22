# Infrastructure Events

Acontecimentos **técnicos** da plataforma (I/O, compile, cache, backup).

Volume: [Event-Driven Architecture](../bible/06-event-driven-architecture.md). Transporte: [Infrastructure Event Bus](../10-architecture/07-event-system.md).

## Objetivo

Contrato de Infrastructure Events: o que é, quem publica/consome, e o que um evento **nunca** faz.

## Quem publica / consome

| Papel | Actores |
|-------|---------|
| Publica | Packages de Infrastructure |
| Consome | Packages de Infrastructure |

**Não** usam este bus: Domain Systems, Application Services / UI (excepto via bridge futuro explícito — fora de âmbito).

## O que é um Infrastructure Event

Algo técnico que **já aconteceu**. Nunca um comando.

| Correcto | Errado |
|----------|--------|
| DatabaseCompiled | CompileDatabase |
| CacheInvalidated | InvalidateCache |
| BackupCompleted | RunBackup |

## Imutabilidade

Depois de criado, o evento **nunca** muda.

## Inventário inicial

### Database / mods

DatabaseCompiled · DatabaseValidated · ModPackMounted

### Ops

CacheInvalidated · BackupCompleted

Novos eventos entram neste inventário **antes** do código.

## Regras

Infrastructure Events **nunca**:

- alteram World State / entidades de domínio;
- executam regras de futebol;
- são publicados no Domain Event Bus ou Application Event Bus.

## Semântica

- Entrega síncrona por omissão
- Sem replay obrigatório
- **Não** entram no Domain Event Log

## Convenções

Passado PascalCase: `DatabaseCompiled`, `BackupCompleted`.

## Pontes

| Tema | Documento |
|------|-----------|
| Volume | [06-event-driven-architecture.md](../bible/06-event-driven-architecture.md) |
| Event Buses | [07-event-system.md](../10-architecture/07-event-system.md) |
| Domain Events | [01-domain-events.md](01-domain-events.md) |
| Design | [2026-07-22-three-level-event-buses-design.md](../superpowers/specs/2026-07-22-three-level-event-buses-design.md) |
