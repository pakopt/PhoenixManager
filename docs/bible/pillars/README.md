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
