# Application Events

Acontecimentos da **aplicação** (sessão, settings, UI) — não regras de futebol.

Volume: [Event-Driven Architecture](../bible/06-event-driven-architecture.md). Transporte: [Application Event Bus](../10-architecture/07-event-system.md).

## Objetivo

Contrato de Application Events: o que é, quem publica/consome, e o que um evento **nunca** faz.

## Quem publica / consome

| Papel | Actores |
|-------|---------|
| Publica | Application Services (+ adapters de app) |
| Consome | Application Services / UI adapters da app |

**Não** usam este bus: Domain Systems, packages de Infrastructure.

## O que é um Application Event

Algo que **já aconteceu** na app. Nunca um comando.

| Correcto | Errado |
|----------|--------|
| SaveLoaded | LoadSave |
| SettingsChanged | ChangeSettings |
| ThemeChanged | SetTheme |

## Imutabilidade

Depois de criado, o evento **nunca** muda.

## Inventário inicial

### Sessão / carreira

SaveLoaded · SaveSaved · CareerStarted · CareerAbandoned

### Preferências

SettingsChanged · ThemeChanged · LocaleChanged

Novos eventos entram neste inventário (ou na Ubiquitous Language da app) **antes** do código.

## Regras

Application Events **nunca**:

- alteram World State / entidades de domínio;
- executam lógica de negócio de futebol;
- são publicados no Domain Event Bus ou Infrastructure Event Bus.

Apenas informam a camada de aplicação.

## Semântica

- Entrega síncrona por omissão
- Sem replay obrigatório
- **Não** entram no Domain Event Log

## Convenções

Passado PascalCase: `SaveLoaded`, `SettingsChanged`.

## Pontes

| Tema | Documento |
|------|-----------|
| Volume | [06-event-driven-architecture.md](../bible/06-event-driven-architecture.md) |
| Event Buses | [07-event-system.md](../10-architecture/07-event-system.md) |
| Domain Events | [01-domain-events.md](01-domain-events.md) |
| Design | [2026-07-22-three-level-event-buses-design.md](../superpowers/specs/2026-07-22-three-level-event-buses-design.md) |
