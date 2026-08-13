# Architecture Bible

Índice lógico da documentação da **Phoenix Platform** (o jogo Phoenix Manager é um cliente).

## Pilares de engenharia

Fonte de verdade estável. Docs novos e satélites **referenciam** estes pilares — não redefinem os conceitos-base.

| Pilar | Pergunta | Documento |
|-------|----------|-----------|
| Simulation Runtime | Como o motor executa a simulação? | [pillars/simulation-runtime.md](pillars/simulation-runtime.md) |
| Data Architecture | Como os dados vivem, persistem e se consultam? | [pillars/data-architecture.md](pillars/data-architecture.md) |
| Domain Architecture | Como as regras de futebol se organizam? | [pillars/domain-architecture.md](pillars/domain-architecture.md) |

Visão geral: [pillars/README.md](pillars/README.md).

Planta: **10 macro-módulos** — [Platform Overview](../10-architecture/01-overview.md). A localização física dos ficheiros continua nas pastas numeradas (`00-project/` … `90-roadmap/`) e em `specs/`.

## Regras

Nada entra na Architecture Bible sem pensarmos primeiro se ainda fará sentido daqui a 10 anos.

**Regra de Aggregate de vínculo:** relação entre duas entidades com duração, condições ou obrigações → Aggregate próprio, nunca campo embutido — [Domain Model](../15-domain/01-overview.md) · [ARCHITECTURE_RULES.md](../ARCHITECTURE_RULES.md).

Preferir conceitos estáveis do domínio (motores, entidades, princípios) a detalhes transitórios (ferramenta X, versão Y, hype de framework). Detalhe operacional ou roadmap curto fica fora da Bible ou no volume Roadmap — não como “verdade arquitectónica”.

**Pilares** (Runtime · Data · Domain) ≠ volumes satélite. Platform Architecture ≠ Domain Model ≠ Entity Specification ≠ Core Business Processes ≠ Event-Driven Architecture ≠ Software Architecture.

## Satélites (volumes)

Cada volume é um **satélite**: responde “que documentos cobrem este tema?” e deve apontar para o(s) pilar(es) quando tocar Runtime, Data ou Domain.

| Volume | Tema | Índice |
|--------|------|--------|
| 1 | Vision | [01-vision.md](01-vision.md) |
| 2 | Platform Architecture | [02-platform-architecture.md](02-platform-architecture.md) |
| 3 | Domain Model | [03-domain-model.md](03-domain-model.md) |
| 4 | Entity Specification | [04-entity-specification.md](04-entity-specification.md) |
| 5 | Core Business Processes | [05-core-business-processes.md](05-core-business-processes.md) |
| 6 | Event-Driven Architecture | [06-event-driven-architecture.md](06-event-driven-architecture.md) |
| 7 | Software Architecture | [07-software-architecture.md](07-software-architecture.md) |
| 8 | Technology | [08-technology.md](08-technology.md) |
| 9 | Database | [09-database.md](09-database.md) |
| 10 | Game Engine | [10-game-engine.md](10-game-engine.md) |
| 11 | Match Engine | [11-match-engine.md](11-match-engine.md) |
| 12 | AI | [12-ai.md](12-ai.md) |
| 13 | UI | [13-ui.md](13-ui.md) |
| 14 | Database Editor | [14-editor.md](14-editor.md) |
| 15 | Modding | [15-modding.md](15-modding.md) |
| 16 | Save System | [16-save-system.md](16-save-system.md) |
| 17 | Performance | [17-performance.md](17-performance.md) |
| 18 | Testing | [18-testing.md](18-testing.md) |
| 19 | Deployment | [19-deployment.md](19-deployment.md) |
| 20 | Roadmap | [20-roadmap.md](20-roadmap.md) |
| 21 | Development Architecture | [21-development-architecture.md](21-development-architecture.md) |

**Contratos de engenharia:** [coding](../10-architecture/20-coding-standards.md) · [ADR](../10-architecture/21-adr-process.md) · [packages](../10-architecture/22-package-contracts.md) · [errors](../10-architecture/23-error-handling.md) · [perf](../10-architecture/24-performance-guidelines.md) · [testing](../80-testing/00-testing-strategy.md) · [save integrity](../60-save-system/07-integrity-security.md) · [release](../85-deployment/07-release-strategy.md). **Milestones:** [00-platform-milestones.md](../90-roadmap/00-platform-milestones.md).

Ver também: [docs/README.md](../README.md) · [STYLE_GUIDE.md](../STYLE_GUIDE.md) · [DECISIONS.md](../DECISIONS.md)
