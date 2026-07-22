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
