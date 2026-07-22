# Volume 21 — Development Architecture

Como o **monorepo**, packages e dependências de desenvolvimento estão organizados (layout alvo, diamond graph, contratos de package)?

Dono canónico do layout físico e das regras de import entre packages. O [Volume 7 — Software Architecture](07-software-architecture.md) indexa fluxo de dados, eventos e plugins; este volume indexa **como o código vive no disco e quem depende de quem**.

**Documentação apenas nesta fase:** a árvore alvo descreve o destino; **não** se criam packages novos em disco até ao Milestone Foundation (ver [Platform Milestones](../90-roadmap/00-platform-milestones.md)).

| # | Título | Documento |
|---|--------|-----------|
| 01 | Monorepo Architecture | [03-monorepo.md](../10-architecture/03-monorepo.md) |
| 02 | Folder Structure (alvo) | [04-folder-structure.md](../10-architecture/04-folder-structure.md) |
| 03 | Dependency Rules (diamond) | [05-dependencies.md](../10-architecture/05-dependencies.md) |
| 04 | Package Contracts | [22-package-contracts.md](../10-architecture/22-package-contracts.md) |
| 05 | Coding Standards | [20-coding-standards.md](../10-architecture/20-coding-standards.md) |
| 06 | ADR Process | [21-adr-process.md](../10-architecture/21-adr-process.md) |

Pilares: [Simulation Runtime](pillars/simulation-runtime.md) · [Data Architecture](pillars/data-architecture.md) · [Domain Architecture](pillars/domain-architecture.md).

← [Architecture Bible](README.md)
