# Platform Milestones

Qual é a ordem canónica de construção da Phoenix Platform?

**Desktop Client só no Milestone 4.** M1–M3 são headless e testáveis. ADR: [ADR-0034](../DECISIONS.md#adr-0034).

Isto **substitui** a narrativa “gameplay-first / desktop cedo” como roadmap de arquitectura. O [plano.md](../plano.md) continua a ser o tracker operacional do protótipo TS actual; novos trabalhos de plataforma alinham-se a esta grelha.

## Ordem

| # | Milestone | Entrega | Apps |
|---|-----------|---------|------|
| **M1** | Foundation | Shared, contracts/Zod, database loaders, toolchains, CI, **contratos de engenharia** | CLI smoke |
| **M2** | Runtime | Tick, scheduler, World Changes commit, buses de transporte, RandomService | CLI / sim harness |
| **M3** | Football Engine | Domain Systems (BCs), wired pela Application; época headless | CLI |
| **M4** | Desktop Client | Electron UI sobre Application estável | `apps/desktop` |
| **M5** | Database Editor | Editor de packs (app ou extract do Mods) | `database-editor` |
| **M6** | Gameplay | Loops de carreira jogáveis (mercado, finanças, tácticas na UI) | Desktop |
| **M7** | Content → Steam Early Access | Conteúdo + critérios EA ([07-release-strategy.md](../85-deployment/07-release-strategy.md)) | Steam |

## Sempre

1. Fechar o milestone actual antes de promover o seguinte como “feito”.
2. Gates de teste do milestone ([00-testing-strategy.md](../80-testing/00-testing-strategy.md)).
3. Package novo só com [Package Contract](../10-architecture/22-package-contracts.md).

## Nunca

1. Bloquear M1–M3 por pixels de UI.
2. Tratar marcos TS 1–5d do protótipo como se fossem esta grelha (são legado operacional).
3. Criar `packages/domain|runtime|ui` em disco antes dos contratos + milestone correspondente ([ADR-0035](../DECISIONS.md#adr-0035)).

## Relação com docs v0.1 / plano

- [v0.1.md](v0.1.md) — aponta para **Foundation (M1)** conceptual; detalhe operacional no plano.
- [plano.md](../plano.md) — protótipo actual; novas features de plataforma referenciam M1–M7 aqui.
- [Vol. 20](../bible/20-roadmap.md) — índice; este ficheiro é a ordem canónica de plataforma.

Ver também: [03-monorepo.md](../10-architecture/03-monorepo.md) · [Vol. 21](../bible/21-development-architecture.md)
